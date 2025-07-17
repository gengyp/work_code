import pandas as pd
import numpy as np
from scipy.stats import chi2

def calc_chiSquare(sampleSet):
    '''
    计算卡方统计量
    '''
    # 计算样本期望频率
    target_cnt = sampleSet['target'].sum()
    sample_cnt = sampleSet['target'].count()
    expected_ratio = target_cnt * 1.0/sample_cnt 
    # 对变量按属性值从大到小排序
    df = sampleSet[['var', 'target']]
    col_value = list(set(df['var']))
    col_value.sort()    
    # 对变量区间进行遍历，计算每一个区间对应的卡方统计量
    chi_list = []; target_list = []; expected_target_list = []
    for value in col_value:
        df_target_cnt = df.loc[df['var'] == value,'target'].sum()
        df_cnt = df.loc[df['var'] == value,'target'].count()
        expected_target_cnt = df_cnt * expected_ratio
        chi_square = (df_target_cnt - expected_target_cnt)**2 / expected_target_cnt
        chi_list.append(chi_square)
        target_list.append(df_target_cnt)
        expected_target_list.append(expected_target_cnt)
    # 导出结果到dataframe
    chi_result = pd.DataFrame({'var':col_value, 'chi_square':chi_list,
                               'target_cnt':target_list, 'expected_target_cnt':expected_target_list})
    return chi_result

def chiMerge_maxInterval(chi_result, maxInterval=5):
    '''
    卡方分箱合并--最大区间限制法
    '''
    group_cnt = len(chi_result)
    # 如果变量区间超过最大分箱限制，则根据合并原则进行合并
    while(group_cnt > maxInterval):
        min_index = chi_result[chi_result['chi_square']==chi_result['chi_square'].min()].index.tolist()[0]
        # 如果分箱区间在最前,则向下合并
        if min_index == 0:
            chi_result = merge_chiSquare(chi_result, min_index+1, min_index)
        # 如果分箱区间在最后，则向上合并
        elif min_index == group_cnt-1:
            chi_result = merge_chiSquare(chi_result, min_index-1, min_index)
        # 如果分箱区间在中间，则判断与其相邻的最小卡方的区间，然后进行合并
        else:
            if chi_result.loc[min_index-1, 'chi_square'] > chi_result.loc[min_index+1, 'chi_square']:
                chi_result = merge_chiSquare(chi_result, min_index, min_index+1)
            else:
                chi_result = merge_chiSquare(chi_result, min_index-1, min_index)
        group_cnt = len(chi_result)
    return chi_result

def chiMerge_minChiSquare(chi_result, maxInterval=5):
    '''
    卡方分箱合并--卡方阈值法
    '''
    threshold = get_chiSquare_distribution(4, 0.1)
    min_chiSquare = chi_result['chi_square'].min()
    group_cnt = len(chi_result)
    # 如果变量区间的最小卡方值小于阈值，则继续合并直到最小值大于等于阈值
    while(min_chiSquare < threshold and group_cnt > 6):
        min_index = chi_result[chi_result['chi_square']==chi_result['chi_square'].min()].index.tolist()[0]
        # 如果分箱区间在最前,则向下合并
        if min_index == 0:
            chi_result = merge_chiSquare(chi_result, min_index+1, min_index)
        # 如果分箱区间在最后，则向上合并
        elif min_index == group_cnt-1:
            chi_result = merge_chiSquare(chi_result, min_index-1, min_index)
        # 如果分箱区间在中间，则判断与其相邻的最小卡方的区间，然后进行合并
        else:
            if chi_result.loc[min_index-1, 'chi_square'] > chi_result.loc[min_index+1, 'chi_square']:
                chi_result = merge_chiSquare(chi_result, min_index, min_index+1)
            else:
                chi_result = merge_chiSquare(chi_result, min_index-1, min_index)
        min_chiSquare = chi_result['chi_square'].min()
        group_cnt = len(chi_result)
    return chi_result

def get_chiSquare_distuibution(dfree=4, cf=0.1):
    '''
    根据自由度和置信度得到卡方分布和阈值
    dfree:自由度，分类类别-1，默认为4
    cf:显著性水平 significance level，默认10%
    '''
    percents = [ 0.95, 0.90, 0.5,0.1, 0.05, 0.025, 0.01, 0.005]
    # df 为 卡方分布 分位数表
    df = pd.DataFrame(np.array([chi2.isf(percents, df=i) for i in range(1, 30)]))
    df.columns = percents
    df.index = df.index+1
    # 显示小数点后面数字
    pd.set_option('precision', 3)
    return df.loc[dfree, cf]    # 

def merge_chiSquare(chi_result, index, mergeIndex, a='expected_target_cnt',b='target_cnt',c= 'chi_square'):
    '''
    按index进行合并，并计算合并后的卡方值
    index: 合并后的序列号
    mergeIndex: 需合并的区间序号
    '''
    chi_result.loc[mergeIndex, a] = chi_result.loc[mergeIndex, a] + chi_result.loc[index, a]
    chi_result.loc[mergeIndex, b] = chi_result.loc[mergeIndex, b] + chi_result.loc[index, b]
    chi_result.loc[mergeIndex, c] = (chi_result.loc[mergeIndex, b] - chi_result.loc[mergeIndex, a])**2 /chi_result.loc[mergeIndex, a]
    chi_result = chi_result.drop([index])
    chi_result = chi_result.reset_index(drop=True)
    return chi_result 
