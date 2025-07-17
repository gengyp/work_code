# 加载包
import os
import sys
import numpy as np
import pandas as pd

# 获取当前工作目录的绝对路径
curr_path = os.getcwd()
sys.path.insert(0, os.path.join(curr_path, 'model_code'))

# 模型和输出文件保存名称，可变参数
data_file = 'train_HR.csv'
model_path = 'hr_att_rate.pkl'
excel_path = 'hr_att_rate.xlsx'

# step1 数据画像探索
# 1. 数据加载
df = pd.read_csv(os.path.join(curr_path,data_file))
print(df.shape)
df.head()

# 2. 单变量分析
# 分析字段：数据类型，非空个数、均值、标准差、最小值、中位数、最大值
# 唯一值个数，异常值个数，异常值占比、缺失率，Top1占比，Top3占比

from uniAnalysis import Univariable
# label 列重命名
df.rename(columns={'left':'flag'}, inplace=True)

uni = Univariable(df=df,target=df['flag'])
# 查看变量的单变量统计表
uni_table = uni.overview
uni_table.head()


# 3. 缺失值填充
# 4. 异常值处理
# 5. 离散变量编码

# 对所有字符型变量空值 用 ‘0’替代
str_cols = df.columns[df.dtypes == 'object']
for col in str_cols:
    df.loc[(df[col]=='')|(df[col]=='未知'),col] = '0'
print('字符型变量个数:{}\n分别为:{}\n缺失值已补0.'.format(len(str_cols),','.join(str_cols)))


# 异常值处理
# df.loc[df.nearest_pass_org=='资金平台-131','nearest_pass_org'] = '0'
# df.loc[df.in_time=='运营商未提供入网时间','in_time'] = '0'

# 2. 变量缺失值处理
from dataProcess import DataProcess

# 缺失值统计
df.isnull().sum().sort_values(ascending=False).head(5)
pro = DataProcess(df=df,target=df.flag,ignore_columns=ignore)


df_miss = pro.check_na


df_miss[df_miss['missNum']>0].head()


pro.fillna_simple(drop_ratio=0.5)


s = df['time_spend_company']



pro.outlier_analysis


cat_vars = pro.cat_vars


# 2. 字符型变量编码


# 对离散变量进行编码，返回编码
pro.labelencoder


trans_dict = pro.trans_dict
trans_dict


df = pro.get_processedData


df.shape


# # step2 单变量分析
# 1. 单变量分析表





# unique_num=1 的变量直接删除
dropcol = set(uni_table[uni_table.eval('uniqueNum<=1')].index)


print('删除变量个数: {}\nTop10 删除变量:{}'.format(len(dropcol),list(dropcol)[:20]))


df.drop(dropcol,axis=1,inplace=True)


# top1 >0.8 or unique_num<=10 的变量作为离散变量
cat_vars = (set(uni_table[uni_table.eval('top1p>0.8 | uniqueNum<=10')].index)|set(cat_vars)) - dropcol


print('离散变量个数: {}\nTop10 离散变量:{}'.format(len(cat_vars),list(cat_vars)[:10]))


# 2. 好坏样本分布


df.flag.value_counts()
df.flag.value_counts()/len(df)


# # step3 随机抽样


from sampleSeg import Sample


sam = Sample(df=df,target=df.flag,pct_train=0.75,class_weight='balanced')


train,test = sam.train,sam.test


# # step4 对训练样本做 bin
# 1. 连续变量和离散变量 分BIN


# print(scb.bin.__doc__)
from binTransform import Bin


bin=Bin(df=train,target=train['flag'],ignore_columns=ignore,cat_columns=list(cat_vars))


print('连续变量：{}，离散变量：{}'.format(len(bin.num_columns),len(bin.cat_columns)))


# bin.num_columns


bin.num_bin_cart(columns=bin.num_columns,min_leaf_ratio=0.15)
#将所有连续型变量采用等量划分法分为7段


print('连续变量：{}，离散变量：{}'.format(len(bin.num_columns),len(bin.cat_columns)))


bin.cat_bin_solution(columns=bin.cat_columns)


# 变量分箱信息
bad_var = []
for k,v in bin.bin_info.items():
    if len(v)<10:
        print('\n变量:{: <30}--> {:}'.format(k,v))
    else:
        print(k,len(v),'\n'*2)
        bad_var.append(k)


# bad_var
# bin.bin_info[bad_var[0]]


# # 有问题变量输出,人为分箱
# tempdt = {'call_time_6m_collection':{(0.0,): 0.0, (11.0,): 11.0, 'others': 999999}}
# bin.artificial_update_bin(tempdt)


dis_df=bin.transform()
#得到分箱后的数据集
dis_df.head()


# 2. bin后数据，做含 iv值的单变量分析


# 对分箱后的数据集再次进行单变量分析，包含Iv值分析
uni = Univariable(df=dis_df,target=dis_df['flag'],ignore_columns=ignore,cal_iv=True)


uni_table = uni.overview
uni_table.head() # uni_table.loc['total_12m']


# 3. iv值 筛选变量，并做 woe 转换


after_uni=uni.select('Iv>=0.02') # 根据单变量统计表,输入条件筛选列


#得到单变量筛选后的数据集after_uni
after_uni.head()


