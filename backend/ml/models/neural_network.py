"""
Neural Network model implementation for investment prediction.
"""

import numpy as np
import pandas as pd
from typing import Dict, Any, List, Optional, Tuple
from sklearn.neural_network import MLPClassifier, MLPRegressor
from sklearn.preprocessing import StandardScaler, LabelEncoder
import joblib
import logging

from ml.models.base import BaseModel

logger = logging.getLogger(__name__)


class NeuralNetworkModel(BaseModel):
    """
    Neural Network model for investment outcome prediction.
    
    This model uses multi-layer perceptrons to capture complex
    non-linear relationships in investment data.
    """
    
    def __init__(self, model_type: str = "classifier", **kwargs):
        super().__init__()
        self.model_type = model_type
        self.model_name = "neural_network"
        self.version = "1.0.0"
        
        # Model parameters with defaults
        default_params = {
            "hidden_layer_sizes": (100, 50),
            "activation": "relu",
            "solver": "adam",
            "alpha": 0.0001,
            "learning_rate": "constant",
            "learning_rate_init": 0.001,
            "max_iter": 1000,
            "random_state": 42,
            "early_stopping": True,
            "validation_fraction": 0.1,
            "n_iter_no_change": 10
        }
        default_params.update(kwargs)
        
        # Initialize the sklearn model
        if model_type == "classifier":
            self.model = MLPClassifier(**default_params)
        else:
            self.model = MLPRegressor(**default_params)
        
        self.scaler = StandardScaler()
        self.label_encoders = {}
        self.feature_names = []
        self.is_trained = False
        
    def preprocess_features(self, features: Dict[str, Any]) -> np.ndarray:
        """Preprocess input features for the neural network"""
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
        """Train the neural network model"""
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
            
            logger.info(f"Training completed. Score: {train_score:.4f}")
            logger.info(f"Number of iterations: {self.model.n_iter_}")
            logger.info(f"Loss: {self.model.loss_}")
            
            return {
                "training_score": train_score,
                "n_iterations": int(self.model.n_iter_),
                "final_loss": float(self.model.loss_),
                "n_layers": len(self.model.coefs_),
                "convergence": "converged" if self.model.n_iter_ < self.model.max_iter else "max_iter_reached",
                "status": "success"
            }
            
        except Exception as e:
            logger.error(f"Training failed: {e}")
            return {"status": "failed", "error": str(e)}
    
    def predict(self, features: Dict[str, Any]) -> Dict[str, Any]:
        """Make prediction using the trained neural network"""
        if not self.is_trained:
            return {"error": "Model not trained"}
        
        try:
            # Preprocess features
            processed_features = self.preprocess_features(features)
            X = processed_features.reshape(1, -1)
            
            # Scale features
            X_scaled = self.scaler.transform(X)
            
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
    
    def get_feature_importance(self) -> Dict[str, float]:
        """
        Get feature importance approximation for neural networks.
        This uses the mean absolute weight of connections from input layer.
        """
        if not self.is_trained or not hasattr(self.model, 'coefs_'):
            return {}
        
        # Get weights from input layer to first hidden layer
        input_weights = np.abs(self.model.coefs_[0])
        
        # Calculate mean absolute weight for each input feature
        feature_importance = np.mean(input_weights, axis=1)
        
        # Normalize to sum to 1
        feature_importance = feature_importance / np.sum(feature_importance)
        
        return dict(zip(self.feature_names, feature_importance))
    
    def get_network_info(self) -> Dict[str, Any]:
        """Get information about the neural network architecture"""
        if not self.is_trained:
            return {}
        
        return {
            "n_layers": len(self.model.coefs_),
            "layer_sizes": [coef.shape[0] for coef in self.model.coefs_] + [self.model.coefs_[-1].shape[1]],
            "total_parameters": sum(coef.size + intercept.size for coef, intercept in zip(self.model.coefs_, self.model.intercepts_)),
            "activation_function": self.model.activation,
            "solver": self.model.solver,
            "learning_rate": self.model.learning_rate_init,
            "alpha": self.model.alpha
        }
    
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
