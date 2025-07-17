# -*- coding: utf-8 -*-
# import warnings
# warnings.filterwarnings('ignore')
import pandas as pd
import numpy as np
from sklearn.feature_selection import RFE
from sklearn.feature_selection import RFECV
# from sklearn.cross_validation import StratifiedKFold
from sklearn.model_selection import StratifiedKFold
from sklearn.linear_model import LinearRegression, LogisticRegression
# from sklearn.linear_model import RandomizedLogisticRegression
# from sklearn.grid_search import GridSearchCV
from sklearn.model_selection import GridSearchCV
import joblib
from sklearn.metrics import roc_auc_score
from sklearn.metrics import confusion_matrix, classification_report, accuracy_score

from commonTools import CommonTool
from binTransform import Bin
from weightOfEvidence import Woe_dataframe


class Models(object):
    '''
    models class
    '''

    def __init__(self, data, target, ignore_columns=None, C=0.5, class_weight='balanced'):
        self.df = data.copy()
        self.target = target
        self.C = C
        self.class_weight = class_weight
        self.lr = LogisticRegression(
            penalty='l2', class_weight=class_weight, C=C, random_state=1)

        if ignore_columns:
            self.df.drop(ignore_columns, axis=1, inplace=True)

    def rfe(self, n_features_to_select, step):
        rfe_model = RFE(
            self.lr, n_features_to_select=n_features_to_select, step=step)
        rfe_model.fit(self.df, self.target)
        return rfe_model

    def rfecv(self, cv_scoring='roc_auc', n_KFold=3):
        # rfecv_model=RFECV(estimator=self.lr, step=1, cv=StratifiedKFold(self.target,n_KFold), scoring=cv_scoring,n_jobs=-1)
        rfecv_model = RFECV(estimator=self.lr, step=1, cv=StratifiedKFold(
            n_splits=n_KFold), scoring=cv_scoring, n_jobs=-1)
        rfecv_model.fit(self.df, self.target)
        return rfecv_model

    # def randlogistic(self, selection_threshold=0.25, sample_fraction=0.75):
    #     rlr_model = LogisticRegression(
    #         C=self.C, selection_threshold=selection_threshold, normalize=False, sample_fraction=sample_fraction)
    #     rlr_model.fit(self.df.values, self.target.values)
    #     return rlr_model

    def LR(self, cv_scoring='roc_auc', cv=3):
        estimator = LogisticRegression(
            penalty='l2', class_weight=self.class_weight)
        param_grid = {'C': np.linspace(0.1, 1, 100)}
        grid_search = GridSearchCV(
            estimator=estimator, param_grid=param_grid, scoring=cv_scoring, cv=cv)
        grid_search.fit(self.df, self.target)
        best_parameters = grid_search.best_estimator_.get_params()
        print('GridSearchCV the best estimator is:\n{}'.format(best_parameters))
        lr_model = LogisticRegression(
            penalty='l2', class_weight=self.class_weight, C=best_parameters['C'])
        lr_model.fit(self.df, self.target)
        return lr_model

    def compute_vif_circle(self, data, threshold=5):
        col, max_vif = sorted(self.compute_vif(data).items(),key=lambda x: x[1], reverse=True)[0]
        cols = list(data.columns)
        while max_vif > threshold:
            print('current var:{}\tvif is:{}'.format(col, max_vif))
            cols.pop(cols.index(col))
            t_data = data[cols]
            vif_dt = self.compute_vif(t_data)
            col, max_vif = sorted(
                vif_dt.items(), key=lambda x: x[1], reverse=True)[0]
        return vif_dt

    def compute_vif(self, data):
        '''
        计算VIF (variance inflation factor)
        '''
        vif_dt = {}
        for col in data.columns:
            cols = list(data.columns)
            cols.pop(cols.index(col))
            t_data = data[cols]

            reg = LinearRegression()
            reg.fit(X=t_data, y=data[col])
            r_2 = reg.score(X=t_data, y=data[col])
            vif_dt[col] = round(1/(1 - r_2), 2)
        return vif_dt


