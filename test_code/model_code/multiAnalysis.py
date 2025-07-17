# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
from model import Models
import matplotlib.pyplot as plt
from commonTools import CommonTool


class corr_factory(object):
    @staticmethod
    def corr_group(data, corr_ratio):
        result = []  # 存放 强相关变量组，强相关变量：变量间相关系数大于 corr_ratio
        already_in = set()  # 已加入强相关变量组的变量
        corrMatrix = data.astype('float32').corr()
        corrMatrix.loc[:, :] = np.tril(corrMatrix, k=-1)  # 不含对角线 下三角矩阵

        for col in corrMatrix.columns:  # 按列进行比较
            corr_vars = corrMatrix.loc[abs(
                # 变量col 的强相关变量 list
                corrMatrix[col]) > corr_ratio, col].index.tolist()
            if corr_vars and col not in already_in:  # 如果变量存在于某一强相关变量组，则跳过
                # 当前变量的强相关变量 已经存在于其他变量组的变量
                exist_corr_vars = [i for i in corr_vars if i in already_in]

                if exist_corr_vars:
                    # 当前变量的最强相关变量
                    max_corr_var = corrMatrix.loc[exist_corr_vars, col].idxmax(
                    )
                    for l in range(0, len(result)):  # 遍历 当前强相关变量组
                        if max_corr_var in result[l]:
                            result[l].append(col)  # 如果变量在某一组中，将当前变量加入该组
                            already_in.update(col)
                else:
                    already_in.update(set(corr_vars))
                    corr_vars.append(col)
                    result.append(corr_vars)

        return result

    @staticmethod
    def corr_reduce_iv(corr_group, df_miss, uni_table, data, corr_ratio):
        corr_group_lst = corr_group(data, corr_ratio)
        while corr_group_lst:
            corr_group_vars = corr_group_lst[0]
            cgv_iv_df = uni_table.loc[corr_group_vars, ['Iv', 'Iv_rank']]
            cgv_miss_df = df_miss.loc[corr_group_vars, [
                'missNum', 'missRatio', 'type']]
            print('强相关变量组:\n', pd.concat([cgv_iv_df, cgv_miss_df], axis=1))
            corr_vars_iv = uni_table.loc[corr_group_vars, 'Iv']
            drop_colums = corr_vars_iv.drop(corr_vars_iv.sort_values(
                # 删除 强相关变量组 中 iv 最高的变量，将剩余变量删除
                ascending=False).head(1).index).index
            print('删除列:', drop_colums, end='\n\n')
            # 删除强相关变量组内 除iv值最高的其余所有变量，并重新计算 强相关变量组
            data.drop(drop_colums, axis=1, inplace=True)
            corr_group_lst = corr_group(data, corr_ratio)
        return data  # 返回 强相关变量数据集


