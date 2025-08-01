"""
LIME (Local Interpretable Model-agnostic Explanations) explainer for model interpretability.
"""

import logging
from typing import Dict, Any, List, Optional, Callable
import numpy as np
import pandas as pd

try:
    from lime import lime_tabular
    LIME_AVAILABLE = True
except ImportError:
    LIME_AVAILABLE = False
    lime_tabular = None

logger = logging.getLogger(__name__)


class LIMEExplainer:
    """
    LIME-based model explainer for investment decision interpretability.
    Provides local explanations for individual predictions.
    """
    
    def __init__(self):
        self.explainers = {}
        self.available = LIME_AVAILABLE
        
        if not self.available:
            logger.warning("LIME not available. Install with: pip install lime")
    
    def create_explainer(
        self,
        training_data: np.ndarray,
        feature_names: List[str],
        class_names: Optional[List[str]] = None,
        model_name: str = "default"
    ) -> bool:
        """
        Create a LIME tabular explainer.
        
        Args:
            training_data: Training data for explanation baseline
            feature_names: Names of input features
            class_names: Names of output classes (for classification)
            model_name: Name to identify the explainer
        
        Returns:
            True if explainer created successfully
        """
        if not self.available:
            logger.error("LIME not available")
            return False
        
        try:
            # Create LIME tabular explainer
            explainer = lime_tabular.LimeTabularExplainer(
                training_data,
                feature_names=feature_names,
                class_names=class_names,
                mode='classification' if class_names else 'regression',
                discretize_continuous=True,
                random_state=42
            )
            
            self.explainers[model_name] = {
                "explainer": explainer,
                "feature_names": feature_names,
                "class_names": class_names
            }
            
            logger.info(f"Created LIME explainer for {model_name}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to create LIME explainer for {model_name}: {e}")
            return False
    
    def explain_prediction(
        self,
        model_name: str,
        instance: np.ndarray,
        predict_fn: Callable,
        num_features: int = 10,
        num_samples: int = 1000
    ) -> Dict[str, Any]:
        """
        Explain a single prediction using LIME.
        
        Args:
            model_name: Name of the explainer
            instance: Single instance to explain
            predict_fn: Model prediction function
            num_features: Number of features to include in explanation
            num_samples: Number of samples for LIME
        
        Returns:
            Dictionary with LIME explanation
        """
        if not self.available:
            return {"error": "LIME not available"}
        
        if model_name not in self.explainers:
            return {"error": f"No explainer found for {model_name}"}
        
        try:
            explainer_info = self.explainers[model_name]
            explainer = explainer_info["explainer"]
            feature_names = explainer_info["feature_names"]
            
            # Generate explanation
            explanation = explainer.explain_instance(
                instance,
                predict_fn,
                num_features=num_features,
                num_samples=num_samples
            )
            
            # Extract explanation data
            explanation_list = explanation.as_list()
            explanation_map = explanation.as_map()
            
            # Prepare results
            result = {
                "explanation_list": explanation_list,
                "local_prediction": explanation.local_pred,
                "intercept": explanation.intercept[1] if hasattr(explanation, 'intercept') and len(explanation.intercept) > 1 else 0,
                "score": explanation.score if hasattr(explanation, 'score') else 0,
                "local_exp": dict(explanation_map[1]) if 1 in explanation_map else {}
            }
            
            # Add feature contributions
            feature_contributions = {}
            for feature_desc, contribution in explanation_list:
                # Extract feature name from description
                feature_name = self._extract_feature_name(feature_desc, feature_names)
                feature_contributions[feature_name] = contribution
            
            result["feature_contributions"] = feature_contributions
            
            return result
            
        except Exception as e:
            logger.error(f"LIME explanation failed: {e}")
            return {"error": str(e)}
    
    def explain_prediction_html(
        self,
        model_name: str,
        instance: np.ndarray,
        predict_fn: Callable,
        num_features: int = 10,
        num_samples: int = 1000
    ) -> str:
        """
        Generate HTML explanation for a prediction.
        
        Args:
            model_name: Name of the explainer
            instance: Single instance to explain
            predict_fn: Model prediction function
            num_features: Number of features to include
            num_samples: Number of samples for LIME
        
        Returns:
            HTML string with explanation
        """
        if not self.available:
            return "<p>LIME not available</p>"
        
        if model_name not in self.explainers:
            return f"<p>No explainer found for {model_name}</p>"
        
        try:
            explainer_info = self.explainers[model_name]
            explainer = explainer_info["explainer"]
            
            # Generate explanation
            explanation = explainer.explain_instance(
                instance,
                predict_fn,
                num_features=num_features,
                num_samples=num_samples
            )
            
            # Return HTML
            return explanation.as_html()
            
        except Exception as e:
            logger.error(f"LIME HTML explanation failed: {e}")
            return f"<p>Error generating explanation: {str(e)}</p>"
    
    def get_feature_importance(
        self,
        model_name: str,
        instances: np.ndarray,
        predict_fn: Callable,
        num_features: int = 10,
        num_samples: int = 500
    ) -> Dict[str, float]:
        """
        Get average feature importance across multiple instances.
        
        Args:
            model_name: Name of the explainer
            instances: Multiple instances to explain
            predict_fn: Model prediction function
            num_features: Number of features to include
            num_samples: Number of samples for LIME
        
        Returns:
            Dictionary with average feature importance
        """
        if not self.available:
            return {}
        
        if model_name not in self.explainers:
            return {}
        
        try:
            explainer_info = self.explainers[model_name]
            feature_names = explainer_info["feature_names"]
            
            # Collect feature contributions across instances
            all_contributions = {name: [] for name in feature_names}
            
            # Sample a subset of instances if too many
            if len(instances) > 20:
                indices = np.random.choice(len(instances), 20, replace=False)
                sample_instances = instances[indices]
            else:
                sample_instances = instances
            
            for instance in sample_instances:
                explanation_result = self.explain_prediction(
                    model_name, instance, predict_fn, num_features, num_samples
                )
                
                if "feature_contributions" in explanation_result:
                    for feature_name, contribution in explanation_result["feature_contributions"].items():
                        if feature_name in all_contributions:
                            all_contributions[feature_name].append(abs(contribution))
            
            # Calculate average importance
            avg_importance = {}
            for feature_name, contributions in all_contributions.items():
                if contributions:
                    avg_importance[feature_name] = np.mean(contributions)
                else:
                    avg_importance[feature_name] = 0.0
            
            return avg_importance
            
        except Exception as e:
            logger.error(f"Feature importance calculation failed: {e}")
            return {}
    
    def _extract_feature_name(self, feature_desc: str, feature_names: List[str]) -> str:
        """Extract feature name from LIME feature description"""
        # LIME descriptions often contain conditions like "feature_name <= 5.0"
        # We need to extract the actual feature name
        
        for name in feature_names:
            if name in feature_desc:
                return name
        
        # Fallback: return the description itself
        return feature_desc.split()[0] if ' ' in feature_desc else feature_desc
    
    def create_prediction_wrapper(self, model, model_type: str = "classifier"):
        """
        Create a prediction wrapper function for LIME.
        
        Args:
            model: The model to wrap
            model_type: Type of model ("classifier" or "regressor")
        
        Returns:
            Prediction function suitable for LIME
        """
        if model_type == "classifier":
            def predict_fn(instances):
                if hasattr(model, 'predict_proba'):
                    return model.predict_proba(instances)
                else:
                    # For models without predict_proba, create binary probabilities
                    predictions = model.predict(instances)
                    probs = np.zeros((len(predictions), 2))
                    probs[predictions == 0, 0] = 1.0
                    probs[predictions == 1, 1] = 1.0
                    return probs
        else:
            def predict_fn(instances):
                predictions = model.predict(instances)
                return predictions.reshape(-1, 1) if predictions.ndim == 1 else predictions
        
        return predict_fn
    
    def is_available(self) -> bool:
        """Check if LIME is available"""
        return self.available
    
    def get_explainer_info(self, model_name: str) -> Dict[str, Any]:
        """Get information about the explainer"""
        if model_name not in self.explainers:
            return {}
        
        explainer_info = self.explainers[model_name]
        return {
            "explainer_type": "LIME Tabular",
            "model_name": model_name,
            "feature_names": explainer_info["feature_names"],
            "class_names": explainer_info["class_names"],
            "available": True
        }
    
    def remove_explainer(self, model_name: str) -> bool:
        """Remove an explainer"""
        if model_name in self.explainers:
            del self.explainers[model_name]
            logger.info(f"Removed LIME explainer for {model_name}")
            return True
        return False
