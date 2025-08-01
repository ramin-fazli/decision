"""Prediction schemas for ML model operations"""

from typing import Dict, List, Optional, Any, Union
from pydantic import BaseModel, Field
from datetime import datetime
from enum import Enum


class ModelType(str, Enum):
    """Available model types"""
    RANDOM_FOREST = "random_forest"
    DECISION_TREE = "decision_tree"
    NEURAL_NETWORK = "neural_network"
    QDA = "qda"


class PredictionRequest(BaseModel):
    """Schema for single prediction request"""
    model_name: str = Field(..., description="Name of the model to use for prediction")
    features: Dict[str, Any] = Field(..., description="Feature values for prediction")
    model_version: Optional[str] = Field(None, description="Specific model version to use")
    
    class Config:
        schema_extra = {
            "example": {
                "model_name": "random_forest",
                "features": {
                    "funding_stage": "Series A",
                    "sector": "AI/ML",
                    "team_experience_years": 8,
                    "market_size_millions": 1500,
                    "revenue_growth_rate": 0.25,
                    "competition_level": "medium"
                },
                "model_version": "1.0.0"
            }
        }


class PredictionResponse(BaseModel):
    """Schema for single prediction response"""
    id: int = Field(..., description="Prediction record ID")
    prediction: Union[float, str, Dict[str, Any]] = Field(..., description="Model prediction result")
    confidence: Optional[float] = Field(None, description="Prediction confidence score (0-1)")
    model_name: str = Field(..., description="Name of the model used")
    model_version: str = Field(..., description="Version of the model used")
    features: Dict[str, Any] = Field(..., description="Input features used")
    created_at: datetime = Field(..., description="Timestamp when prediction was made")
    
    class Config:
        from_attributes = True


class BatchPredictionRequest(BaseModel):
    """Schema for batch prediction request"""
    model_name: str = Field(..., description="Name of the model to use for predictions")
    features_list: List[Dict[str, Any]] = Field(..., description="List of feature sets for batch prediction")
    model_version: Optional[str] = Field(None, description="Specific model version to use")
    
    class Config:
        schema_extra = {
            "example": {
                "model_name": "random_forest",
                "features_list": [
                    {
                        "funding_stage": "Series A",
                        "sector": "FinTech",
                        "team_experience_years": 5,
                        "market_size_millions": 2000,
                        "revenue_growth_rate": 0.30,
                        "competition_level": "high"
                    },
                    {
                        "funding_stage": "Seed",
                        "sector": "HealthTech",
                        "team_experience_years": 3,
                        "market_size_millions": 800,
                        "revenue_growth_rate": 0.15,
                        "competition_level": "low"
                    }
                ],
                "model_version": "1.0.0"
            }
        }


class BatchPredictionResponse(BaseModel):
    """Schema for batch prediction response"""
    batch_id: str = Field(..., description="Batch prediction ID")
    total_predictions: int = Field(..., description="Total number of predictions made")
    successful_predictions: int = Field(..., description="Number of successful predictions")
    failed_predictions: int = Field(..., description="Number of failed predictions")
    predictions: List[PredictionResponse] = Field(..., description="List of individual predictions")
    model_name: str = Field(..., description="Name of the model used")
    model_version: str = Field(..., description="Version of the model used")
    created_at: datetime = Field(..., description="Timestamp when batch was processed")


class FeatureImportance(BaseModel):
    """Schema for feature importance information"""
    feature_name: str = Field(..., description="Name of the feature")
    importance_score: float = Field(..., description="Importance score (0-1)")
    description: Optional[str] = Field(None, description="Description of the feature")


class ModelExplanation(BaseModel):
    """Schema for model explanation and interpretability"""
    prediction_id: int = Field(..., description="ID of the prediction being explained")
    model_name: str = Field(..., description="Name of the model")
    explanation_type: str = Field(..., description="Type of explanation (SHAP, LIME, etc.)")
    feature_importance: List[FeatureImportance] = Field(..., description="Feature importance rankings")
    explanation_details: Dict[str, Any] = Field(..., description="Detailed explanation data")
    confidence: float = Field(..., description="Overall confidence in explanation")
    
    class Config:
        schema_extra = {
            "example": {
                "prediction_id": 123,
                "model_name": "random_forest",
                "explanation_type": "SHAP",
                "feature_importance": [
                    {
                        "feature_name": "team_experience_years",
                        "importance_score": 0.35,
                        "description": "Years of experience of the founding team"
                    },
                    {
                        "feature_name": "market_size_millions",
                        "importance_score": 0.28,
                        "description": "Total addressable market size in millions USD"
                    }
                ],
                "explanation_details": {
                    "shap_values": [0.12, -0.05, 0.08, 0.15, -0.02, 0.07],
                    "base_value": 0.65,
                    "expected_value": 0.73
                },
                "confidence": 0.87
            }
        }


class PredictionFilter(BaseModel):
    """Schema for filtering prediction history"""
    model_name: Optional[str] = Field(None, description="Filter by model name")
    start_date: Optional[datetime] = Field(None, description="Filter predictions after this date")
    end_date: Optional[datetime] = Field(None, description="Filter predictions before this date")
    min_confidence: Optional[float] = Field(None, ge=0, le=1, description="Minimum confidence score")
    max_confidence: Optional[float] = Field(None, ge=0, le=1, description="Maximum confidence score")


class PredictionHistory(BaseModel):
    """Schema for prediction history response"""
    total_count: int = Field(..., description="Total number of predictions")
    predictions: List[PredictionResponse] = Field(..., description="List of predictions")
    page: int = Field(..., description="Current page number")
    page_size: int = Field(..., description="Number of items per page")
    total_pages: int = Field(..., description="Total number of pages")


class ModelPerformanceMetrics(BaseModel):
    """Schema for model performance metrics"""
    model_name: str = Field(..., description="Name of the model")
    model_version: str = Field(..., description="Version of the model")
    accuracy: float = Field(..., description="Model accuracy")
    precision: float = Field(..., description="Model precision")
    recall: float = Field(..., description="Model recall")
    f1_score: float = Field(..., description="Model F1 score")
    auc_roc: Optional[float] = Field(None, description="Area under ROC curve")
    total_predictions: int = Field(..., description="Total number of predictions made")
    last_updated: datetime = Field(..., description="When metrics were last calculated")


class UploadDataRequest(BaseModel):
    """Schema for data upload request"""
    dataset_name: str = Field(..., description="Name for the uploaded dataset")
    description: Optional[str] = Field(None, description="Description of the dataset")
    target_column: Optional[str] = Field(None, description="Name of the target column for training")
    feature_columns: Optional[List[str]] = Field(None, description="List of feature column names")


class UploadDataResponse(BaseModel):
    """Schema for data upload response"""
    dataset_id: str = Field(..., description="Unique identifier for the uploaded dataset")
    dataset_name: str = Field(..., description="Name of the dataset")
    total_rows: int = Field(..., description="Number of rows in the dataset")
    total_columns: int = Field(..., description="Number of columns in the dataset")
    column_names: List[str] = Field(..., description="List of column names")
    upload_timestamp: datetime = Field(..., description="When the dataset was uploaded")
    status: str = Field(..., description="Upload status")
