"""
Prediction models for storing ML predictions and results.
"""

from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, JSON, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from core.database import Base


class Prediction(Base):
    """Model for storing prediction requests and metadata"""
    
    __tablename__ = "predictions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Prediction metadata
    model_name = Column(String(100), nullable=False)
    model_version = Column(String(50))
    prediction_type = Column(String(50))  # classification, regression, etc.
    
    # Input data
    input_features = Column(JSON)  # Store the input features as JSON
    feature_hash = Column(String(64))  # Hash of features for deduplication
    
    # Status and processing
    status = Column(String(50), default="pending")  # pending, completed, failed
    error_message = Column(Text)
    processing_time = Column(Float)  # Time taken in seconds
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    completed_at = Column(DateTime(timezone=True))
    
    # Relationships
    user = relationship("User", back_populates="predictions")
    results = relationship("PredictionResult", back_populates="prediction", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Prediction(id={self.id}, model='{self.model_name}', status='{self.status}')>"


class PredictionResult(Base):
    """Model for storing prediction results and explanations"""
    
    __tablename__ = "prediction_results"
    
    id = Column(Integer, primary_key=True, index=True)
    prediction_id = Column(Integer, ForeignKey("predictions.id"), nullable=False)
    
    # Prediction results
    prediction_value = Column(Float)  # Main prediction value
    confidence_score = Column(Float)  # Confidence/probability
    prediction_class = Column(String(100))  # For classification tasks
    probability_distribution = Column(JSON)  # Full probability distribution
    
    # Model explanation
    feature_importance = Column(JSON)  # Feature importance scores
    shap_values = Column(JSON)  # SHAP explanation values  
    lime_explanation = Column(JSON)  # LIME local explanation
    
    # Additional metadata
    model_metadata = Column(JSON)  # Model-specific metadata
    explanation_metadata = Column(JSON)  # Explanation method metadata
    
    # Risk assessment (for investment decisions)  
    risk_score = Column(Float)
    risk_factors = Column(JSON)  # List of risk factors
    success_probability = Column(Float)  # Investment success probability
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    prediction = relationship("Prediction", back_populates="results")
    
    def __repr__(self):
        return f"<PredictionResult(id={self.id}, prediction_id={self.prediction_id}, value={self.prediction_value})>"
