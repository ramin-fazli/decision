"""
Core ML Engine for Decision platform.
Manages model loading, inference, and explainability.
"""

import asyncio
import pickle
import logging
from typing import Dict, Any, List, Optional, Union
from pathlib import Path
import pandas as pd
import numpy as np

from ml.models.base import BaseModel
from ml.models.decision_tree import DecisionTreeModel
from ml.models.random_forest import RandomForestModel
from ml.models.neural_network import NeuralNetworkModel
from ml.models.qda import QDAModel
from ml.features.extractors import FeatureExtractor
from ml.explainability.shap_explainer import SHAPExplainer
from ml.explainability.lime_explainer import LIMEExplainer
from core.config import settings

logger = logging.getLogger(__name__)


class MLEngine:
    """
    Core ML Engine that orchestrates model operations.
    Handles model loading, prediction, and explainability.
    """
    
    def __init__(self):
        self.models: Dict[str, BaseModel] = {}
        self.feature_extractor = FeatureExtractor()
        self.shap_explainer = SHAPExplainer()
        self.lime_explainer = LIMEExplainer()
        self._load_models()
    
    def _load_models(self):
        """Load all available models"""
        try:
            # Initialize model registry
            model_classes = {
                "decision_tree": DecisionTreeModel,
                "random_forest": RandomForestModel,
                "neural_network": NeuralNetworkModel,
                "qda": QDAModel
            }
            
            for model_name, model_class in model_classes.items():
                try:
                    # Try to create instance with different initialization approaches
                    try:
                        model = model_class()
                    except TypeError:
                        # Try with model_type parameter for models that need it
                        model = model_class(model_type="classifier")
                    
                    self.models[model_name] = model
                    logger.info(f"Loaded model: {model_name}")
                except Exception as e:
                    logger.warning(f"Failed to load model {model_name}: {e}")
                    # Continue loading other models
            
            logger.info(f"ML Engine initialized with {len(self.models)} models")
            
        except Exception as e:
            logger.error(f"Failed to initialize ML Engine: {e}")
            # Don't raise - allow the engine to start with whatever models loaded
            logger.warning("ML Engine starting with limited model support")
    
    async def predict(
        self,
        model_name: str,
        features: Dict[str, Any],
        model_version: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Make a single prediction using the specified model.
        
        Args:
            model_name: Name of the model to use
            features: Input features as dictionary
            model_version: Specific model version (optional)
        
        Returns:
            Dictionary containing prediction and confidence
        """
        if model_name not in self.models:
            raise ValueError(f"Model '{model_name}' not found")
        
        model = self.models[model_name]
        
        try:
            # Extract and transform features
            processed_features = await self.feature_extractor.extract(features)
            
            # Make prediction
            prediction = await model.predict(processed_features)
            confidence = await model.predict_proba(processed_features)
            
            return {
                "prediction": prediction,
                "confidence": float(confidence) if confidence is not None else None,
                "model_name": model_name,
                "model_version": model_version or model.version
            }
            
        except Exception as e:
            logger.error(f"Prediction failed for model {model_name}: {e}")
            raise
    
    async def predict_batch(
        self,
        model_name: str,
        features_list: List[Dict[str, Any]],
        model_version: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Make batch predictions using the specified model.
        
        Args:
            model_name: Name of the model to use
            features_list: List of feature dictionaries
            model_version: Specific model version (optional)
        
        Returns:
            List of prediction dictionaries
        """
        if model_name not in self.models:
            raise ValueError(f"Model '{model_name}' not found")
        
        model = self.models[model_name]
        results = []
        
        try:
            # Process features in batches for efficiency
            batch_size = 100  # Configurable batch size
            
            for i in range(0, len(features_list), batch_size):
                batch = features_list[i:i + batch_size]
                
                # Extract and transform features for batch
                processed_batch = []
                for features in batch:
                    processed_features = await self.feature_extractor.extract(features)
                    processed_batch.append(processed_features)
                
                # Make batch predictions
                predictions = await model.predict_batch(processed_batch)
                confidences = await model.predict_proba_batch(processed_batch)
                
                # Format results
                for j, (prediction, confidence) in enumerate(zip(predictions, confidences)):
                    results.append({
                        "prediction": prediction,
                        "confidence": float(confidence) if confidence is not None else None,
                        "model_name": model_name,
                        "model_version": model_version or model.version,
                        "index": i + j
                    })
            
            return results
            
        except Exception as e:
            logger.error(f"Batch prediction failed for model {model_name}: {e}")
            raise
    
    async def explain_prediction(
        self,
        model_name: str,
        features: Dict[str, Any],
        model_version: Optional[str] = None,
        explanation_method: str = "shap"
    ) -> Dict[str, Any]:
        """
        Generate explanation for a prediction.
        
        Args:
            model_name: Name of the model
            features: Input features
            model_version: Model version
            explanation_method: Method to use ('shap' or 'lime')
        
        Returns:
            Dictionary containing explanation data
        """
        if model_name not in self.models:
            raise ValueError(f"Model '{model_name}' not found")
        
        model = self.models[model_name]
        
        try:
            # Extract and transform features
            processed_features = await self.feature_extractor.extract(features)
            
            # Generate explanation based on method
            if explanation_method.lower() == "shap":
                explanation = await self.shap_explainer.explain(
                    model, processed_features
                )
            elif explanation_method.lower() == "lime":
                explanation = await self.lime_explainer.explain(
                    model, processed_features
                )
            else:
                raise ValueError(f"Unknown explanation method: {explanation_method}")
            
            return {
                "method": explanation_method,
                "feature_importance": explanation.get("feature_importance", {}),
                "shap_values": explanation.get("shap_values"),
                "lime_explanation": explanation.get("lime_explanation"),
                "model_name": model_name,
                "model_version": model_version or model.version
            }
            
        except Exception as e:
            logger.error(f"Explanation generation failed for model {model_name}: {e}")
            raise
    
    async def get_model_info(self, model_name: str) -> Dict[str, Any]:
        """
        Get information about a specific model.
        
        Args:
            model_name: Name of the model
        
        Returns:
            Dictionary containing model information
        """
        if model_name not in self.models:
            raise ValueError(f"Model '{model_name}' not found")
        
        model = self.models[model_name]
        
        return {
            "name": model_name,
            "version": model.version,
            "type": model.model_type,
            "description": model.description,
            "features": model.feature_names,
            "performance_metrics": model.performance_metrics,
            "training_date": model.training_date,
            "is_trained": model.is_trained
        }
    
    async def list_models(self) -> List[Dict[str, Any]]:
        """
        List all available models.
        
        Returns:
            List of model information dictionaries
        """
        return [
            await self.get_model_info(model_name)
            for model_name in self.models.keys()
        ]
    
    async def retrain_model(
        self,
        model_name: str,
        training_data: pd.DataFrame,
        target_column: str
    ) -> Dict[str, Any]:
        """
        Retrain a specific model with new data.
        
        Args:
            model_name: Name of the model to retrain
            training_data: Training dataset
            target_column: Name of the target column
        
        Returns:
            Dictionary containing training results
        """
        if model_name not in self.models:
            raise ValueError(f"Model '{model_name}' not found")
        
        model = self.models[model_name]
        
        try:
            # Prepare features and target
            X = training_data.drop(columns=[target_column])
            y = training_data[target_column]
            
            # Extract features
            processed_X = []
            for _, row in X.iterrows():
                features = row.to_dict()
                processed_features = await self.feature_extractor.extract(features)
                processed_X.append(processed_features)
            
            processed_X = pd.DataFrame(processed_X)
            
            # Train model
            training_results = await model.train(processed_X, y)
            
            logger.info(f"Model {model_name} retrained successfully")
            
            return {
                "model_name": model_name,
                "training_results": training_results,
                "new_version": model.version,
                "training_samples": len(training_data)
            }
            
        except Exception as e:
            logger.error(f"Model retraining failed for {model_name}: {e}")
            raise
    
    async def health_check(self) -> Dict[str, Any]:
        """
        Perform health check on ML engine and models.
        
        Returns:
            Dictionary containing health status
        """
        model_status = {}
        
        for model_name, model in self.models.items():
            try:
                # Test model with dummy data
                dummy_features = model.get_dummy_features()
                await model.predict(dummy_features)
                model_status[model_name] = "healthy"
            except Exception as e:
                model_status[model_name] = f"unhealthy: {str(e)}"
        
        healthy_models = sum(1 for status in model_status.values() if status == "healthy")
        total_models = len(model_status)
        
        return {
            "status": "healthy" if healthy_models == total_models else "degraded",
            "models_loaded": total_models,
            "healthy_models": healthy_models,
            "model_status": model_status,
            "feature_extractor": "healthy",  # TODO: Add actual health check
            "explainers": "healthy"  # TODO: Add actual health check
        }


# Global ML Engine instance
ml_engine = MLEngine()
