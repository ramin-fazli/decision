"""
Decision Tree model implementation for investment prediction.
"""

import numpy as np
import pandas as pd
from typing import Dict, Any, List, Optional, Union
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor
from sklearn.preprocessing import StandardScaler, LabelEncoder
import joblib
import logging
from datetime import datetime

from ml.models.base import BaseModel

logger = logging.getLogger(__name__)


class DecisionTreeModel(BaseModel):
    """
    Decision Tree model for investment outcome prediction.
    
    This model uses decision trees to make interpretable predictions
    about investment success based on company and market features.
    """
    
    def __init__(self, model_type: str = "classifier", **kwargs):
        super().__init__(
            model_name="decision_tree",
            model_type=model_type
        )
        self.model_type = model_type
        self.model_name = "decision_tree"
        self.version = "1.0.0"
        
        # Model parameters with defaults
        default_params = {
            "max_depth": 10,
            "min_samples_split": 5,
            "min_samples_leaf": 2,
            "random_state": 42,
            "class_weight": "balanced" if model_type == "classifier" else None
        }
        default_params.update(kwargs)
        
        # Initialize the sklearn model
        if model_type == "classifier":
            self.model = DecisionTreeClassifier(**default_params)
        else:
            self.model = DecisionTreeRegressor(**{k: v for k, v in default_params.items() if k != "class_weight"})
        
        self.scaler = StandardScaler()
        self.label_encoders = {}
        self.feature_names = []
        self.is_trained = False
        
    def preprocess_features(self, features: Dict[str, Any]) -> np.ndarray:
        """Preprocess input features for the model"""
        try:
            # Convert to DataFrame for easier processing
            df = pd.DataFrame([features])
            
            # Handle categorical features
            categorical_columns = []
            for col in df.columns:
                if df[col].dtype == 'object' or isinstance(df[col].iloc[0], str):
                    categorical_columns.append(col)
            
            # Encode categorical variables
            for col in categorical_columns:
                if col not in self.label_encoders:
                    # Create new encoder if not exists (for training)
                    self.label_encoders[col] = LabelEncoder()
                    # Fit with common values
                    common_values = self._get_common_values(col)
                    self.label_encoders[col].fit(common_values)
                
                try:
                    df[col] = self.label_encoders[col].transform(df[col])
                except ValueError:
                    # Handle unseen categories
                    df[col] = 0
            
            # Ensure all features are numeric
            df = df.apply(pd.to_numeric, errors='coerce').fillna(0)
            
            # Scale features if scaler is fitted
            if hasattr(self.scaler, 'mean_'):
                processed_features = self.scaler.transform(df.values)
            else:
                processed_features = df.values
            
            return processed_features.flatten()
            
        except Exception as e:
            logger.error(f"Error preprocessing features: {e}")
            # Return zeros if preprocessing fails
            return np.zeros(len(self.feature_names) if self.feature_names else 10)
    
    def _get_common_values(self, column: str) -> List[str]:
        """Get common values for categorical encoding"""
        common_values_map = {
            "funding_stage": ["Pre-Seed", "Seed", "Series A", "Series B", "Series C", "Later Stage"],
            "sector": ["AI/ML", "FinTech", "HealthTech", "E-commerce", "SaaS", "Biotech", "CleanTech"],
            "competition_level": ["low", "medium", "high"],
            "geography": ["North America", "Europe", "Asia", "Other"],
            "business_model": ["B2B", "B2C", "B2B2C", "Marketplace", "SaaS", "Hardware"]
        }
        return common_values_map.get(column, ["unknown", "other", "standard"])
    
    async def train(self, X: pd.DataFrame, y: pd.Series, validation_split: float = 0.2) -> Dict[str, Any]:
        """Train the decision tree model"""
        try:
            logger.info(f"Training {self.model_name} with {len(X)} samples")
            
            # Store feature names
            self.feature_names = list(X.columns)
            
            # Convert to numpy arrays
            X_array = X.values
            y_array = y.values
            
            # Fit scaler on training data
            self.scaler.fit(X)
            X_scaled = self.scaler.transform(X)
            
            # Train the model
            self.model.fit(X_scaled, y)
            self.is_trained = True
            
            # Calculate training metrics
            train_score = self.model.score(X_scaled, y)
            feature_importance = self.model.feature_importances_
            
            logger.info(f"Training completed. Score: {train_score:.4f}")
            
            return {
                "training_score": train_score,
                "feature_importance": dict(zip(self.feature_names, feature_importance)),
                "model_depth": self.model.tree_.max_depth,
                "n_leaves": self.model.tree_.n_leaves,
                "status": "success"
            }
            
        except Exception as e:
            logger.error(f"Training failed: {e}")
            return {"status": "failed", "error": str(e)}
    
    async def predict(self, features: Union[Dict[str, Any], pd.DataFrame]) -> Any:
        """Make prediction using the trained model"""
        if not self.is_trained:
            return {"error": "Model not trained"}
        
        try:
            # Convert features to the right format
            if isinstance(features, dict):
                df = pd.DataFrame([features])
            else:
                df = features
            
            # Scale features
            X_scaled = self.scaler.transform(df.values)
            
            # Make prediction
            if self.model_type == "classifier":
                prediction = self.model.predict(X_scaled)[0]
                probabilities = self.model.predict_proba(X_scaled)[0]
                confidence = np.max(probabilities)
                
                return {
                    "prediction": int(prediction),
                    "confidence": float(confidence),
                    "probabilities": probabilities.tolist(),
                    "model_name": self.model_name,
                    "model_version": self.version
                }
            else:
                prediction = self.model.predict(X_scaled)[0]
                
                return {
                    "prediction": float(prediction),
                    "model_name": self.model_name,
                    "model_version": self.version
                }
                
        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            return {"error": str(e)}
    
    async def predict_proba(self, features: Union[Dict[str, Any], pd.DataFrame]) -> Optional[float]:
        """Get prediction probability/confidence."""
        if not self.is_trained:
            return None
        
        try:
            # Convert features to the right format
            if isinstance(features, dict):
                df = pd.DataFrame([features])
            else:
                df = features
            
            # Scale features
            X_scaled = self.scaler.transform(df.values)
            
            # Get probability for classification
            if self.model_type == "classifier" and hasattr(self.model, 'predict_proba'):
                probabilities = self.model.predict_proba(X_scaled)[0]
                return float(np.max(probabilities))
            else:
                # For regression, return None or some confidence measure
                return None
                
        except Exception as e:
            logger.error(f"Probability prediction failed: {e}")
            return None
    
    def get_feature_importance(self) -> Dict[str, float]:
        """Get feature importance from the trained model"""
        if not self.is_trained:
            return {}
        
        importance_scores = self.model.feature_importances_
        return dict(zip(self.feature_names, importance_scores))
    
    def save_model(self, filepath: str) -> bool:
        """Save the trained model to disk"""
        try:
            model_data = {
                "model": self.model,
                "scaler": self.scaler,
                "label_encoders": self.label_encoders,
                "feature_names": self.feature_names,
                "model_name": self.model_name,
                "version": self.version,
                "model_type": self.model_type,
                "is_trained": self.is_trained
            }
            joblib.dump(model_data, filepath)
            logger.info(f"Model saved to {filepath}")
            return True
        except Exception as e:
            logger.error(f"Failed to save model: {e}")
            return False
    
    def load_model(self, filepath: str) -> bool:
        """Load a trained model from disk"""
        try:
            model_data = joblib.load(filepath)
            self.model = model_data["model"]
            self.scaler = model_data["scaler"]
            self.label_encoders = model_data["label_encoders"]
            self.feature_names = model_data["feature_names"]
            self.model_name = model_data["model_name"]
            self.version = model_data["version"]
            self.model_type = model_data["model_type"]
            self.is_trained = model_data["is_trained"]
            logger.info(f"Model loaded from {filepath}")
            return True
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            return False
