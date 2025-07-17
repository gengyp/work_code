import pandas as pd
import numpy as np
from typing import Dict
from .base import BaseProcessor

class WOETransformer(BaseProcessor):
    def __init__(self, config_path: str = None):
        super().__init__(config_path)
        self.woe_dict = {}
        self.iv_dict = {}

    def fit(self, df: pd.DataFrame, target: pd.Series):
        """计算WOE和IV"""
        self.woe_dict = {}
        self.iv_dict = {}

        for col in df.columns:
            woe_iv = self._calculate_woe_iv(df[col], target)
            self.woe_dict[col] = woe_iv['woe']
            self.iv_dict[col] = woe_iv['iv']

    def _calculate_woe_iv(self, series: pd.Series, target: pd.Series) -> Dict:
        """计算单个变量的WOE和IV"""
        df = pd.DataFrame({'x': series, 'y': target})
        grouped = df.groupby('x')['y'].agg(['count', 'sum'])
        grouped.columns = ['total', 'bad']
        grouped['good'] = grouped['total'] - grouped['bad']

        total_bad = grouped['bad'].sum()
        total_good = grouped['good'].sum()

        grouped['bad_rate'] = grouped['bad'] / total_bad
        grouped['good_rate'] = grouped['good'] / total_good
        grouped['woe'] = np.log(grouped['bad_rate'] / grouped['good_rate'])
        grouped['iv'] = (grouped['bad_rate'] - grouped['good_rate']) * grouped['woe']

        return {
            'woe': grouped['woe'].to_dict(),
            'iv': grouped['iv'].sum()
        }

    def transform(self, df: pd.DataFrame) -> pd.DataFrame:
        """应用WOE转换"""
        woe_df = pd.DataFrame(index=df.index)
        for col in df.columns:
            woe_df[col] = df[col].map(self.woe_dict[col])
        return woe_df
