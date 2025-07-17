import pandas as pd
import numpy as np
from .base import BaseProcessor
from typing import Dict, List

class DataPreprocessor(BaseProcessor):
    def __init__(self, config_path: str = None):
        super().__init__(config_path)
        self.encoders = {}

    def handle_missing_values(self, df: pd.DataFrame, drop_threshold: float = 0.5) -> pd.DataFrame:
        """处理缺失值"""
        missing_ratios = df.isnull().mean()
        to_drop = missing_ratios[missing_ratios > drop_threshold].index.tolist()
        df = df.drop(columns=to_drop)

        # 填充剩余缺失值
        for col in df.columns:
            if df[col].dtype == 'object':
                df[col] = df[col].fillna('unknown')
            else:
                df[col] = df[col].fillna(df[col].median())
        return df

    def encode_categorical(self, df: pd.DataFrame, cat_cols: List[str]) -> pd.DataFrame:
        """分类变量编码"""
        from sklearn.preprocessing import LabelEncoder
        for col in cat_cols:
            le = LabelEncoder()
            df[col] = le.fit_transform(df[col].astype(str))
            self.encoders[col] = le
        return df

    def detect_outliers(self, df: pd.DataFrame) -> Dict[str, Dict]:
        """检测异常值"""
        outlier_info = {}
        numeric_cols = df.select_dtypes(include=np.number).columns

        for col in numeric_cols:
            q1 = df[col].quantile(0.25)
            q3 = df[col].quantile(0.75)
            iqr = q3 - q1
            lower = q1 - 1.5 * iqr
            upper = q3 + 1.5 * iqr

            outliers = df[(df[col] < lower) | (df[col] > upper)][col]
            outlier_info[col] = {
                'count': len(outliers),
                'ratio': len(outliers)/len(df),
                'values': outliers.unique().tolist()
            }
        return outlier_info
