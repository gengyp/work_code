# coding:utf-8
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from commonTools import CommonTool


class Sample(CommonTool):
    """
    抽样类

    Parameters
    ----------
    df:需要计算的数据集(DataFrame)
    target:标识列(Series),取值(0,1) 标识列中 1 代表响应
    pct_train(默认0.8):训练样本占比(0<x<1之间numeric)
    class_weight(默认'balanced'):样本中响应与未响应样本占比('balanced' or 'orignal' or dict)
                'balanced':自动平衡为1:1
                'orignal': 保持原始比例
                {'res':x,'non_res':y}: dict x,y为指定响应/未响应比例
    Examples
    --------
    >>>import ScoreCardBox as scb
    >>>sam=scb.sample(df,df.flag,0.85,{'res':1,'non_res':3})
    >>>sam
    ------------------------
    df shape:
    rows:88262
    columns:386

    orignal weight:
    res:1.0
    non_res:5.0
    ------------------------
    >>>train=sam.train
    >>>test=sam.test
    """

    def __init__(self, df, target, ignore_columns=None, pct_train=0.75, class_weight='balanced'):
        super(Sample, self).__init__(df, target, ignore_columns)
        self.pct_train = pct_train
        self.class_weight = class_weight
        self.train_test_split()

    def train_test_split(self):
        df = self.__resample()
        self.train, self.test = train_test_split(
            df, train_size=self.pct_train, test_size=1 - self.pct_train)
        print('train size:\t{}'.format(self.train.shape))
        print('test size:\t{}'.format(self.test.shape))

    def __resample(self):
        # 根据输入比例 重置正负样本比例
        df_non_response = self.df[self.target == 0]
        df_response = self.df[self.target == 1]

        df_dict = {'res': df_response, 'non_res': df_non_response}

        weight = len(df_non_response) * 1.0 / len(df_response)  # 0/1 好坏比
        if weight >= 1:  # 好 > 坏
            ori_weight = {'non_res': np.round(weight), 'res': 1.0}
        else:
            ori_weight = {'non_res': 1.0, 'res': np.round(1.0 / weight)}
        self.ori_weight = ori_weight  # round 取整后，为整数比

        if isinstance(self.class_weight, dict):
            result = []
            for key in self.class_weight.keys():
                target_size = int(len(df_dict[key]) * (self.class_weight[key] / ori_weight[key]))
                if self.class_weight[key] > ori_weight[key]:
                    # 过采样
                    result.append(df_dict[key].sample(n=target_size, replace=True))
                elif self.class_weight[key] < ori_weight[key]:
                    # 欠采样
                    result.append(df_dict[key].sample(n=target_size, replace=False))
                else:
                    result.append(df_dict[key])
            return pd.concat(result, axis=0)

        elif self.class_weight == 'balanced' and ori_weight['non_res'] != ori_weight['res']:
            # 将样本比例较多的，随机抽样到 和比例较少的样本数量,欠采样
            inverse = [key for key, value in ori_weight.items() if value != 1.0][0]
            min_size = min(len(df_dict['res']), len(df_dict['non_res']))
            sub_sample = df_dict[inverse].sample(n=min_size, replace=False)
            keys = list(ori_weight.keys())
            keys.pop(keys.index(inverse))
            return pd.concat([df_dict[keys[0]], sub_sample], axis=0)
        else:
            return self.df

    def __repr__(self):
        return 'df shape:\t{}\norignal weight:\t{}'.format(self.df.shape, self.ori_weight)