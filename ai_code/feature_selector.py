import pandas as pd
import numpy as np
from sklearn.feature_selection import RFE, RFECV
from sklearn.linear_model import LogisticRegression
from typing import List
from .base import BaseProcessor

class FeatureSelector(BaseProcessor):
    def __init__(self, config_path: str = None):
        super().__init__(config_path)
        self.selected_features = []

    def select_by_iv(self, iv_dict: Dict[str, float]) -> List[str]:
        """基于IV值筛选特征"""
        iv_threshold = self.config.get('feature_selection', {}).get('iv_threshold', 0.02)
        return [f for f, iv in iv_dict.items() if iv >= iv_threshold]

    def select_by_correlation(self, df: pd.DataFrame, threshold: float = 0.7) -> List[str]:
        """基于相关性筛选特征"""
        corr_matrix = df.corr().abs()
        upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(bool))
        to_drop = [col for col in upper.columns if any(upper[col] > threshold)]
        return [col for col in df.columns if col not in to_drop]

    def select_by_rfe(self, df: pd.DataFrame, target: pd.Series) -> List[str]:
        """递归特征消除"""
        n_features = self.config.get('feature_selection', {}).get('n_features', 15)
        model = LogisticRegression(class_weight=self.config.get('model', {}).get('class_weight', 'balanced'))
        rfe = RFE(model, n_features_to_select=n_features)
        rfe.fit(df, target)
        return df.columns[rfe.support_].tolist()

    def select_features(self, df: pd.DataFrame, target: pd.Series, iv_dict: Dict[str, float]) -> pd.DataFrame:
        """综合特征选择"""
        # 第一步：IV筛选
        iv_selected = self.select_by_iv(iv_dict)
        df_iv = df[iv_selected]

        # 第二步：相关性筛选
        corr_selected = self.select_by_correlation(df_iv)
        df_corr = df_iv[corr_selected]

        # 第三步：模型筛选
        self.selected_features = self.select_by_rfe(df_corr, target)
        return df[self.selected_features]
