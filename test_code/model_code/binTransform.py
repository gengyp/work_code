# -*- coding: utf-8 -*-
# import pp
import pandas
import numpy
from commonTools import CommonTool
from commonTools import EdaMethod
from commonTools import Discretizated
from time import time
from concurrent.futures import ProcessPoolExecutor
# from pathos.multiprocessing import ProcessPool as Pool


class Calculate_bin(object):
    """
    Bin计算的工厂类
    """
    @staticmethod
    def cat_bin_solution_1(s1, y, binlimitnum, evaluationType, decreasingvalue):
        def Evaluation(df, evaluationType, bininfodict, decreasingvalue, data_type):
            df['iv_plus_gain'] = numpy.round(numpy.where(
                df['iv'] >= 99, 0, df['iv'])+df['gain'], 4)
            df.sort_values(by=['woepattern', 'intervalnums'], inplace=True)
            varname, binsno = df['iv_plus_gain'].idxmax().split('&&')
            max_iv = df['iv_plus_gain'].max()
            if data_type == 'num':
                binsno = int(binsno)
            if evaluationType == 1:
                return varname, numpy.array(bininfodict[binsno])
            if evaluationType == 2:
                df['woepattern_flag'] = 1*(df['woepattern'] < 99)
                if df[df['woepattern_flag'] == 1].shape[0] > 0:
                    varname_con, binsno_con = df[df['woepattern_flag'] == 1]['iv_plus_gain'].idxmax(
                    ).split('&&')
                    if data_type == 'num':
                        binsno_con = int(binsno_con)
                    max_iv_con = df[df['woepattern_flag']
                                    == 1]['iv_plus_gain'].max()
                    if max_iv-max_iv_con > decreasingvalue:
                        return varname, numpy.array(bininfodict[binsno])
                    else:
                        return varname_con, numpy.array(bininfodict[binsno_con])
                else:
                    return varname, numpy.array(bininfodict[binsno])

        def binresult(series_discrete, y, data_type):
            # 输入：离散化序列，标签，数据类型
            # print('计算变量的 chi2pvalue、infogain、iv...')
            st_array = EdaMethod(series_discrete).UnFeatureSelection(y)
            woe_array, woe_info = Discretizated(
                series_discrete).WoeTransform(y)
            woepattern = EdaMethod(woe_info.values()).woecheck()
            intervalnums = len(series_discrete.value_counts().index.tolist())
            if data_type == 'num':
                return pandas.Series([st_array['chi2pvalue'], st_array['gain'], st_array['iv'], woepattern],
                                     index=['chi2pvalue', 'gain', 'iv', 'woepattern'])
            else:
                return pandas.Series([st_array['chi2pvalue'], st_array['gain'], st_array['iv'], woepattern, intervalnums],
                                     index=['chi2pvalue', 'gain', 'iv', 'woepattern', 'intervalnums'])

        def binprocess(s1, binlimitnum):
            '''
            输入：变量的Series
            输出：binlimitnum 种分箱结果，以及六种分箱数据框
            '''
            varname = s1.name
            d1 = pandas.DataFrame(s1, columns=[varname])
            st = s1.value_counts()  # 指标对应值的个数
            # 设置成“category”数据类型
            # d1[varname] = d1[varname].astype('category')
            d1 = d1.apply(lambda x: pandas.Categorical(x))

            bininfodict = {}
            bininfodict['0'] = st.index.tolist()  # 变量所有取值列表

            print('{} 变量取值个数为：{}。分箱结果如下：'.format(s1.name, s1.nunique()))
            print('{}-->{}'.format('0', bininfodict['0']))
            if len(st) <= 2:
                print('exists only less then 2 levels ,do not need  bin process')
                return d1, bininfodict

            endlimit = len(st)-2
            for i in range(1, binlimitnum):
                if i > endlimit:  # 变量取值 >6 不会执行该条件
                    return d1, bininfodict
                bins = st.nlargest(i).index.tolist()  # 前 i 大的取值list
                print('{}-->{}'.format(str(i), bins+['others']))

                s_new = d1[varname].copy()
                s_new = s_new.cat.set_categories(bins+['others'])
                s_new[~s_new.isin(bins)] = 'others'

                d1[varname+'&&'+str(i)] = s_new

                bininfodict[str(i)] = list(s_new.cat.categories.values)
            return d1, bininfodict

        d1, bininfodict = binprocess(s1, binlimitnum)

        # 对原始变量重命名，保证格式统一
        d1.rename(columns={s1.name: s1.name+'&&0'}, inplace=True)

        # 对 d1 的每一列操作,计算 卡方检验、信息增益、iv 值
        df1 = d1.apply(lambda x: binresult(x, y, data_type='cat')).T

        varname, bininfo = Evaluation(
            df1, evaluationType, bininfodict, decreasingvalue, data_type='cat')

        dt = {}
        for i in bininfo:
            if i == 'others':
                dt[i] = 999999
            else:
                i = eval(i) if isinstance(i, str) else i
                dt[(i,)] = i
        return dt

    @staticmethod
    def chi_merge(s1, maxInterval=5):
        pass

    @staticmethod
    def num_bin_cart(s1, y, min_leaf_ratio):
        def calc_var_median(sample_set):
            '''
            计算相邻变量的中位数，以便进行决策树二元切分
            '''
            var_list = list(numpy.unique(sample_set.iloc[:, 0]))
            var_list.sort()
            var_median_list = []
            for i in range(len(var_list) - 1):
                var_median = round((var_list[i] + var_list[i+1]) / 2.0, 2)
                var_median_list.append(var_median)
            return var_median_list

        def choose_best_split(sample_set, min_samples_leaf):
            '''
            使用CART分类决策树选择最好的样本切分点
            返回切分点
            '''
            var_median_list = calc_var_median(sample_set)

            sample_cnt = sample_set.shape[0]
            sample1_cnt = sum(sample_set.iloc[:, 1])
            sample0_cnt = sample_cnt - sample1_cnt
            Gini = 1 - numpy.square(1.0*sample1_cnt / sample_cnt) - \
                numpy.square(1.0*sample0_cnt / sample_cnt)

            bestGini = 0.0
            bestSplit_point = 'null'
            for split in var_median_list:
                left = sample_set[sample_set.iloc[:, 0] < split]
                right = sample_set[sample_set.iloc[:, 0] > split]

                left_cnt = left.shape[0]
                right_cnt = right.shape[0]
                left1_cnt = sum(left.iloc[:, 1])
                right1_cnt = sum(right.iloc[:, 1])
                left0_cnt = left_cnt - left1_cnt
                right0_cnt = right_cnt - right1_cnt
                left_ratio = 1.0*left_cnt / sample_cnt
                right_ratio = 1.0*right_cnt / sample_cnt

                if left_cnt < min_samples_leaf or right_cnt < min_samples_leaf:
                    continue
                # 计算该切分点的Gini系数
                Gini_left = 1 - \
                    numpy.square(1.0*left1_cnt / left_cnt) - \
                    numpy.square(1.0*left0_cnt / left_cnt)
                Gini_right = 1 - \
                    numpy.square(1.0*right1_cnt / right_cnt) - \
                    numpy.square(1.0*right0_cnt / right_cnt)
                Gini_temp = Gini - (left_ratio * Gini_left +
                                    right_ratio * Gini_right)
                if Gini_temp > bestGini:
                    bestGini = Gini_temp
                    bestSplit_point = split

            Gini = Gini - bestGini
            return bestSplit_point

        def bining_data_split(sample_set, min_samples_leaf, split_list):
            '''
            划分数据找到最优分割点list
            '''
            split = choose_best_split(sample_set, min_samples_leaf)
            if split == 'null':
                return

            split_list.append(split)
            # 根据分割点划分数据集，判断是否能继续划分，如果可以则继续
            sample_set_left = sample_set[sample_set.iloc[:, 0] < split]
            sample_set_right = sample_set[sample_set.iloc[:, 0] > split]
            print('左节点样本量:{},右节点样本量:{},样本分割点:{}'.format(
                sample_set_left.shape[0], sample_set_right.shape[0], split_list))
            if len(sample_set_left) >= 2*min_samples_leaf and len(numpy.unique(sample_set_left.iloc[:, 0])) > 1:
                bining_data_split(
                    sample_set_left, min_samples_leaf, split_list)

            if len(sample_set_right) >= 2*min_samples_leaf and len(numpy.unique(sample_set_right.iloc[:, 0])) > 1:
                bining_data_split(sample_set_right,
                                  min_samples_leaf, split_list)

        def get_bestsplit_list(s1, y, min_samples_leaf):
            '''
            根据分箱得到最优分割点list
            '''
            # 计算最小样本阈值（终止条件）
            split_list = []
            bining_data_split(pandas.concat(
                [s1, y], axis=1), min_samples_leaf, split_list)
            split_list.sort()
            return split_list

        min_samples_leaf = int(numpy.ceil(min_leaf_ratio * len(y)))

        print('\n分箱变量:{},叶子节点最小数量:{}'.format(s1.name, min_samples_leaf))
        split_list = get_bestsplit_list(s1, y, min_samples_leaf)
        if split_list == []:
            print(s1.value_counts()/len(y))

        return split_list


