"""
Random Forest model implementation for Decision platform.
Based on the thesis research, implementing Random Forest for startup success prediction.
"""

from typing import Dict, Any, List, Optional, Union
from datetime import datetime
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
import logging

from ml.models.base import BaseModel

logger = logging.getLogger(__name__)


class RandomForestModel(BaseModel):
    """
    Random Forest model implementation for investment decision support.
    
    This model is based on the research findings from the master's thesis
    "The Impact of AI-powered Decision-Making on Venture Capital Investments".
    """
    
    def __init__(self):
        super().__init__(
            model_name="random_forest",
            model_type="ensemble"
        )
        self.description = "Random Forest model for startup success prediction"
        
        # Model hyperparameters (optimized based on thesis research)
        self.n_estimators = 100
        self.max_depth = 10
        self.min_samples_split = 5
        self.min_samples_leaf = 2
        self.random_state = 42
        
        # Expected features based on Crunchbase data structure
        self.feature_names = [
            'funding_total_usd',
            'funding_rounds',
            'founded_at_year',
            'category_code',
            'country_code',
            'state_code',
            'region',
            'city',
            'employee_count',
            'has_angel_investors',
            'has_vc_investors',
            'time_to_first_funding',
            'last_funding_at_year',
            'first_funding_at_year'
        ]
        
        # Initialize the sklearn model
        self._initialize_model()
    
    def _initialize_model(self):
        """Initialize the sklearn Random Forest model"""
        self._model = RandomForestClassifier(
            n_estimators=self.n_estimators,
            max_depth=self.max_depth,
            min_samples_split=self.min_samples_split,
            min_samples_leaf=self.min_samples_leaf,
            random_state=self.random_state,
            n_jobs=-1  # Use all available cores
        )
    
    async def train(
        self,
        X: pd.DataFrame,
        y: pd.Series,
        validation_split: float = 0.2
    ) -> Dict[str, Any]:
        """
        Train the Random Forest model.
        
        Args:
            X: Feature matrix
            y: Target vector (0 for failure, 1 for success)
            validation_split: Fraction of data to use for validation
        
        Returns:
            Dictionary containing training results and metrics
        """
        try:
            logger.info("Starting Random Forest model training...")
            
            # Split data into training and validation sets
            X_train, X_val, y_train, y_val = train_test_split(
                X, y, test_size=validation_split, random_state=self.random_state,
                stratify=y
            )
            
            # Train the model
            self._model.fit(X_train, y_train)
            
            # Make predictions on validation set
            y_pred = self._model.predict(X_val)
            y_pred_proba = self._model.predict_proba(X_val)[:, 1]
            
            # Calculate performance metrics
            metrics = {
                'accuracy': accuracy_score(y_val, y_pred),
                'precision': precision_score(y_val, y_pred, average='weighted'),
                'recall': recall_score(y_val, y_pred, average='weighted'),
                'f1_score': f1_score(y_val, y_pred, average='weighted'),
                'roc_auc': roc_auc_score(y_val, y_pred_proba) if len(np.unique(y_val)) > 1 else 0.0
            }
            
            # Perform cross-validation
            cv_scores = cross_val_score(
                self._model,
                X_train,
                y_train,
                cv=5,
                scoring='accuracy'
            )
            
            metrics['cv_mean'] = cv_scores.mean()
            metrics['cv_std'] = cv_scores.std()
            
            # Update model metadata
            self.performance_metrics = metrics
            self.training_date = datetime.now()
            self.is_trained = True
            self.feature_names = list(X.columns)
            
            logger.info(f"Random Forest training completed. Accuracy: {metrics['accuracy']:.4f}")
            
            return {
                'success': True,
                'metrics': metrics,
                'training_samples': len(X_train),
                'validation_samples': len(X_val),
                'feature_count': len(self.feature_names),
                'cv_scores': cv_scores.tolist()
            }
            
        except Exception as e:
            logger.error(f"Random Forest training failed: {e}")
            raise
    
    async def predict(self, features: Union[Dict[str, Any], pd.DataFrame]) -> int:
        """
        Make a single prediction.
        
        Args:
            features: Input features as dictionary or DataFrame row
        
        Returns:
            Prediction (0 for failure, 1 for success)
        """
        if not self.is_trained:
            raise ValueError("Model must be trained before making predictions")
        
        try:
            # Convert features to DataFrame if needed
            if isinstance(features, dict):
                df = pd.DataFrame([features])
            else:
                df = features
            
            # Ensure all required features are present
            if not self.validate_features(features if isinstance(features, dict) else features.to_dict()):
                raise ValueError("Invalid features provided")
            
            # Make prediction
            prediction = self._model.predict(df)[0]
            return int(prediction)
            
        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            raise
    
    async def predict_proba(
        self,
        features: Union[Dict[str, Any], pd.DataFrame]
    ) -> float:
        """
        Get prediction probability for success class.
        
        Args:
            features: Input features as dictionary or DataFrame row
        
        Returns:
            Probability of success (between 0 and 1)
        """
        if not self.is_trained:
            raise ValueError("Model must be trained before making predictions")
        
        try:
            # Convert features to DataFrame if needed
            if isinstance(features, dict):
                df = pd.DataFrame([features])
            else:
                df = features
            
            # Get probability for success class (class 1)
            probabilities = self._model.predict_proba(df)
            return float(probabilities[0][1])
            
        except Exception as e:
            logger.error(f"Probability prediction failed: {e}")
            raise
    
    def get_feature_importance(self) -> Dict[str, float]:
        """
        Get feature importance scores from the trained Random Forest.
        
        Returns:
            Dictionary mapping feature names to importance scores
        """
        if not self.is_trained:
            raise ValueError("Model must be trained to get feature importance")
        
        try:
            importances = self._model.feature_importances_
            feature_importance = dict(zip(self.feature_names, importances))
            
            # Sort by importance (descending)
            return dict(sorted(feature_importance.items(), key=lambda x: x[1], reverse=True))
            
        except Exception as e:
            logger.error(f"Failed to get feature importance: {e}")
            return {}
    
    def get_tree_info(self) -> Dict[str, Any]:
        """
        Get information about the Random Forest trees.
        
        Returns:
            Dictionary containing tree statistics
        """
        if not self.is_trained:
            return {}
        
        try:
            return {
                'n_estimators': self._model.n_estimators,
                'max_depth': self._model.max_depth,
                'min_samples_split': self._model.min_samples_split,
                'min_samples_leaf': self._model.min_samples_leaf,
                'n_features': self._model.n_features_in_,
                'n_classes': len(self._model.classes_)
            }
            
        except Exception as e:
            logger.error(f"Failed to get tree info: {e}")
            return {}
    
    def get_model_summary(self) -> Dict[str, Any]:
        """
        Get comprehensive model summary including Random Forest specific info.
        
        Returns:
            Dictionary containing detailed model information
        """
        summary = super().get_model_summary()
        summary.update({
            'model_parameters': {
                'n_estimators': self.n_estimators,
                'max_depth': self.max_depth,
                'min_samples_split': self.min_samples_split,
                'min_samples_leaf': self.min_samples_leaf,
                'random_state': self.random_state
            },
            'tree_info': self.get_tree_info(),
            'feature_importance': self.get_feature_importance() if self.is_trained else {}
        })
        return summary
