import pandas as pd
import yaml
from pathlib import Path
from .preprocessor import DataPreprocessor
from .binning import BinningProcessor
from .woe import WOETransformer
from .feature_selector import FeatureSelector
from .scorecard import ScorecardModel

class ScorecardPipeline:
    def __init__(self, config_path: str = 'config.yaml'):
        self.config_path = config_path
        self.preprocessor = DataPreprocessor(config_path)
        self.binner = BinningProcessor(config_path)
        self.woe_transformer = WOETransformer(config_path)
        self.selector = FeatureSelector(config_path)
        self.model = ScorecardModel(config_path)

    def run(self, data_path: str, target_col: str):
        # 1. 数据加载
        df = pd.read_csv(data_path)
        target = df[target_col]

        # 2. 数据预处理
        print("Preprocessing data...")
        df = self.preprocessor.handle_missing_values(df)
        cat_cols = [col for col in df.columns if df[col].dtype == 'object']
        df = self.preprocessor.encode_categorical(df, cat_cols)

        # 3. 变量分箱
        print("Binning variables...")
        self.binner.fit(df, target, cat_cols)
        binned_df = self.binner.transform(df)

        # 4. WOE转换
        print("Calculating WOE...")
        self.woe_transformer.fit(binned_df, target)
        woe_df = self.woe_transformer.transform(binned_df)

        # 5. 特征选择
        print("Selecting features...")
        selected_df = self.selector.select_features(woe_df, target, self.woe_transformer.iv_dict)

        # 6. 模型训练
        print("Training model...")
        self.model.train(selected_df, target)

        # 7. 结果输出
        print("Generating report...")
        report = {
            'model': self.model.get_model_report(),
            'iv_values': self.woe_transformer.iv_dict,
            'selected_features': self.selector.selected_features,
            'binning_info': self.binner.bin_info
        }

        return report

if __name__ == "__main__":
    pipeline = ScorecardPipeline()
    report = pipeline.run('data.csv', 'target')
    print(report)
