"""
SHAP (SHapley Additive exPlanations) explainer for model interpretability.
"""

import logging
from typing import Dict, Any, List, Optional, Union
import numpy as np
import pandas as pd

try:
    import shap
    SHAP_AVAILABLE = True
except ImportError:
    SHAP_AVAILABLE = False
    shap = None

logger = logging.getLogger(__name__)


class SHAPExplainer:
    """
    SHAP-based model explainer for investment decision interpretability.
    Provides feature importance and contribution analysis.
    """
    
    def __init__(self):
        self.explainers = {}
        self.available = SHAP_AVAILABLE
        
        if not self.available:
            logger.warning("SHAP not available. Install with: pip install shap")
    
    def create_explainer(self, model, training_data: np.ndarray, model_name: str) -> bool:
        """
        Create a SHAP explainer for the given model.
        
        Args:
            model: Trained model object
            training_data: Training data for background
            model_name: Name to identify the explainer
        
        Returns:
            True if explainer created successfully
        """
        if not self.available:
            logger.error("SHAP not available")
            return False
        
        try:
            # Determine the appropriate explainer type
            explainer_type = self._get_explainer_type(model)
            
            if explainer_type == "tree":
                explainer = shap.TreeExplainer(model)
            elif explainer_type == "linear":
                explainer = shap.LinearExplainer(model, training_data)
            elif explainer_type == "kernel":
                # Use a sample of training data for kernel explainer (can be slow)
                background_sample = training_data[:min(100, len(training_data))]
                explainer = shap.KernelExplainer(model.predict, background_sample)
            else:
                # Default to kernel explainer
                background_sample = training_data[:min(100, len(training_data))]
                explainer = shap.KernelExplainer(model.predict, background_sample)
            
            self.explainers[model_name] = explainer
            logger.info(f"Created {explainer_type} explainer for {model_name}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to create explainer for {model_name}: {e}")
            return False
    
    def explain_prediction(
        self,
        model_name: str,
        features: np.ndarray,
        feature_names: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        Explain a single prediction using SHAP values.
        
        Args:
            model_name: Name of the model/explainer
            features: Input features array
            feature_names: Names of features
        
        Returns:
            Dictionary with SHAP explanation
        """
        if not self.available:
            return {"error": "SHAP not available"}
        
        if model_name not in self.explainers:
            return {"error": f"No explainer found for {model_name}"}
        
        try:
            explainer = self.explainers[model_name]
            
            # Calculate SHAP values
            if hasattr(explainer, 'shap_values'):
                # For tree explainers
                shap_values = explainer.shap_values(features.reshape(1, -1))
                
                # Handle multi-class case
                if isinstance(shap_values, list):
                    # Use the positive class for binary classification
                    shap_values = shap_values[1] if len(shap_values) == 2 else shap_values[0]
                
                shap_values = shap_values[0]  # Get first (and only) instance
            else:
                # For other explainers
                shap_values = explainer(features.reshape(1, -1))[0]
                if hasattr(shap_values, 'values'):
                    shap_values = shap_values.values
            
            # Create feature importance ranking
            abs_shap = np.abs(shap_values)
            importance_ranking = np.argsort(abs_shap)[::-1]
            
            # Prepare results
            result = {
                "shap_values": shap_values.tolist(),
                "expected_value": getattr(explainer, 'expected_value', 0.0),
                "feature_importance": abs_shap.tolist(),
                "importance_ranking": importance_ranking.tolist()
            }
            
            # Add feature names if provided
            if feature_names:
                result["feature_names"] = feature_names
                result["feature_contributions"] = dict(zip(feature_names, shap_values))
                result["ranked_features"] = [feature_names[i] for i in importance_ranking]
            
            return result
            
        except Exception as e:
            logger.error(f"SHAP explanation failed: {e}")
            return {"error": str(e)}
    
    def get_feature_importance(
        self,
        model_name: str,
        features: np.ndarray,
        feature_names: Optional[List[str]] = None
    ) -> Dict[str, float]:
        """
        Get feature importance based on mean absolute SHAP values.
        
        Args:
            model_name: Name of the model/explainer
            features: Input features array (multiple samples)
            feature_names: Names of features
        
        Returns:
            Dictionary mapping feature names to importance scores
        """
        if not self.available:
            return {}
        
        if model_name not in self.explainers:
            return {}
        
        try:
            explainer = self.explainers[model_name]
            
            # Calculate SHAP values for all samples
            if hasattr(explainer, 'shap_values'):
                shap_values = explainer.shap_values(features)
                if isinstance(shap_values, list):
                    shap_values = shap_values[1] if len(shap_values) == 2 else shap_values[0]
            else:
                shap_explanation = explainer(features)
                shap_values = shap_explanation.values
            
            # Calculate mean absolute SHAP values
            mean_abs_shap = np.mean(np.abs(shap_values), axis=0)
            
            # Create importance dictionary
            if feature_names:
                return dict(zip(feature_names, mean_abs_shap))
            else:
                return {f"feature_{i}": val for i, val in enumerate(mean_abs_shap)}
                
        except Exception as e:
            logger.error(f"Feature importance calculation failed: {e}")
            return {}
    
    def create_summary_plot_data(
        self,
        model_name: str,
        features: np.ndarray,
        feature_names: Optional[List[str]] = None,
        max_display: int = 10
    ) -> Dict[str, Any]:
        """
        Create data for SHAP summary plot.
        
        Args:
            model_name: Name of the model/explainer
            features: Input features array
            feature_names: Names of features
            max_display: Maximum number of features to display
        
        Returns:
            Dictionary with plot data
        """
        if not self.available:
            return {"error": "SHAP not available"}
        
        if model_name not in self.explainers:
            return {"error": f"No explainer found for {model_name}"}
        
        try:
            explainer = self.explainers[model_name]
            
            # Calculate SHAP values
            if hasattr(explainer, 'shap_values'):
                shap_values = explainer.shap_values(features)
                if isinstance(shap_values, list):
                    shap_values = shap_values[1] if len(shap_values) == 2 else shap_values[0]
            else:
                shap_explanation = explainer(features)
                shap_values = shap_explanation.values
            
            # Calculate feature importance and select top features
            feature_importance = np.mean(np.abs(shap_values), axis=0)
            top_indices = np.argsort(feature_importance)[-max_display:][::-1]
            
            # Prepare plot data
            plot_data = {
                "shap_values": shap_values[:, top_indices].tolist(),
                "feature_values": features[:, top_indices].tolist(),
                "feature_importance": feature_importance[top_indices].tolist(),
                "feature_indices": top_indices.tolist()
            }
            
            if feature_names:
                plot_data["feature_names"] = [feature_names[i] for i in top_indices]
            
            return plot_data
            
        except Exception as e:
            logger.error(f"Summary plot data creation failed: {e}")
            return {"error": str(e)}
    
    def _get_explainer_type(self, model) -> str:
        """Determine the appropriate SHAP explainer type for the model"""
        model_type = type(model).__name__.lower()
        
        # Tree-based models
        if any(tree_type in model_type for tree_type in [
            'randomforest', 'decisiontree', 'xgb', 'lightgbm', 'catboost'
        ]):
            return "tree"
        
        # Linear models
        elif any(linear_type in model_type for linear_type in [
            'linear', 'logistic', 'ridge', 'lasso', 'elastic'
        ]):
            return "linear"
        
        # Default to kernel explainer for complex models
        else:
            return "kernel"
    
    def is_available(self) -> bool:
        """Check if SHAP is available"""
        return self.available
    
    def get_explainer_info(self, model_name: str) -> Dict[str, Any]:
        """Get information about the explainer"""
        if model_name not in self.explainers:
            return {}
        
        explainer = self.explainers[model_name]
        return {
            "explainer_type": type(explainer).__name__,
            "model_name": model_name,
            "available": True
        }