class Evaluate(CommonTool):
    """
    模型评估类

    Parameters
    ----------
    data:需要计算的数据集(已经离散化的DataFrame)
    target:标识列(Series)
    fitted_model:拟合好的模型
    ignore_columns(默认None):需要忽略的列(包含列名的list)
                            会在计算时忽略
    Examples
    --------
    >>>import ScoreCardBox as scb
    >>>eva=scb.eva(final_woe,final_woe.flag,lr_model,['userid','bankid','flag'])

    >>>eva.auc  模型auc值

    >>>eva.ks   模型ks值

    >>>eva.coef 模型系数

    >>>train_score=eva.from_p_to_score 转换为得分

    """

    def __init__(self, data, target, fitted_model, ignore_columns=None):
        super(Evaluate, self).__init__(data, target, ignore_columns)
        self.fitted_model = fitted_model

    @property
    def auc(self):
        auc_score = roc_auc_score(
            self.target, self.fitted_model.predict_proba(self.df)[:, 1])
        # print('AUC Value:{}'.format(auc_score))
        return auc_score

    @property
    def ks(self):
        ksvalue = Apply_func.ksvalue(
            self.df.values, self.target.values, self.fitted_model)
        # print('KS Value:{}'.format(ksvalue))
        return ksvalue

    @property
    def acc(self):
        acc = accuracy_score(self.target.values,
                             self.fitted_model.predict(self.df.values))
        # print('Acc Value:{}'.format(acc))
        return acc

    @property
    def report(self):
        ks, auc, acc = self.ks, self.auc, self.acc
        text = classification_report(
            self.target.values, self.fitted_model.predict(self.df.values))
        precision, recall, f1score, bad_num = [
            eval(i) for i in text.split('\n')[3].split()[1:]]
        total_num = eval(text.split('\n')[5].split()[6])
        lst = [ks, auc, acc, precision, recall, f1score,
               bad_num, total_num, bad_num/total_num*1.0]  # 存放评估指标
        print('classification_report:\n{}'.format(text))
        return lst

    @property
    def coef(self):
        df_coef = pd.DataFrame(
            {"columns": list(self.df.columns), "coef": list(self.fitted_model.coef_.T)})
        model_coef = pd.concat(
            [df_coef['columns'], df_coef['coef'].apply(lambda x: round(x[0], 8))], 1)
        return model_coef

    @property
    def from_p_to_score(self):
        score_out, detail_out = Apply_func.fromptoscore(
            self.fitted_model, self.df.values)
        score = pd.DataFrame(score_out, columns=['score'], index=self.df.index)
        detail = pd.DataFrame(detail_out, index=self.df.index).drop(0, 1)
        detail.columns = self.df.columns
        final_df = pd.concat(([score, detail]), axis=1)
        if self.ignore_columns:
            final_df = self.recover_func(final_df)
        return final_df


class Apply_func(object):
    @staticmethod
    def ksvalue(data, target, model):
        prob = model.predict_proba(data)
        y = pd.DataFrame(target, columns=['flag'])
        print('-'*10, 'ks graph', '-'*10)
        list1 = np.digitize(prob[:, 1], np.array(
            [np.percentile(prob[:, 1], x) for x in range(10, 101, 10)]), right=True) + 1
        probpd = pd.DataFrame(np.array(list1), columns=['decimal'])
        resultpd = pd.merge(probpd, y, how='left',
                            left_index=True, right_index=True)
        resultpd_st = resultpd.groupby('decimal', group_keys=False)[
            'flag'].apply(lambda x:pd.Series(x).value_counts()).unstack()
        resultpd_st2 = resultpd_st.apply(
            lambda x: x*1.0/x.sum(), axis=0).apply(np.cumsum, axis=0)
        resultpd_st2.columns = ['normal', 'dlq']
        resultpd_st2.plot()
        return abs(resultpd_st2['dlq']-resultpd_st2['normal']).max()

    @staticmethod
    def fromptoscore(model, data, A=540.6843, B=86.5617):
        constant = np.array([1]*data.shape[0]).reshape(-1, 1)
        X_new = np.column_stack((constant, data)).astype('float64')
        coef_new = np.column_stack(
            (A-B*(model.intercept_), -B*(model.coef_))).astype('float64').T
        detail = np.zeros(X_new.shape)  # 用户得分矩阵
        for i in range(len(X_new)):
            for k in range(len(coef_new)):
                detail[i][k] = X_new[i][k]*coef_new[k]
        return np.dot(X_new, coef_new), detail

    @staticmethod
    def save(bin_dictionary, woe_dict, model, path):
        """
        模型保存模块:

        Parameters
        ----------
        bin_dictionary: bin.bin_info
        woe_dict:       woe.get_woe
        table:          woe.get_table
        var_type_dict:  bin.var_type_dict
        final_columns:  final_columns
        model:          lr_model
        train_score:    train_score
        """
        model_save = {}
        model_save['bin_dictionary'] = bin_dictionary
        model_save['woe_dict'] = woe_dict
        model_save['model'] = model
        try:
            joblib.dump(model_save, path, compress=True)
        except:
            print('load model error!~~')

    @staticmethod
    def get_var_analysis(lr_model, model_coef, bin_info, table, A=540, B=86.5617):
        """
        模型导出模块:
        Parameters
        ----------
        lr_model:     拟合好的lr_model
        model_coef:   模型变量系数df
        bin_info:     变量的bin字典
        table:        变量的分析table字典
        """
        print('调整常数:\t{:}\n线性变换系数:\t{:}\n截距:\t{:>25}'.format(
            *[A, B, lr_model.intercept_[0]]))

        var_analysis = pd.DataFrame(
            columns=['var', 'index', 'Bin', 'score', 'non_response', 'response', 'woe', 'iv'])
        final_vars = model_coef['columns'].values
        num_vars = len(final_vars)  # 变量的个数
        add_score2var = (A - B*lr_model.intercept_[0])/num_vars
        for k, v in bin_info.items():
            if k not in final_vars:
                continue
            t_lst = []
            Beta_i = model_coef.loc[model_coef['columns']
                                    == k, 'coef'].values[0]
            if isinstance(v, list):
                for j in range(len(v)+1):
                    if j == 0:
                        bin_detail = str(round(v[j], 4))+']'
                    elif j == len(v):
                        bin_detail = '(' + str(round(v[j-1], 4))
                    else:
                        bin_detail = '('+str(round(v[j-1], 4)) + \
                            ','+str(round(v[j], 4))+']'
                    woe_ij = table[k].loc[j, 'woe']
                    score = round(add_score2var - B*Beta_i*woe_ij, 2)
                    t_lst.append([k, j, bin_detail, score])
            elif isinstance(v, dict):
                for k1, v1 in v.items():
                    woe_ij = table[k].loc[v1, 'woe']
                    score = round(add_score2var - B*Beta_i*woe_ij, 2)
                    t_lst.append([k, v1, k1, score])
            else:
                print('bin info error!~~')
            df2 = table[k]
            var_detail_df = pd.DataFrame(t_lst, columns=['var', 'index', 'Bin', 'score']).merge(
                df2, left_on='index', right_on=df2.index)
            var_analysis = pd.concat([var_analysis, var_detail_df], axis=0)
        var_analysis['total'] = var_analysis['non_response'] + \
            var_analysis['response']
        total_user = sum(var_analysis['total'])/num_vars
        var_analysis['user_ratio'] = var_analysis['total']/total_user
        return var_analysis

    @staticmethod
    def load(path):
        return joblib.load(path)


