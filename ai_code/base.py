from typing import Dict, List, Union, Optional
import pandas as pd
import numpy as np
from dataclasses import dataclass

@dataclass
class ColumnInfo:
    name: str
    dtype: str
    unique_count: int
    missing_ratio: float
    iv_value: Optional[float] = None

class BaseProcessor:
    def __init__(self, config_path: str = None):
        self.config = self._load_config(config_path) if config_path else {}

    def _load_config(self, path: str) -> Dict:
        import yaml
        with open(path) as f:
            return yaml.safe_load(f)

    def get_column_stats(self, df: pd.DataFrame) -> Dict[str, ColumnInfo]:
        stats = {}
        for col in df.columns:
            stats[col] = ColumnInfo(
                name=col,
                dtype=str(df[col].dtype),
                unique_count=df[col].nunique(),
                missing_ratio=df[col].isnull().mean()
            )
        return stats
