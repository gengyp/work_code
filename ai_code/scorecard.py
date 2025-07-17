import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import GridSearchCV
from typing import Dict
from .base import BaseProcessor

class ScorecardModel(BaseProcessor):
    def __init__(self, config_path: str = None):
        super().__init__(config_path)
        self.model = None
        self.coefficients = {}

    def train(self, X: pd.DataFrame, y: pd.Series):
        """训练逻辑回归模型"""
        params = {
            'C': np.logspace(-3, 3, 7),
            'penalty': ['l2'],
            'class_weight': [self.config.get('model', {}).get('class_weight', 'balanced')]
        }

        gs = GridSearchCV(
            LogisticRegression(),
            param_grid=params,
            scoring=self.config.get('model', {}).get('scoring', 'roc_auc'),
            cv=self.config.get('model', {}).get('cv', 3)
        )
        gs.fit(X, y)

        self.model = gs.best_estimator_
        self.coefficients = dict(zip(X.columns, self.model.coef_[0]))

    def predict_score(self, X: pd.DataFrame, base_points: int = 600, pdo: int = 20) -> pd.Series:
        """预测分数"""
        if not self.model:
            raise ValueError("Model not trained yet")

        # 计算log odds
        log_odds = self.model.predict_log_proba(X)[:, 1]

        # 分数转换
        factor = pdo / np.log(2)
        offset = base_points - factor * np.log(1)  # 假设odds=1时得分为base_points

        scores = offset - factor * log_odds
        return scores

    def get_model_report(self) -> Dict:
        """获取模型报告"""
        return {
            'intercept': float(self.model.intercept_[0]),
            'coefficients': self.coefficients,
            'feature_importance': dict(zip(
                self.coefficients.keys(),
                np.abs(list(self.coefficients.values()))
            ))
        }
