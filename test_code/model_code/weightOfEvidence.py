# -*- coding: utf-8 -*-


"""
WOE值与IV值
"""
import numpy as np
import pandas as pd
from commonTools import CommonTool
# import pp


class Woe(object):
    """
    单列WOE与IV值的计算类
    """

    def __init__(self, series, target):
        self.series = series
        self.target = target
        self.__max_woe = 3
        self.__min_woe = -3

        self.woe_iv(self.series, self.target)

    def woe_iv(self, series, flag):
        table = self.woe_table(series, flag)
        try:
            response_total = table['response'].sum()
            non_response_total = table['non_response'].sum()
            table['woe'] = table.apply(lambda x: self.woe_calculate(
                x, non_response_total, response_total), axis=1)
            table['iv'] = (table['response']/response_total -
                           table['non_response']/non_response_total)*table.woe
        except:
            table['woe'] = 0
            table['iv'] = 99.0/len(table.index)
        self.table = table

    def woe_calculate(self, table, non_response_total, response_total):
        response = table['response']
        non_response = table['non_response']
        if non_response == 0:
            return self.__max_woe
        elif response == 0:
            return self.__min_woe
        else:
            # 坏好比,自然对数
            return round(np.log((response*1.0/response_total)/(non_response*1.0/non_response_total)), 4)

    def woe_table(self, series, flag):
        one = pd.Series(1, index=series.index)
        _g = pd.concat([series, flag, one], axis=1)
        table = _g.groupby([series.name, flag.name]
                           ).sum().unstack()  # 计算分组后，0,1 样本数

        if len(table.columns) == 1:
            print('error!~~')
            # table.columns=[response_dict[1][flag.values[0]]]
        else:
            table.columns = [0, 1]
            table.rename(columns={0: 'non_response',
                         1: 'response'}, inplace=True)
        table.fillna(0, inplace=True)
        return table

    @property
    def woe(self):
        return self.table.woe

    @property
    def iv(self):
        return round(sum(self.table.iv), 4)

    @property
    def max_woe(self):
        return self.__max_woe

    @max_woe.setter
    def max_woe(self, max_woe):
        self.__max_woe = max_woe
        self.woe_iv(self.series, self.target)

    @property
    def min_woe(self):
        return self.__min_woe

    @min_woe.setter
    def min_woe(self, min_woe):
        self.__min_woe = min_woe
        self.woe_iv(self.series, self.target)


class Woe_dataframe(CommonTool):
    """
    多列WOE与IV值计算类

    Parameters
    ----------
    data:需要计算的数据集(已经离散化的DataFrame)
    target:标识列(Series)
    columns(默认'ALL'):需要计算的列(包含列名的list)
    ignore_columns(默认None):需要忽略的列(包含列名的list)
                            会在计算时忽略
    response(默认1):响应变量取值(0,1)
            1: 标识列中1代表响应
            0: 标识列中0代表响应

    Examples
    --------
    >>>import ScoreCardBox as scb
    >>>woe=scb.woe(df,df.flag,['userid','flag])
    >>>income=woe['bankincome_8_avg']#查看单个变量
       woe:
       bankincome_8_avg
       0   -1.8072
       1   -0.2686
       2    0.1454
       3    0.1796
       4    0.2173
       5    0.0416
       Name: woe, dtype: float64
       ----------------
       iv:
       0.1447
       ----------------
       table:
                            0     1     woe        iv
       bankincome_8_avg
       0                  975   500 -1.8072  0.111876
       1                 2770  6617 -0.2686  0.013310
       2                 2354  8507  0.1454  0.004070
       3                 2291  8567  0.1796  0.006148
       4                 2224  8636  0.2173  0.008909
       5                 2551  8310  0.0416  0.000343
    >>>woe_dict=income.get_woe#查看所有变量woe字典
    >>>iv_dict=income.get_iv#查看所有变量iv字典
    >>>table_dict=income.get_table#查看所有变量分析表字典
    """

    def __init__(self, data, target, ignore_columns=None, caculate=True):
        super(Woe_dataframe, self).__init__(data, target, ignore_columns)
        if caculate:
            self.caculate()

    def caculate(self):
        self._iv_dict = {}      # 存放 每个变量的 iv
        self._table_dict = {}   # 存放 每个变量的 分组 non_response response  woe iv
        self._woe_dict = {}     # 存放 每个变量的 分组 woe,用于转换数据集

        for i in self.df.columns:
            _ins = Woe(self.df[i], self.target)
            self._woe_dict[i] = _ins.woe
            self._iv_dict[i] = _ins.iv
            self._table_dict[i] = _ins.table

    @property
    def get_woe(self):
        return self._woe_dict

    @property
    def get_iv(self):
        return self._iv_dict

    @property
    def get_table(self):
        return self._table_dict

    def __getitem__(self, key):
        try:
            _woe = self._woe_dict[key]
            _iv = self._iv_dict[key]
            _table = self._table_dict[key]
        except:
            raise ValueError('column %s does not exist' % key)
        print('woe:\n{}'.format(_woe))
        print('----------------')
        print('iv:\n{}'.format(_iv))
        print('----------------')
        print('table:\n{}'.format(_table))
        single_dict = {'woe': _woe, 'iv': _iv, 'table': _table}
        return single_dict

    def __repr__(self):
        _min = min(self._iv_dict.items(), key=lambda x: x[1])
        _max = max(self._iv_dict.items(), key=lambda x: x[1])
        return '''columns_length: {} max_iv  {}:{} min_iv  {}:{} '''.format(self.df.shape[1], _max[0], _max[1], _min[0], _min[1])

    def woe_transform(self, woe_dict):
        transform = self.df[list(woe_dict.keys())].apply(
            lambda x: self.trans_func(woe_dict, x), axis=0)
        if self.ignore_columns:
            transform = self.recover_func(transform)
        return transform

    def trans_func(self, woe_dict, series):
        # 从传入的 WOE 字典中获取当前列对应的 WOE 序列
        woe_series = woe_dict[series.name]
        # 从原始数据集中获取当前列的数据
        ori_data = self.df[series.name]
        # 根据原始数据的值从 WOE 序列中选取对应的 WOE 值，得到转换后的序列
        transformed = woe_series.loc[ori_data]
        # 将转换后序列的索引设置为原始数据的索引，保证索引一致
        transformed.index = ori_data.index
        # 返回转换后的序列
        return transformed
