import pandas as pd
import numpy as np
from sklearn.tree import DecisionTreeClassifier
from typing import Dict, List, Union
from .base import BaseProcessor

class BinningProcessor(BaseProcessor):
    def __init__(self, config_path: str = None):
        super().__init__(config_path)
        self.bin_info = {}

    def fit(self, df: pd.DataFrame, target: pd.Series, cat_cols: List[str] = None):
        """训练分箱"""
        self.bin_info = {}
        num_cols = [col for col in df.columns if col not in (cat_cols or [])]

        # 连续变量分箱
        for col in num_cols:
            self.bin_info[col] = self._numeric_binning(df[col], target)

        # 分类变量分箱
        for col in (cat_cols or []):
            self.bin_info[col] = self._categorical_binning(df[col], target)

    def _numeric_binning(self, series: pd.Series, target: pd.Series) -> List[float]:
        """连续变量CART分箱"""
        min_leaf = self.config.get('binning', {}).get('continuous', {}).get('min_leaf_ratio', 0.1) * len(series)

        tree = DecisionTreeClassifier(
            max_leaf_nodes=self.config.get('binning', {}).get('continuous', {}).get('max_bins', 5),
            min_samples_leaf=min_leaf
        )
        tree.fit(series.values.reshape(-1, 1), target)

        thresholds = np.sort(tree.tree_.threshold[tree.tree_.threshold != -2])
        return thresholds.tolist()

    def _categorical_binning(self, series: pd.Series, target: pd.Series) -> Dict:
        """分类变量合并分箱"""
        max_bins = self.config.get('binning', {}).get('categorical', {}).get('max_bins', 6)
        # 简化的合并逻辑，实际应实现完整的IV计算和合并
        value_counts = series.value_counts()
        if len(value_counts) <= max_bins:
            return {v: v for v in value_counts.index}
        else:
            # 简化的合并策略 - 实际应基于统计指标
            main_values = value_counts.nlargest(max_bins-1).index
            return {v: v if v in main_values else 'others' for v in series.unique()}

    def transform(self, df: pd.DataFrame) -> pd.DataFrame:
        """应用分箱转换"""
        binned_df = pd.DataFrame(index=df.index)

        for col, bins in self.bin_info.items():
            if isinstance(bins, list):  # 连续变量
                binned_df[col] = pd.cut(df[col], bins=[-np.inf] + bins + [np.inf], labels=False)
            else:  # 分类变量
                binned_df[col] = df[col].map(bins).fillna('others')

        return binned_df
