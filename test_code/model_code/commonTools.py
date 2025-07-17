# -*- coding: utf-8 -*-
"""
公用工具模块
"""
import pandas as pd
import numpy as np
from scipy.stats import chisquare


class CommonTool(object):
    """
    docstring for CommonTool--公用工具模块
    """

    def __init__(self, df, target, ignore_columns):
        self.df = df.copy()
        self.target = target
        self.ignore_columns = ignore_columns  # 不需要处理的列

        if ignore_columns:
            self.ignore_func()

    def ignore_func(self):
        self.recover = self.df[self.ignore_columns]  # 忽略的列
        self.df.drop(self.ignore_columns, axis=1, inplace=True)

    def recover_func(self, df=None):
        if df is None:
            return pd.concat([self.recover, self.df], axis=1)
        else:
            return pd.concat([self.recover, df], axis=1)


class EdaMethod(object):
    """
    计算数据框每一列的相关指标
    卡方检验、信息增益、iv值等
    """

    def __init__(self, Series):
        self.Series = Series

    def basicInfo(self):
        return pd.Series([self.topNp(1), self.topNp(3), self.uniqueValue()], index=['top1p', 'top3p', 'uniqueNum'])

    def topNp(self, n=3):
        s = self.Series.value_counts()
        return sum(s.iloc[:n])*1.0/sum(s)  # 耗时一两个小时

    def uniqueValue(self):
        return len(np.unique(self.Series))

    def UnFeatureSelection(self, y):
        return pd.Series([self.Chi2Computing(y), self.GainComputing(y), self.IvComputing(y)], index=['chi2pvalue', 'gain', 'iv'])

    def Chi2Computing(self, y):
        def chisquarePvalue(observed, expected):
            return chisquare(observed, expected)[1]

        def binarystats(y):
            # 返回 1、0 的取值个数
            btotal, gtotal = (len(y[y == value]) for value in [1, 0])
            return btotal, gtotal

        def Chi2(x, y):
            '''
            y need to be binary
            '''
            bitotal, gitotal = binarystats(x)  # 实际值

            btotal, gtotal = binarystats(y)  # 期望值
            extotal = (bitotal+gitotal)*1.0/totalrows*btotal  # 类别占比*期望值
            acttotal = bitotal
            return pd.Series([extotal, acttotal], index=['extotal', 'acttotal'])

        y = pd.Series(y)
        totalrows = len(self.Series)
        s1 = self.Series.reset_index(drop=True)
        s2 = y.reset_index(drop=True)
        df = pd.concat([s1, s2], axis=1)
        df.columns = ['a', 'b']
        # 关于 a 的每个分组计算和 y 的1、0 占比.x代表相应分组的y
        gby = df.groupby('a', observed=True)['b'].apply(
            lambda x: Chi2(x, y)).unstack()
        return chisquarePvalue(gby['acttotal'], gby['extotal'])

    def GainComputing(self, y):
        y = pd.Series(y)

        def GainValue(x):
            p = x.value_counts()*1.00/len(x)
            return sum(p*(-1)*np.log2(p))

        s1 = self.Series.reset_index(drop=True)
        s2 = y.reset_index(drop=True)
        df = pd.concat([s1, s2], axis=1)
        df.columns = ['x', 'y']
        s3 = df.groupby('x', observed=True)['y'].apply(GainValue)
        s4 = df.groupby('x', observed=True)['y'].apply(len)
        return GainValue(y)-sum(s3*s4)/sum(s4)  # sum(p*H(y|x))

    def IvComputing(self, y):
        y = pd.Series(y)

        def ivvalue(x, y):
            '''
            y need to be binary
            '''
            def binarystats(y):
                btotal, gtotal = (len(y[y == value]) for value in [1, 0])
                return btotal, gtotal
            bitotal, gitotal = binarystats(x)
            if bitotal == 0 or gitotal == 0:
                return 99
            btotal, gtotal = binarystats(y)

            WoeWgt = (bitotal*1.0/btotal)-(gitotal*1.0/gtotal)  # 坏样本占比-好样本占比
            woe = np.log((bitotal*1.0/btotal)/(gitotal*1.0/gtotal))
            return WoeWgt*woe

        s1 = self.Series.reset_index(drop=True)
        s2 = y.reset_index(drop=True)
        df = pd.concat([s1, s2], axis=1)
        df.columns = ['a', 'b']
        s1 = df.groupby('a', observed=True)['b'].aggregate(lambda x: ivvalue(x, y))
        return sum(s1)

    def pattern(self):
        # 判断序列是否单调
        b = list(self.Series)
        s_b_asc = sorted(b, reverse=False)
        s_b_desc = sorted(b, reverse=True)
        if b == s_b_asc:
            return 1  # woe 单增
        elif b == s_b_desc:
            return 2  # woe 单减
        else:
            return 3  # 非单调

    def woecheck(self):
        # 将当前实例的 Series 转换为列表，方便后续操作
        b = list(self.Series)
        # 调用 pattern 方法判断序列是否单调，并获取判断结果
        result = self.pattern()
        # 如果序列是单调递增（结果为 1）或单调递减（结果为 2）
        if result in [1, 2]:
            # 直接返回单调类型的结果
            return result
        # 获取列表中的最大值
        b_max = max(b)
        # 获取列表中的最小值
        b_min = min(b)
        # 获取最大值在列表中的索引
        b_max_index = b.index(b_max)
        # 获取最小值在列表中的索引
        b_min_index = b.index(b_min)
        # 检查最大值索引是否在列表范围内，且前半部分单调递增，后半部分单调递减
        if b_max_index < len(b) and (EdaMethod(b[0:b_max_index+1]).pattern() == 1) and (EdaMethod(b[b_max_index:]).pattern() == 2):
            # 符合条件则判定为倒 U 型，返回 3
            return 3  # 倒 U 型
        # 检查最小值索引是否在列表范围内，且前半部分单调递减，后半部分单调递增
        if b_min_index < len(b) and (EdaMethod(b[0:b_min_index+1]).pattern() == 2) and (EdaMethod(b[b_min_index:]).pattern() == 1):
            # 符合条件则判定为 U 型，返回 4
            return 4  # U 型
        # 若都不符合上述条件，返回 99 表示其他情况
        return 99