class Test_apply(CommonTool):
    """
    测试集转换类

    Parameters
    ----------
    data:需要计算的数据集(已经离散化的DataFrame)
    target:标识列(Series)变量取值(0,1)
    model_path:保存好的模型信息路径
    response(默认1):
            1: 标识列中1代表响应
            0: 标识列中0代表响应
    Examples
    --------
    >>>import ScoreCardBox as scb
    >>>test_apply=scb.test_apply(test,test.flag,'/root/model_save/model1.pkl',['userid','bankid','flag'])

    >>>test_woe=test_apply.transform()
    """

    def __init__(self, data, target, model_path, ignore_columns=None, response=1):
        super(Test_apply, self).__init__(data, target, ignore_columns)
        try:
            self.model_save = Apply_func.load(model_path)
        except:
            print("can't load apply model,please check!~~")
        self.bin_info = self.model_save['bin_dictionary']
        final_columns = list(self.bin_info.keys())
        self.df_test = self.df[final_columns]

    def transform(self):
        bin_ins = Bin(self.df_test, target=None)
        dis_df = bin_ins.transform(bin_info=self.bin_info)
        woe_ins = Woe_dataframe(dis_df, target=None, caculate=False)
        woe_test = woe_ins.woe_transform(self.model_save['woe_dict'])
        if self.ignore_columns:
            woe_test = self.recover_func(woe_test)
        return woe_test


class PSI(object):
    def __init__(self, test, real):
        self.test = test
        self.real = real
        self.main()

    def main(self):
        bin_ = range(10, 101, 10)
        bins = np.array(np.percentile(self.test, bin_))
        bins = np.sort(list(set(np.round(bins.tolist(), 3))))
        test_bin = pd.Series(np.digitize(self.test, bins, right=True))
        real_bin = pd.Series(np.digitize(self.real, bins, right=True))
        test_ratio = test_bin.value_counts().sort_index()/len(test_bin)
        real_ratio = real_bin.value_counts().sort_index()/len(real_bin)
        final_df = pd.concat([test_ratio, real_ratio], axis=1, join='inner')
        final_df.columns = ['test', 'real']
        final_df['minus'] = final_df['real']-final_df['test']
        final_df['In'] = (final_df['real']/final_df['test']).apply(np.log)
        final_df['psi'] = final_df['minus']*final_df['In']
        self.final_df = final_df
        self.bins = bins

    @property
    def final_df(self):
        return self.final_df

    @property
    def bins(self):
        return self.bins

    @property
    def psi(self):
        return self.final_df.psi.sum()