class Bin(CommonTool):
    """
    Bin计算类 : 数据离散以及最优Bin的计算

    Parameters
    ----------
    data:需要计算的数据集
    target:标识列(Series)
    ignore_columns(默认None):需要忽略的列(包含列名的list) 会在计算时忽略
    cat_columns(默认为None):离散变量（取值大于50可认为是连续变量）

    Examples
    --------
    >>>import ScoreCardBox as scb
    >>>bin=scb.bin(train,train.flag,['userid', 'flag'])

    >>>bin#查看目前支持的算法

    >>>dis_df=bin.transform()#默认根据实例的bin_info来转换，也可以传入特定的bin_info
    """

    def __init__(self, df, target, ignore_columns=None, cat_columns=None):
        super(Bin, self).__init__(df, target, ignore_columns)
        self.cat_columns = cat_columns

        self.bin_info = {}
        if cat_columns is not None:
            self.get_num_columns()

    def get_num_columns(self):
        '''分离连续、离散变量'''
        num_cols = []
        for i in self.df.columns:
            if i not in self.cat_columns:
                num_cols.append(i)
        self.num_columns = num_cols

    def cat_bin_solution(self, columns, evaluationType=2, decreasingvalue=0.005, binlimitnum=6):
        """
        分类型最优算法1
        用于分类型变量的归并，穷举多种分类归并策略，最终采纳最合适的归并方法用来归并

        Parameters
        ----------
        columns: 需要计算的分类型列, 需要为list, 如['column1', 'column2']
        binlimitnum(默认6): 归并后最大区间数, 一般取6
        evaluationType(默认2): 1表示iv最大化策略，2表示综合最优策略
        decreasingvalue(默认为0.005): 在evaluationType=2的时候, 表示采用综合最优策略能否容忍的iv降低程度
        """
        # 如果未传入 columns 参数，则使用类实例中的 cat_columns 作为目标列
        final_columns = columns or self.cat_columns
        # 用于存储每个分类型列的分箱结果
        dt_cat = {}
        # 创建 Calculate_bin 类的实例，用于调用分箱计算方法
        ins = Calculate_bin()
        # 初始化已处理列的计数器
        count = 0
        # 记录需要处理的列的总数
        count_all = len(final_columns)
        # 遍历需要处理的分类型列
        for i in final_columns:
            # 计数器加 1
            count += 1
            # 调用 Calculate_bin 类的 cat_bin_solution_1 方法进行分箱计算
            dt = ins.cat_bin_solution_1(s1=self.df[i], y=self.target, binlimitnum=binlimitnum,
                                        evaluationType=evaluationType, decreasingvalue=decreasingvalue)
            # 将当前列的分箱结果存储到 dt_cat 字典中
            dt_cat[i] = dt
            # 打印当前处理进度信息
            print('{} columns have done with {} columns left\n'.format(
                count, count_all-count))
        # 将分箱结果更新到类实例的 bin_info 属性中
        self.bin_info.update(dt_cat)

    def num_bin_cart(self, columns=None, min_leaf_ratio=0.15):
        """
        最优分箱

        Parameters
        ----------
        columns(默认为'ALL'):需要计算的列,需要为list,如['column1','column2']
        min_leaf_ratio(默认为0.1):叶子节点最小占比
        """
        dt_num = {}
        self.num_columns = columns or self.num_columns
        ins = Calculate_bin()

        count = 0
        count_all = len(columns)
        start_time = time()

        for i in columns:
          count += 1
          dt = ins.num_bin_cart(s1=self.df[i],y=self.target,min_leaf_ratio=min_leaf_ratio)
          dt_num[i] = dt
          print('{} columns have done with {} columns left\n'.format(count,count_all-count))
          if count%10==0:
            print('\ntotal cost time:{}\n'.format(time()-start_time))

        # with ProcessPoolExecutor(max_workers=1) as executor:
        #     for col, dt in zip(columns, executor.map(ins.num_bin_cart, [self.df[i] for i in columns],
        #                                              [self.target for i in range(count_all)], [min_leaf_ratio]*count_all)):
        #         count += 1
        #         dt_num[col] = dt
        #         print('{} columns have done with {} columns left\n'.format(
        #             count, count_all-count))
        #         if count % 10 == 0:
        #             print('\ntotal cost time:{}\n'.format(time()-start_time))

        # pool = Pool(ncpus=10)
        # for col,dt in zip(columns,pool.map(ins.num_bin_cart,[self.df[i] for i in columns],
        #     [self.target for i in range(count_all)],[min_leaf_ratio]*count_all)):
        #   dt_num[col] = dt
        # print('\ntotal cost time:{}\n'.format(time()-start_time))

        self.bin_info.update(dt_num)
        self.__pro_null_bin()

    def __pro_null_bin(self):
        # 处理bin 为空的连续变量
        temp = []
        for k, v in self.bin_info.items():
            if v == []:
                temp.append(k)
                self.num_columns.pop(self.num_columns.index(k))
                self.cat_columns.append(k)
        for i in temp:
            self.bin_info.pop(i)

    def artificial_update_bin(self, dt):
        # 人工分箱，更新bin
        for k, v in dt.items():
            if isinstance(v, list):  # 连续变量
                if k in self.cat_columns:
                    self.cat_columns.pop(self.cat_columns.index(k))
                    self.num_columns.append(k)
            elif isinstance(v, dict):  # 离散变量
                if k in self.num_columns:
                    self.num_columns.pop(self.num_columns.index(k))
                    self.cat_columns.append(k)
            else:
                print('人工对部分变量分箱，更新 bin 出错！~~')
        self.bin_info.update(dt)

    def transform(self, bin_info=None):
        """
        Parameters
        ----------
        bin_info: bin信息的dict,默认为此实例做完bin后的bin_info

        comments: 分箱变量信息 要与 数据框变量个数 相等
        """
        bin_info = bin_info or self.bin_info

        cat_columns, num_columns = [], []
        for k, v in bin_info.items():
            if isinstance(v, dict):
                cat_columns.append(k)
            elif isinstance(v, list):
                num_columns.append(k)
            else:
                print('bin_info exist error!~~')

        # 根据 连续/离散 分离 bin_info
        num_bin_info, cat_bin_info = {}, {}
        for i in num_columns:
            num_bin_info[i] = bin_info[i]
        for i in cat_columns:
            cat_bin_info[i] = bin_info[i]

        dis_df_temp = []
        try:
            if len(num_columns):
                dis_df_temp.append(self.df[num_columns].apply(
                    lambda x: self.num_trans_func(x, num_bin_info[x.name]), axis=0))
            print("连续变量分箱转换完成！~~")
            if len(cat_columns):
                dis_df_temp.append(self.df[cat_columns].apply(
                    lambda x: self.cat_trans_func(x, cat_bin_info[x.name]), axis=0))
            dis_df = pandas.concat(dis_df_temp, axis=1)
            print("离散变量分箱转换完成！~~")
        except:
            print('discrete error!')
            return

        if self.ignore_columns:
            dis_df = self.recover_func(dis_df)
        return dis_df

    def num_trans_func(self, series, bins):
        return numpy.digitize(series, bins, right=True)

    def cat_trans_func(self, series, bins):
        bk = list(bins.keys())
        if 'others' in bk:
            bk.remove('others')
        _nk = [round(i, 8) for x in bk for i in x]  # 离散分箱 key，去除 others
        _other = [i for i in series.value_counts().index if round(i, 8)
                  not in _nk]  # others 取值 list
        for i in bins.keys():
            if i == 'others':
                if _other:
                    series.replace(_other, bins[i], inplace=True)
            else:
                series.replace(i, bins[i], inplace=True)
        return series
