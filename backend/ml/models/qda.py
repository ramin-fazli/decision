"""
Quadratic Discriminant Analysis (QDA) model implementation for investment prediction.
"""

import numpy as np
import pandas as pd
from typing import Dict, Any, List, Optional
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis
from sklearn.preprocessing import StandardScaler, LabelEncoder
import joblib
import logging

from ml.models.base import BaseModel

logger = logging.getLogger(__name__)


class QDAModel(BaseModel):
    """
    Quadratic Discriminant Analysis model for investment outcome prediction.
    
    QDA is particularly useful when the assumption of equal covariance matrices
    across classes is violated (unlike LDA). It can capture quadratic decision
    boundaries and is effective for investment classification tasks.
    """
    
    def __init__(self, **kwargs):
        super().__init__()
        self.model_name = "qda"
        self.version = "1.0.0"
        
        # QDA parameters with defaults
        default_params = {
            "priors": None,
            "reg_param": 0.0,
            "store_covariance": False,
            "tol": 1.0e-4
        }
        default_params.update(kwargs)
        
        # Initialize the sklearn QDA model
        self.model = QuadraticDiscriminantAnalysis(**default_params)
        self.scaler = StandardScaler()
        self.label_encoders = {}
        self.feature_names = []
        self.is_trained = False
        
    def preprocess_features(self, features: Dict[str, Any]) -> np.ndarray:
        """Preprocess input features for QDA"""
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
    
    def train(self, training_data: List[Dict[str, Any]], targets: List[Any]) -> Dict[str, Any]:
        """Train the QDA model"""
        try:
            logger.info(f"Training {self.model_name} with {len(training_data)} samples")
            
            # Convert training data to DataFrame
            df = pd.DataFrame(training_data)
            self.feature_names = list(df.columns)
            
            # Preprocess features
            X_processed = []
            for features in training_data:
                processed = self.preprocess_features(features)
                X_processed.append(processed)
            
            X = np.array(X_processed)
            y = np.array(targets)
            
            # Fit scaler on training data
            self.scaler.fit(X)
            X_scaled = self.scaler.transform(X)
            
            # Train the model
            self.model.fit(X_scaled, y)
            self.is_trained = True
            
            # Calculate training metrics
            train_score = self.model.score(X_scaled, y)
            
            logger.info(f"Training completed. Accuracy: {train_score:.4f}")
            
            # Get class information
            classes = self.model.classes_
            priors = self.model.priors_ if hasattr(self.model, 'priors_') else None
            
            return {
                "training_accuracy": train_score,
                "n_classes": len(classes),
                "classes": classes.tolist() if hasattr(classes, 'tolist') else list(classes),
                "priors": priors.tolist() if priors is not None else None,
                "n_features": X_scaled.shape[1],
                "status": "success"
            }
            
        except Exception as e:
            logger.error(f"Training failed: {e}")
            return {"status": "failed", "error": str(e)}
    
    def predict(self, features: Dict[str, Any]) -> Dict[str, Any]:
        """Make prediction using the trained QDA model"""
        if not self.is_trained:
            return {"error": "Model not trained"}
        
        try:
            # Preprocess features
            processed_features = self.preprocess_features(features)
            X = processed_features.reshape(1, -1)
            
            # Scale features
            X_scaled = self.scaler.transform(X)
            
            # Make prediction
            prediction = self.model.predict(X_scaled)[0]
            probabilities = self.model.predict_proba(X_scaled)[0]
            confidence = np.max(probabilities)
            
            # Get decision function values (distance from separating hyperplane)
            decision_function = self.model.decision_function(X_scaled)[0]
            
            return {
                "prediction": int(prediction),
                "confidence": float(confidence),
                "probabilities": probabilities.tolist(),
                "decision_function": decision_function.tolist() if hasattr(decision_function, 'tolist') else float(decision_function),
                "model_name": self.model_name,
                "model_version": self.version
            }
                
        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            return {"error": str(e)}
    
    def get_feature_importance(self) -> Dict[str, float]:
        """
        Get feature importance for QDA.
        Since QDA doesn't have built-in feature importance, we use the
        average magnitude of coefficients across all classes.
        """
        if not self.is_trained or not hasattr(self.model, 'coef_'):
            return {}
        
        try:
            # For QDA, we look at the magnitude of the linear terms
            # in the quadratic discriminant function
            if hasattr(self.model, 'coef_') and self.model.coef_ is not None:
                # Average absolute coefficients across classes
                feature_importance = np.mean(np.abs(self.model.coef_), axis=0)
                
                # Normalize to sum to 1
                feature_importance = feature_importance / np.sum(feature_importance)
                
                return dict(zip(self.feature_names, feature_importance))
            else:
                # If no coefficients available, return equal importance
                n_features = len(self.feature_names)
                equal_importance = 1.0 / n_features
                return {name: equal_importance for name in self.feature_names}
                
        except Exception as e:
            logger.error(f"Error calculating feature importance: {e}")
            return {}
    
    def get_model_info(self) -> Dict[str, Any]:
        """Get information about the QDA model"""
        if not self.is_trained:
            return {}
        
        info = {
            "model_type": "Quadratic Discriminant Analysis",
            "n_features": len(self.feature_names),
            "n_classes": len(self.model.classes_),
            "classes": self.model.classes_.tolist(),
            "regularization": self.model.reg_param,
            "tolerance": self.model.tol
        }
        
        # Add priors if available
        if hasattr(self.model, 'priors_') and self.model.priors_ is not None:
            info["priors"] = self.model.priors_.tolist()
        
        # Add covariance information if stored
        if hasattr(self.model, 'covariance_') and self.model.covariance_ is not None:
            info["stores_covariance"] = True
            info["covariance_shape"] = [cov.shape for cov in self.model.covariance_]
        
        return info
    
    def get_class_statistics(self) -> Dict[str, Any]:
        """Get statistics for each class"""
        if not self.is_trained:
            return {}
        
        try:
            stats = {}
            
            # Get class means if available
            if hasattr(self.model, 'means_'):
                stats["class_means"] = {
                    str(cls): means.tolist() 
                    for cls, means in zip(self.model.classes_, self.model.means_)
                }
            
            # Get class priors
            if hasattr(self.model, 'priors_'):
                stats["class_priors"] = {
                    str(cls): float(prior) 
                    for cls, prior in zip(self.model.classes_, self.model.priors_)
                }
            
            return stats
            
        except Exception as e:
            logger.error(f"Error getting class statistics: {e}")
            return {}
    
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
            self.is_trained = model_data["is_trained"]
            logger.info(f"Model loaded from {filepath}")
            return True
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            return False
