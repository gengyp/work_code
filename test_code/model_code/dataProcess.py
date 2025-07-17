# -*- coding:utf8 -*-
import sys
import numpy as np
import pandas as pd
from sklearn import preprocessing
from commonTools import CommonTool


class DataProcess(CommonTool):
    """
    docstring for DataProcess

    异常值处理
    输入：连续变量(离散变量不考虑，结合业务手动处理）
    输出：每个变量 异常值个数，占比，左端异常值列表，右端异常值列表
    """

    def __init__(self, df, target=None, ignore_columns=None):
        # 调用父类的初始化方法
        super(DataProcess, self).__init__(df, target, ignore_columns)

    def cat_num_caculate(self):
        var_type_dict = {}
        for i in self.df.columns:
            if self.df[i].dtypes == 'object':
                var_type_dict[i] = 'cat'
            else:
                var_type_dict[i] = 'num'
        self.var_type_dict = var_type_dict

    @property
    def check_na(self):
        # 查看数据集含有 NaN 值变量的类型及占比
        # df 转换成 boolean 对象，按列求和，并升序排列
        df_na = pd.DataFrame(self.df.isnull().sum().sort_values(
            ascending=False), columns=['missNum'])
        # df_na = df_na[df_na['missNum']>0]
        df_na['type'] = [self.df[i].dtypes for i in df_na.index]
        df_na['missRatio'] = df_na['missNum']*1.0/len(self.df)
        self.df_na = df_na  # 方便缺失值填充时，取缺失值下标
        return df_na

    def fillna_simple(self, drop_ratio=0.5):
        '''
        此处可聚类填充优化,处理NA值，这里遵循以下原则：
        1、变量类型为int或float,用前一个数(还可以是众数、均值、中位数等)替代
        2、变量类型为字符型，用'unknown'替代
        3、缺失值占比大于threshold(0.5)的变量直接删除
        '''
        count = 0
        print('缺失值大于 {} 的变量:'.format(drop_ratio))
        for i in self.df_na.index:
            if self.df_na.loc[i, 'missRatio'] >= drop_ratio:
                print(i, end='\t')
                # 直接删除列(axis=1) 直接替换 内存值改变
                self.df.drop(i, axis=1, inplace=True)
                count += 1
                continue
            if self.df[i].dtypes == np.dtype('object'):  # 字符串类型为 object
                self.df[i].fillna('unknow', inplace=True)
            else:
                self.df[i].fillna(method='pad', inplace=True)  # 用上一个值填充（快）
                self.df[i].fillna(self.df[i].mode()[0],
                                  inplace=True)  # 第一个值为空，用众数填充

        print('\n\nRemain var num is:{}({} NaN values),Drop num:{},Ignore num:{}\nOver!~~'.format(
            self.df.shape[1], self.df_na.shape[0], count, len(self.ignore_columns)))

    @property
    def fillna_tree(self):
        pass

    @property
    def labelencoder(self):
        '''
        离散变量编码函数,使用了sklearn的preprocessing.LabelEncoder()函数
        编码字典：trans_dict
        所有变量编码都是从 0 开始
        '''
        trans_dict = {}  # 字典的字典，变量的值为 编码对应的值
        le = preprocessing.LabelEncoder()
        for col in self.df.columns:
            # 字符串类型为 object
            if self.df[col].dtypes == np.dtype('object'):
                self.df[col] = le.fit_transform(
                    self.df[col].values)  # 将字符串编码成数值型的
                trans_dict[col] = dict([(i, v)
                                       for i, v in enumerate(le.classes_)])
        self.trans_dict = trans_dict
        self.__view_trans_dict()

    def __view_trans_dict(self):
        # 离散变量编码结果
        for k, v in self.trans_dict.items():
            print('\n当前字段:{}'.format(k))
            for k1, v1 in v.items():
                print('  编码:{} --> {}'.format(k1, v1))

    @property
    def cat_vars(self):
        '''
        离散变量列表
        '''
        cat = []
        for col in self.df.columns:
            if self.df[col].dtypes == np.dtype('object'):
                cat.append(col)
        print('cat var total:{}'.format(len(cat)))
        return cat

    @property
    def get_processedData(self):
        if self.ignore_columns:
            return self.recover_func()
        else:
            return self.df

    @property
    def outlier_analysis(self):
        # 异常值个数，占比，左端异常值列表，右端异常值列表
        lst = []
        for col in self.df.columns:
            if self.df[col].dtypes != np.dtype('object'):
                x = self.__outlier_3sigma(self.df[col])
                y = self.__outlier_boxplot(self.df[col])
                z = self.__outlier_zscore(self.df[col])
                tdf = pd.concat([x, y, z, x & y & z, self.df[col]], axis=1)
                tdf.columns = ['3sigma', 'boxplot', 'zscore', 'total', col]

                outlier_values = tdf.query('total==True')[col].values
                outlier_values.sort()
                if len(outlier_values) > 0:
                    left_out = outlier_values[outlier_values <
                                              self.df[col].mean()]
                    right_out = outlier_values[outlier_values >
                                               self.df[col].mean()]
                    lst.append([col, len(outlier_values), len(
                        outlier_values)/len(self.df[col]), left_out, right_out])
        outlier_df = pd.DataFrame(
            lst, columns=['变量名', '异常数', '异常占比', '左侧异常值', '右侧异常值'])
        return outlier_df

    def __outlier_3sigma(self, s, threshold=3):
        '''
        基于 3σ 原则 的异常值检测
        3σ原则只适用服从正态分布的数据，在正太分布假设下，大于3σ的值出现的概率小于0.003，
        属于小概率事件，故可认定其为异常值。
        '''
        # 效率问题：1.增加一列 temp 存储 bool
        return abs(s-s.mean())/s.std() > threshold

    def __outlier_boxplot(self, s):
        '''
        基于箱线图的异常值检测，不限制数据分布，鲁棒性更强
        '''
        IQR = s.describe().iloc[6] - s.describe().iloc[4]
        lower = s.describe().iloc[4] - 1.5*IQR
        upper = s.describe().iloc[6] + 1.5*IQR
        return (s < lower) | (s > upper)

    def __outlier_zscore(self, s, threshold=3.5):
        '''
        基于增强z-score的异常值检测,基于 MAD, MAD=median(|x-x.median()|)
        M_i = 0.6745*(|x-x.median()|)/MAD
        '''
        diff = abs(s-s.median())
        return 0.6745*diff/diff.median() > threshold
