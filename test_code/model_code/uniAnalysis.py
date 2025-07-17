# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib
# matplotlib.style.use('ggplot')
import random
from commonTools import CommonTool
from commonTools import EdaMethod
import weightOfEvidence as woe


class Univariable(CommonTool):
    """
    单变量分析

    Parameters
    ----------
    *data:需要计算的数据集
    target:标识列(Series)
    ignore_columns(默认None):需要忽略的列(包含列名的list) 会在计算时忽略

    cal_iv(默认为False):是否计算iv

    Examples
    --------
    >>>import ScoreCardBox as scb
    >>>uni=scb.uni(train,train.flag,['userid', 'bankid', 'flag'])
       #如无target列，可以不传

    >>>uni.plot_outlier()#随机抽取sample_num(默认为5)个变量绘制分布图

    >>>uni.plot_outlier_single('bankcashbal_9_avg')#查看单个变量的分布、异常值

    >>>uni.overview#查看变量的单变量统计表（存在target列的情况下会计算iv）

    >>>after_uni=uni.select('iv>0.02 & is_float==1 & top1p<0.9')#根据单变量统计表,输入条件筛选列

    """

    def __init__(self, df, target, ignore_columns=None, cal_iv=False):
        super(Univariable, self).__init__(df, target, ignore_columns)
        self.cal_iv = cal_iv
        if cal_iv is False:
            print("can't caculate iv because of cal_iv is False")

    @property
    def overview(self):
        df_t = self.df.apply(lambda x: EdaMethod(x).basicInfo()).T
        df_t['uniqueRatio'] = df_t['uniqueNum']*1.0/len(self.df)
        if self.cal_iv is False:
            self.uni_table = df_t
            return df_t
        else:
            iv_df = self.analysis_table()
            self.uni_table = iv_df.join(df_t)  # 会根据 index 进行关联
            return self.uni_table

    def analysis_table(self):
        if isinstance(self.df, pd.DataFrame):
            ins = woe.Woe_dataframe(self.df, self.target)
            iv = ins.get_iv
            self.woe = ins.get_woe
            self.table = ins.get_table
            self.woe_transformed = ins.woe_transform(self.woe)
            iv_df = pd.DataFrame(
                list(iv.values()), index=iv.keys(), columns=['Iv'])
        else:
            print('data is not DataFrame!~~')

        iv_df = iv_df.sort_values('Iv', ascending=False)
        iv_df['Iv_rank'] = iv_df.rank(ascending=False)
        return iv_df

    def select(self, condition):
        '''
        Parameters
        ----------
        condition(字符串): 且: and 或者 & 或: or 或者 |
        '''
        drop_col = self.uni_table[~self.uni_table.eval(condition)].index.values
        after_drop_df = self.df.drop(drop_col, axis=1)
        if self.ignore_columns:
            # 获得 woe 转换的数据集
            self.woe_transformed = self.woe_transformed[after_drop_df.columns]
            after_drop_df = self.recover_func(
                after_drop_df)  # 获得根据 iv 筛选后，离散化后 数据框
        return after_drop_df

    @property
    def get_woe_transformed(self):
        if self.ignore_columns:
            woe_transformed = self.recover_func(self.woe_transformed)
        return woe_transformed