class Discretizated(EdaMethod):
    def __init__(self, s1):
        super(Discretizated, self).__init__(s1)

    def patterncheck(self, UniqueLevels_limit=10, mostfreq_ratio_limit=0.8):
        """
        根据唯一值数量和最频繁值的占比来检查模式类型。

        :param UniqueLevels_limit: 唯一值数量的阈值，默认为 10。
        :param mostfreq_ratio_limit: 最频繁值占比的阈值，默认为 0.8。
        :return: 模式类型，1 表示最频繁值占比超过阈值，2 表示唯一值数量不超过阈值，3 表示其他情况。
        """
        # 调用 uniqueValue 方法获取当前 Series 的唯一值数量
        UniqueLevels = self.uniqueValue()
        # 调用 topNp 方法获取当前 Series 中最频繁值的占比
        mostfreq_ratio = self.topNp(1)
        # 若最频繁值的占比大于等于设定的阈值
        if mostfreq_ratio >= mostfreq_ratio_limit:
            # 返回模式类型 1
            return 1
        # 若唯一值数量小于等于设定的阈值
        elif UniqueLevels <= UniqueLevels_limit:
            # 返回模式类型 2
            return 2
        else:
            return 3

    def digitize_1(self):
        value = self.UserMod()
        self.Series[self.Series != value] = value+1
        return self.Series

    def digitize_2(self):
        return self.Series

    def digitize_3(self, binrange):
        bins = np.array(np.percentile(self.Series, binrange))
        bins = np.sort(list(set(np.round(bins.tolist(), 3))))
        return np.digitize(self.Series, bins, right=True)+1

    def digitize_3_plus(self, bins):
        return np.digitize(self.Series, bins, right=True)+1

    def digitize(self, binrange):
        if self.patterncheck() == 1:
            return self.digitize_1()
        elif self.patterncheck() == 2:
            return self.digitize_2()
        else:
            return self.digitize_3(binrange)

    def bininfo(self, binrange):
        bins = np.array(np.percentile(self.Series, binrange))
        bins = np.sort(list(set(np.round(bins.tolist(), 3))))
        return bins

    def WoeTransform(self, y):
        def WoeValue(x, y):
            '''
            y need to be binary
            '''
            def binarystats(y):
                btotal, gtotal = (len(y[y == value]) for value in [1, 0])
                return btotal, gtotal
            bitotal, gitotal = binarystats(x)
            if bitotal == 0:
                return -3.0
            if gitotal == 0:
                return 3.0
            btotal, gtotal = binarystats(y)
            woe = np.log((bitotal*1.0/btotal)/(gitotal*1.0/gtotal))
            return woe

        def transfunc(x):
            return WoeValue(x, y)

        s1 = self.Series.reset_index(drop=True)
        s2 = y.reset_index(drop=True)
        df = pd.concat([s1, s2], axis=1)
        df.columns = ['a', 'b']
        # df=pd.DataFrame([self.Series,pd.Series(y)]).T
        # df.columns=['a','b']
        grouped = df.groupby('a', observed=True)['b']
        woearray = grouped.transform(transfunc)
        woeinfo = {name: transfunc(group) for name, group in grouped}
        return woearray, woeinfo
