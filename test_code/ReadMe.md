# 评分卡建模流程

本项目提供了一套完整的评分卡建模工具，基于Python实现，涵盖数据预处理、特征工程、模型训练与评估等全流程。以下是详细的建模流程说明：

## 一、数据处理
### 1. 功能概述
对数据集进行初步探索，识别数据分布、缺失值和异常值，处理后的数据用于特征工程。

### 2. 具体实现
1. **变量画像**：
    - 基本统计信息：数据类型、非空个数、均值、标准差、最小值、中位数、最大值
    - 分布特征：唯一值个数、Top1占比、Top3占比、唯一值占比
    - 异常值分析：异常值个数、异常值占比
    - 缺失值分析：缺失值个数、缺失率

2. **缺失值填充**：
    - 数值型变量：0填充
    - 离散型变量：用'unknown'填充
    - 高缺失率变量（>50%）：直接删除，业务不允许这么高的缺失率

3. **异常值处理**：
    - 异常值识别方法
        1. 箱线图检测法
        2. 3sigma原则
        3. 基于增强z-score的异常值检测,基于 MAD, MAD=median(|x-x.median()|)，M_i = 0.6745*(|x-x.median()|)/MAD
    - 输出异常值列表和占比

4. **离散变量编码**：
    - 基于好坏比列倒序的数值编码
    - 生成编码字典，便于逆转换

### 4. 输入输出
- **输入**：原始数据集（DataFrame）
- **输出**：单变量分析报告、处理后数据集

## 三、特征工程
### 1. 功能概述
特征工程是评分卡建模的核心步骤，包括特征分箱、WOE编码、IV值计算和特征筛选等。

### 2. 具体功能
#### 2.1 特征分箱
- **分箱方法**：
    - 最终选择：最优分箱（CART决策树分箱）最小叶节点占比5%

#### 2.2 WOE编码与IV计算
- **WOE编码**：将变量值转换为证据权重值（`weightOfEvidence.py`）
- **IV计算**：计算每个变量的信息价值，评估变量预测能力（`weightOfEvidence.py`）

#### 2.3 特征筛选
- **单变量筛选**：基于IV值筛选（`uniAnalysis.py`）
- **多变量筛选**：基于相关性分析和VIF（多重共线性）检测（`multiAnalysis.py`、`model.py`）
- **递归特征消除**：使用RFE和RFECV方法（`model.py`）

#### 2.4 相关性分析
- **相关系数计算**：基于Pearson相关系数（`multiAnalysis.py`）
- **强相关变量处理**：基于IV值选择强相关变量组中的最优变量（`multiAnalysis.py`）

### 4. 输入输出
- **输入**：处理后数据集
- **输出**：WOE编码后的数据集、筛选后的特征列表

## 四、模型训练
### 1. 功能概述
实现评分卡模型的训练、参数调优和评估。

### 2. 核心实现
- **模型训练**：`model.py` 中的 `Models` 类

### 3. 具体功能
1. **模型类型**：
    - 逻辑回归（默认）

2. **参数调优**：
    - 网格搜索（GridSearchCV）
    - 支持L2正则化

3. **特征选择**：
    - 递归特征消除（RFE、RFECV）
    - 基于VIF的多重共线性检测

4. **模型评估**：
    - ROC-AUC曲线
    - 混淆矩阵
    - 分类报告

### 4. 输入输出
- **输入**：WOE编码后的训练集
- **输出**：训练好的模型、模型评估指标

### 5. 使用示例
```python
from model import Models

# 模型训练
model = Models(corr_reduced_data, df_processed['flag'])
# 参数调优与训练
lr_model = model.LR(cv_scoring='roc_auc', cv=5)

# 模型评估
y_pred = lr_model.predict(test_data)
accuracy = accuracy_score(test_data['flag'], y_pred)
roc_auc = roc_auc_score(test_data['flag'], lr_model.predict_proba(test_data)[:, 1])
print(f'Accuracy: {accuracy}, ROC-AUC: {roc_auc}')
```

## 五、模型测试
### 1. 功能概述
对训练好的模型进行测试和评估，确保模型性能符合预期。

### 2. 核心实现
- **模型评估**：`model.py` 中的相关方法

### 3. 具体功能
1. **性能评估**：
    - 计算准确率、精确率、召回率、F1值
    - 绘制ROC曲线和PR曲线
    - 计算KS统计量

2. **评分卡转换**：
    - 将模型输出转换为评分卡分数
    - 确定分数刻度和基准分

### 4. 输入输出
- **输入**：训练好的模型、测试数据集
- **输出**：模型评估报告、评分卡分数

## 六、模型导出
### 1. 功能概述
将训练好的模型和相关配置导出，便于部署和使用。

### 2. 核心实现
- **模型保存**：使用 `joblib` 库保存模型
- **配置保存**：保存分箱规则、WOE编码表等

### 3. 具体功能
1. **模型保存**：
    - 保存模型参数和系数
    - 保存特征列表和分箱规则

2. **评分卡导出**：
    - 导出评分卡规则表
    - 生成Excel报告

### 4. 输入输出
- **输入**：训练好的模型、评分卡参数
- **输出**：模型文件、评分卡规则表、Excel报告

### 5. 使用示例
```python
import joblib

# 保存模型
joblib.dump(lr_model, 'scorecard_model.pkl')

# 保存分箱规则和WOE编码
binning_rules = {'feature1': bin_rules1, 'feature2': bin_rules2}
joblib.dump(binning_rules, 'binning_rules.pkl')

# 生成Excel报告
generate_excel_report(lr_model, binning_rules, 'scorecard_report.xlsx')
```

## 七、项目结构
```
test_code/
├── ReadMe.md           # 项目文档
├── mian.py             # 主程序入口
├── myscorecard.py      # 评分卡建模类
├── train_HR.csv        # 示例数据
└── model_code/         # 核心模块
    ├── binTransform.py        # 特征分箱转换
    ├── chi2square_bin.py      # 卡方分箱
    ├── commonTools.py         # 通用工具
    ├── dataProcess.py         # 数据处理
    ├── model.py               # 模型训练与评估
    ├── multiAnalysis.py       # 多变量分析
    ├── sampleSeg.py           # 样本分割与抽样
    ├── uniAnalysis.py         # 单变量分析
    └── weightOfEvidence.py    # WOE与IV计算
```

## 八、依赖包
- pandas
- numpy
- scikit-learn
- scipy
- matplotlib
- seaborn
- joblib

## 九、使用流程
1. 数据加载与预处理
2. 单变量分析与特征筛选
3. 样本分割与平衡
4. 特征分箱与WOE编码
5. 模型训练与调优
6. 模型评估与测试
7. 模型导出与部署

希望本文档能帮助您快速理解和使用本评分卡建模工具。如有任何问题或建议，请随时联系。