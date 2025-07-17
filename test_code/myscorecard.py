# -*- coding: utf-8 -*-
# 评分卡建模类
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor


class dataProcess():
    '''
    评分卡建模类
    1. 数据探索
    2. 数据处理
    '''
    def __init__(self, df, target):
        self.df = df.copy()
        self.target = target

    def overview(self):
        '''
        1. 数据探索 根据数据框df,生成单变量分析表
            1. 数据类型,非空个数、均值、标准差、最小值、中位数、最大值
            2. 唯一值个数,异常值个数,异常值占比、缺失率,Top1占比,Top3占比
            3. 唯一值个数占比,异常值个数占比
        '''
        # 基础统计信息
        basic_stats = self.df.describe(include='all').T
        basic_stats['dtype'] = self.df.dtypes
        basic_stats['non_null_count'] = self.df.notnull().sum()

        # 计算唯一值相关信息
        def calculate_top_n_percentage(series, n):
            value_counts = series.value_counts()
            if len(value_counts) == 0:
                return 0
            top_n_sum = value_counts.head(n).sum()
            total_sum = value_counts.sum()
            return top_n_sum / total_sum

        unique_stats = self.df.apply(lambda x: pd.Series({
            'unique_num': x.nunique(),
            'top1p': calculate_top_n_percentage(x, 1),
            'top3p': calculate_top_n_percentage(x, 3)
        }))

        # 计算缺失率
        missing_stats = self.df.isnull().mean().rename('missing_rate')

        # 计算异常值（这里简单假设上下四分位距外的值为异常值）
        def calculate_outliers(col):
            '''
            基于箱线图的异常值检测,不限制数据分布,鲁棒性更强
            '''
            if pd.api.types.is_numeric_dtype(col):
                q1 = col.quantile(0.25)
                q3 = col.quantile(0.75)
                iqr = q3 - q1
                lower_bound = q1 - 1.5 * iqr
                upper_bound = q3 + 1.5 * iqr
                outlier_count = ((col < lower_bound) | (col > upper_bound)).sum()
                return outlier_count
            return 0

        outlier_stats = self.df.apply(lambda col: pd.Series(calculate_outliers(col), index=['outlier_count']))

        # 合并所有统计信息
        analysis_table = pd.concat([
            basic_stats[['dtype', 'non_null_count', 'mean', 'std', 'min', '50%', 'max']],
            unique_stats,
            outlier_stats,
            missing_stats
        ], axis=1)

        # 计算唯一值个数占比和异常值个数占比
        analysis_table['unique_rate'] = analysis_table['unique_num'] / len(self.df)
        analysis_table['outlier_num_rate'] = analysis_table['outlier_count'] / len(self.df)

        # 重命名列
        analysis_table = analysis_table.rename(columns={
            '50%': 'median',
        })
        return analysis_table

    def data_process(self):
        '''
        1. 删除唯一值为1的变量
        2. 离散缺失值填充:object类型用unknown填充,
        3. 离散变量编码:object类型变量根据计算的woe升序编码,生成编码字典trans_dict
        4. 重新计算变量缺失率
            4.1 数值型根据缺失率80%以上的构造0-1变量,删除原始变量
            4.2 缺失率50-80%之间的变量,构造0-1变量,保留原始变量
            4.3 缺失率80%以下的用模型填充,构建用其余缺失率20%以下的变量,删除缺失记录的随机森林模型填充
        5. top1>0.8 的 0-1编码,删除原始变量
        '''
        # 1. 删除唯一值为1的变量
        unique_counts = self.df.nunique()
        cols_to_drop = unique_counts[unique_counts == 1].index
        self.df = self.df.drop(columns=cols_to_drop)

        # 2. 离散缺失值填充:object类型用unknown填充
        object_cols = self.df.select_dtypes(include=['object']).columns
        self.df[object_cols] = self.df[object_cols].fillna('unknown')

        # 3. 离散变量编码:object类型变量根据计算的woe升序编码,生成编码字典 trans_dict
        trans_dict = {}
        for col in object_cols:
            woe_dict = self.calculate_woe(self.df[col], self.df[self.target])
            sorted_woe = sorted(woe_dict.items(), key=lambda x: x[1])
            encoding_dict = {key: idx for idx, (key, _) in enumerate(sorted_woe)}
            self.df[col] = self.df[col].map(encoding_dict)
            trans_dict[col] = encoding_dict

        # 4. 重新计算变量缺失率
        missing_rate = self.df.isnull().mean()

        # 4.1 数值型根据缺失率80%及以上的构造one-hot变量,删除原始变量
        high_missing_num_cols = missing_rate[(missing_rate >= 0.8) & (self.df.dtypes != 'object')].index
        for col in high_missing_num_cols:
            self.df[col + '_missing'] = self.df[col].isnull().astype(int)
            self.df = self.df.drop(columns=[col])

        # 4.2 缺失率50-80%之间的变量,构造one-hot变量,保留原始变量
        medium_missing_cols = missing_rate[(missing_rate >= 0.5) & (missing_rate < 0.8)].index
        for col in medium_missing_cols:
            self.df[col + '_missing'] = self.df[col].isnull().astype(int)

        # 4.3 缺失率80%以下的用模型填充,构建用其余缺失率20%以下的变量,删除缺失记录的随机森林模型填充
        low_missing_cols = missing_rate[missing_rate < 0.8].index
        for col in low_missing_cols:
            if self.df[col].isnull().any():
                # 选择缺失率20%以下的变量作为特征
                features = missing_rate[missing_rate < 0.2].index.drop(col) # 排除当前正在处理的列 col
                df_train = self.df.dropna(subset=[col]) # 删除col缺失值的记录
                X_train = df_train[features]
                y_train = df_train[col]
                model = RandomForestRegressor(n_estimators=20, max_depth=4, min_samples_split=5
                                              , min_samples_leaf=2, max_features='auto')
                model.fit(X_train, y_train)
                df_missing = self.df[self.df[col].isnull()]
                X_missing = df_missing[features]
                self.df.loc[self.df[col].isnull(), col] = model.predict(X_missing)

        # 5. top1>=0.8 的 0-1编码,删除原始变量
        def calculate_top1_percentage(series):
            value_counts = series.value_counts()
            if len(value_counts) == 0:
                return 0
            top1_sum = value_counts.head(1).sum()
            total_sum = value_counts.sum()
            return top1_sum / total_sum

        top1_percentages = self.df.apply(calculate_top1_percentage)
        high_top1_cols = top1_percentages[top1_percentages >= 0.8].index
        for col in high_top1_cols:
            top1_value = self.df[col].value_counts().index[0]
            self.df[col + '_binary'] = (self.df[col] == top1_value).astype(int)
            self.df = self.df.drop(columns=[col])

        return self.df, trans_dict

    def calculate_woe(self, feature, target):
        """
        计算 WOE 值
        """
        df = pd.DataFrame({'feature': feature, 'target': target})
        woe_dict = {}
        for category in df['feature'].unique():
            events = df[(df['feature'] == category) & (df['target'] == 1)].shape[0]
            non_events = df[(df['feature'] == category) & (df['target'] == 0)].shape[0]
            total_events = df[df['target'] == 1].shape[0]
            total_non_events = df[df['target'] == 0].shape[0]
            if events == 0:
                events = 0.5
            if non_events == 0:
                non_events = 0.5
            woe = np.log((events / total_events) / (non_events / total_non_events))
            woe_dict[category] = woe
        return woe_dict



class modelTrain():
    '''
    模型训练类
    1. 模型训练
    2. 模型评估
    3. 模型保存
    '''
    pass


class model_predict():
    '''
    模型加载类
    1. 模型加载
    2. 模型预测
    3. 模型评分
    '''
    pass