class Multiple(CommonTool):
    """
    多变量分析

    Parameters
    ----------
    data:需要计算的数据集(已经离散化的DataFrame)
    target:标识列(Series)
    columns(默认'ALL'):需要计算的列(包含列名的list)
    ignore_columns(默认None):需要忽略的列(包含列名的list)
                            会在计算时忽略
    class_weight(默认'balanced'):样本中响应与未响应样本占比,{class_label: weight}
                                如需提高响应或者非响应的权重,可以{0:0.3,1:0.7}

    Examples
    --------
    >>>import ScoreCardBox as scb
    >>>mul=scb.mul(df,df.flag,['userid','flag])
    >>>after_cor=mul.corr_reduce_pp(uni_table,corr_ratio=0.8)

    >>>result_table=mul.multi_analysis_table(n_features_to_select=15,step=5)
    >>>after_mul=mul.multi_reduce(result_table)
    """

    def __init__(self, df, target, ignore_columns=None, class_weight='balanced'):
        super(Multiple, self).__init__(df, target, ignore_columns)
        self.class_weight = class_weight

    def corr_reduce(self, df_miss, uni_table, corr_ratio=0.7, group_vars=None):
        """
        将相关性大于 corr_ratio 的两个变量放在一组里,取组内iv值 top1 变量

        Parameters
        ----------
        uni_table:单变量分析表(包含Iv值)
        corr_ratio(默认为0.7):相关系数的阈值,大于此值的两个变量将被置为一组
        group_vars(默认None): 在计算相关系数时，多少个变量一起计算相关矩阵，默认所有变量进行计算
        """
        job_dt = {}
        cor_data = pd.DataFrame()
        ins = corr_factory()

        if group_vars is None:
            job_dt[0] = ins.corr_reduce_iv(
                ins.corr_group, df_miss, uni_table, self.df, corr_ratio)
        else:
            for i in range(0, self.df.shape[1], group_vars):
                df_sub = self.df.iloc[:, i:i+group_vars]
                job_dt[i] = ins.corr_reduce_iv(
                    ins.corr_group, df_miss, uni_table, df_sub, corr_ratio)

        for i, df_sub in job_dt.items():
            cor_data = pd.concat([cor_data, df_sub], axis=1)
            print('done {}'.format(i))
        self.df = cor_data.copy()
        if self.ignore_columns:
            cor_data = self.recover_func(cor_data)
        return cor_data

    def multi_analysis_table(self, n_features_to_select, n_KFold=3, cv_scoring='roc_auc', rl=False,
                             sample_fraction=0.75, selection_threshold=0.25, step=1):
        """
        多变量分析表格,采用三种方法:
        1.RFE 逐步回归
        2.RFECV 带交叉验证的逐步回归
        3.RL  变量稳定性检验,多次随机抽样建模,观察top n个变量进入模型的次数

        Parameters
        ----------
        n_features_to_select:逐步回归中需要选择的最终变量个数
        n_KFold(默认为3):交叉验证中的验证样本比例
        cv_scoring(默认为roc_auc):交叉验证中的评判标准
        rl(默认为True):是否进行稳定性检验
        sample_fraction(默认为0.75):每次随机抽样占总样本的比例
        selection_threshold(默认为0.25):top百分之多少的变量入选
        step(默认为1):逐步回归中每步筛选的变量数
        """
        ins = Models(self.df, self.target, class_weight=self.class_weight)
        rfe_rank = self._make_dataframe(
            self.RFE(ins, n_features_to_select, step), 'rfe')
        print('rfe success')
        rfecv_rank = self._make_dataframe(
            self.RFECV(ins, n_KFold, cv_scoring), 'rfecv')
        print('rfecv success')
        result_list = [rfe_rank, rfecv_rank]
        if rl:
            rl_rank = self._make_dataframe(
                self.rfecv(ins, sample_fraction, selection_threshold), 'rl')
            result_list.append(rl_rank)
            print('rl success')
        result_table = pd.concat(result_list, axis=1)
        return result_table

    def _make_dataframe(self, value, col):
        return pd.DataFrame(value, columns=[col, 'columns'])

    def __sorted(self, model):
        return sorted(zip(map(lambda x: round(x, 4), model), self.df.columns))

    def RFE(self, ins, n_features_to_select, step):
        # 递归特征消除 (Recursive Feature Elimination)
        rfe_model = ins.rfe(
            n_features_to_select=n_features_to_select, step=step)
        return self.__sorted(rfe_model.ranking_)

    def RFECV(self, ins, n_KFold, cv_scoring):
        rfecv_model = ins.rfecv(n_KFold=n_KFold, cv_scoring=cv_scoring)
        plt.xlabel("Number of features selected")
        plt.ylabel("Scoring: %s" % (cv_scoring))
        plt.plot(range(1, len(rfecv_model.cv_results_['mean_test_score']) + 1),
                 rfecv_model.cv_results_['mean_test_score'])
        return self.__sorted(rfecv_model.ranking_)

    def RL(self, ins, sample_fraction, selection_threshold):
        rlr_model = ins.randlogistic(
            selection_threshold=selection_threshold, sample_fraction=sample_fraction)
        return self.__sorted(rlr_model.scores_)

    def multi_reduce(self, result_table, rl_ratio=0.95):
        """
        根据多变量筛选表格筛选变量
        只有RFE和RFECV以及RL三种都入选的变量才能最终入选

        Parameters
        ----------
        result_table:多变量分析表格
        rl_ratio(默认为0.95):变量稳定性检验中大于此值的变量最终入选

        """
        spl = len(result_table.columns)
        stay_list = []
        stay_set = set()
        for i in range(0, spl, 2):
            temp_table = result_table.iloc[:, i:i+2]
            if 'rl' in temp_table.columns:
                stay_list.append(
                    set(temp_table[temp_table.iloc[:, 0] >= rl_ratio]['columns'].values))
            else:
                stay_list.append(
                    set(temp_table[temp_table.iloc[:, 0] == 1]['columns'].values))
        for s in stay_list:
            if stay_set:
                stay_set = stay_set & s  # 取三者交集
            else:
                stay_set = s
        ret_data = self.df[list(stay_set)]
        if self.ignore_columns:
            ret_data = self.recover_func(ret_data)
        return ret_data, list(stay_set)
