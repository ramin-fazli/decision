"""
Base model class for Decision platform ML models.
Defines the interface that all ML models must implement.
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional, Union
from datetime import datetime
import pandas as pd
import numpy as np
import logging

logger = logging.getLogger(__name__)


class BaseModel(ABC):
    """
    Abstract base class for all ML models in the Decision platform.
    
    This class defines the interface that all models must implement,
    ensuring consistency across different model types.
    """
    
    def __init__(self, model_name: str, model_type: str):
        self.model_name = model_name
        self.model_type = model_type
        self.version = "1.0.0"
        self.description = ""
        self.feature_names: List[str] = []
        self.performance_metrics: Dict[str, float] = {}
        self.training_date: Optional[datetime] = None
        self.is_trained = False
        self._model = None
    
    @abstractmethod
    async def train(
        self,
        X: pd.DataFrame,
        y: pd.Series,
        validation_split: float = 0.2
    ) -> Dict[str, Any]:
        """
        Train the model with provided data.
        
        Args:
            X: Feature matrix
            y: Target vector
            validation_split: Fraction of data to use for validation
        
        Returns:
            Dictionary containing training results and metrics
        """
        pass
    
    @abstractmethod
    async def predict(self, features: Union[Dict[str, Any], pd.DataFrame]) -> Any:
        """
        Make a single prediction.
        
        Args:
            features: Input features as dictionary or DataFrame row
        
        Returns:
            Prediction result
        """
        pass
    
    @abstractmethod
    async def predict_proba(
        self,
        features: Union[Dict[str, Any], pd.DataFrame]
    ) -> Optional[float]:
        """
        Get prediction probability/confidence.
        
        Args:
            features: Input features as dictionary or DataFrame row
        
        Returns:
            Prediction probability or None if not applicable
        """
        pass
    
    async def predict_batch(
        self,
        features_list: List[Union[Dict[str, Any], pd.DataFrame]]
    ) -> List[Any]:
        """
        Make batch predictions.
        
        Args:
            features_list: List of feature sets
        
        Returns:
            List of predictions
        """
        predictions = []
        for features in features_list:
            prediction = await self.predict(features)
            predictions.append(prediction)
        return predictions
    
    async def predict_proba_batch(
        self,
        features_list: List[Union[Dict[str, Any], pd.DataFrame]]
    ) -> List[Optional[float]]:
        """
        Get batch prediction probabilities.
        
        Args:
            features_list: List of feature sets
        
        Returns:
            List of prediction probabilities
        """
        probabilities = []
        for features in features_list:
            proba = await self.predict_proba(features)
            probabilities.append(proba)
        return probabilities
    
    @abstractmethod
    def get_feature_importance(self) -> Dict[str, float]:
        """
        Get feature importance scores.
        
        Returns:
            Dictionary mapping feature names to importance scores
        """
        pass
    
    def get_dummy_features(self) -> Dict[str, Any]:
        """
        Generate dummy features for testing.
        
        Returns:
            Dictionary of dummy feature values
        """
        if not self.feature_names:
            return {}
        
        dummy_features = {}
        for feature in self.feature_names:
            # Generate appropriate dummy values based on feature name patterns
            if any(keyword in feature.lower() for keyword in ['amount', 'funding', 'revenue', 'valuation']):
                dummy_features[feature] = 1000000.0  # Financial amounts
            elif any(keyword in feature.lower() for keyword in ['age', 'years', 'months']):
                dummy_features[feature] = 2.0  # Time periods
            elif any(keyword in feature.lower() for keyword in ['count', 'number', 'total']):
                dummy_features[feature] = 5  # Counts
            elif any(keyword in feature.lower() for keyword in ['rate', 'ratio', 'percentage']):
                dummy_features[feature] = 0.1  # Rates/ratios
            elif feature.lower().endswith('_categorical'):
                dummy_features[feature] = 'category_a'  # Categorical
            else:
                dummy_features[feature] = 1.0  # Default numeric
        
        return dummy_features
    
    def save_model(self, path: str) -> bool:
        """
        Save the trained model to disk.
        
        Args:
            path: Path to save the model
        
        Returns:
            True if successful, False otherwise
        """
        try:
            import pickle
            from pathlib import Path
            
            model_data = {
                'model': self._model,
                'model_name': self.model_name,
                'model_type': self.model_type,
                'version': self.version,
                'feature_names': self.feature_names,
                'performance_metrics': self.performance_metrics,
                'training_date': self.training_date,
                'is_trained': self.is_trained
            }
            
            Path(path).parent.mkdir(parents=True, exist_ok=True)
            
            with open(path, 'wb') as f:
                pickle.dump(model_data, f)
            
            logger.info(f"Model {self.model_name} saved to {path}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to save model {self.model_name}: {e}")
            return False
    
    def load_model(self, path: str) -> bool:
        """
        Load a trained model from disk.
        
        Args:
            path: Path to load the model from
        
        Returns:
            True if successful, False otherwise
        """
        try:
            import pickle
            
            with open(path, 'rb') as f:
                model_data = pickle.load(f)
            
            self._model = model_data['model']
            self.model_name = model_data['model_name']
            self.model_type = model_data['model_type']
            self.version = model_data['version']
            self.feature_names = model_data['feature_names']
            self.performance_metrics = model_data['performance_metrics']
            self.training_date = model_data['training_date']
            self.is_trained = model_data['is_trained']
            
            logger.info(f"Model {self.model_name} loaded from {path}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to load model {self.model_name}: {e}")
            return False
    
    def validate_features(self, features: Dict[str, Any]) -> bool:
        """
        Validate input features against expected feature names.
        
        Args:
            features: Input features to validate
        
        Returns:
            True if valid, False otherwise
        """
        if not self.feature_names:
            return True  # No validation if feature names not set
        
        missing_features = set(self.feature_names) - set(features.keys())
        if missing_features:
            logger.warning(f"Missing features: {missing_features}")
            return False
        
        return True
    
    def get_model_summary(self) -> Dict[str, Any]:
        """
        Get a summary of the model's configuration and performance.
        
        Returns:
            Dictionary containing model summary
        """
        return {
            'name': self.model_name,
            'type': self.model_type,
            'version': self.version,
            'description': self.description,
            'is_trained': self.is_trained,
            'training_date': self.training_date.isoformat() if self.training_date else None,
            'feature_count': len(self.feature_names),
            'features': self.feature_names,
            'performance_metrics': self.performance_metrics
        }