after_uni_woe=uni.get_woe_transformed
#将单变量筛选后的数据集做woe转换


after_uni_woe.head()


# # Step5 多变量分析
# 1. 相关性分析


from multiAnalysis import Multiple
mul=Multiple(df=after_uni_woe,target= after_uni_woe['flag'],ignore_columns=ignore)
#创建多变量分析的实例mul


after_cor=mul.corr_reduce(df_miss,uni_table,corr_ratio=0.4)
#调用相关性筛选函数，即相关性大于0.5的两个变量即为一组
#将筛选后的数据集赋值给after_cor变量
after_cor.shape


after_cor.head()
#查看相关性筛选后的数据集


# 2. 逐步回归分析


result_table=mul.multi_analysis_table(n_features_to_select=7)
# 执行拟合分析函数，这里逐步回归选择10个变量，同时进行稳定性检验,如果变量较少可不做该步
# 得到的分析表格赋值给result_table变量


result_table.head()
#查看拟合分析的结果


final_df,final_columns=mul.multi_reduce(result_table)
final_df.shape
#根据上一步的拟合结果，得到最终的数据集和变量名


final_df.head()
#查看最终经过woe转换的数据集


uni_table.loc[final_columns].sort_values('Iv',ascending=False)
# 查看最终变量名,以及变量iv值等变量分析表


# # step6 模型拟合



from model import Models,Evaluate,Apply_func,Test_apply
model = Models(data=final_df,target = final_df['flag'],ignore_columns=ignore)


lr_model= model.LR()


eva = Evaluate(data=final_df, target = final_df['flag'], fitted_model=lr_model, ignore_columns=ignore)


model_eva = pd.DataFrame([],columns=['train_set','test_set']
                         ,index=['ks-value','auc','acc','precision','recall','f1-score','bad_num','total_num','bad_ratio'])



model_eva['train_set'] = eva.report


# 变量系数
model_coef = eva.coef
model_coef


train_score = eva.from_p_to_score
train_score.head()


train_score.score[train_score.flag==0].hist(bins=50,color='green',alpha=0.5)
train_score.score[train_score.flag==1].hist(bins=50,color='red',alpha=0.3)
# train_score.score.hist(bins=50)


# 最终变量的Woe转换字典woe_dict，离散化后 dis_df 转换
woe_dict={}
for i in final_columns:
    woe_dict[i]=uni.woe[i]


Apply_func.save(bin_dictionary=bin.bin_info, woe_dict=woe_dict,model=lr_model, path=model_path)
# 将建模的重要信息保存到该目录下的document_model.pkl文件里


# # step7 模型测试


# print scb.test_apply.__doc__
from model import Test_apply


test_apply = Test_apply(data=test,target=test['flag'], model_path=model_path, ignore_columns=ignore)


test_woe = test_apply.transform()


test_woe.head()


test_woe=test_woe.dropna(axis=0)


test_eva=Evaluate(data=test_woe, target=test_woe['flag'], fitted_model=lr_model, ignore_columns=ignore)
#创建测试集评估类


model_eva['test_set'] = test_eva.report


test_score = test_eva.from_p_to_score
test_score.head()


# test_score.score.hist(bins=50)
#查看测试集score字段的分布


test_score.score[test_score.flag==0].hist(bins=50,color='green',alpha=0.5)
test_score.score[test_score.flag==1].hist(bins=50,color='red',alpha=0.3)


# # step8 模型导出


# from model1 import Apply_func
bins = np.linspace(220,900,18)
train_score['grade'] = pd.cut(train_score.score,bins)
test_score['grade'] = pd.cut(test_score.score,bins)


std_vars_info = model_coef.merge(uni_table,how='left',left_on='columns',right_on=uni_table.index)


var_analysis = Apply_func.get_var_analysis(lr_model=lr_model,model_coef=model_coef,bin_info=bin.bin_info,table=uni.table)


train_group = train_score.groupby(['grade','flag'])['userid'].count().unstack()
train_group.columns = ['good','bad']
train_group['total'] = train_group['good'] + train_group['bad']
train_group['bad_ratio'] = train_group['bad']/train_group['total']


test_group = test_score.groupby(['grade','flag'])['userid'].count().unstack()
test_group.columns = ['good','bad']
test_group['total'] = test_group['good'] + test_group['bad']
test_group['bad_ratio'] = test_group['bad']/test_group['total']


with pd.ExcelWriter(excel_path) as output_excel:
  model_eva.to_excel(output_excel,index=True,sheet_name='模型评估',encoding='utf-8',float_format = '%.3f')
  std_vars_info.to_excel(output_excel,index=False,sheet_name='变量系数',encoding='utf-8',float_format = '%.8f')
  var_analysis.to_excel(output_excel,index=False,sheet_name='分析表',encoding='utf-8',float_format = '%.4f')
  train_score.to_excel(output_excel,index=False,sheet_name='训练得分明细',encoding='utf-8',float_format = '%.2f')
  test_score.to_excel(output_excel,index=False,sheet_name='测试得分明细',encoding='utf-8',float_format = '%.2f')
  train_group.to_excel(output_excel,index=True,sheet_name='训练用户分层',encoding='utf-8',float_format = '%.2f')
  test_group.to_excel(output_excel,index=True,sheet_name='测试用户分层',encoding='utf-8',float_format = '%.2f')








