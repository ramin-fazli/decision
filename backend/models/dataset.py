"""
Dataset models for storing training data and company information.
"""

from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, JSON, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from core.database import Base


class Dataset(Base):
    """Model for storing dataset metadata and information"""
    
    __tablename__ = "datasets"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Dataset metadata
    name = Column(String(255), nullable=False)
    description = Column(Text)
    source = Column(String(255))  # e.g., "crunchbase", "manual", "api"
    version = Column(String(50))
    
    # Dataset statistics
    total_records = Column(Integer, default=0)
    feature_count = Column(Integer, default=0)
    target_variable = Column(String(100))
    dataset_type = Column(String(50))  # training, validation, test
    
    # Data quality metrics
    completeness_score = Column(Float)  # Percentage of non-null values
    quality_score = Column(Float)  # Overall data quality score
    
    # Processing status
    status = Column(String(50), default="pending")  # pending, processed, error
    processing_log = Column(Text)
    
    # Schema and configuration
    schema_config = Column(JSON)  # Column types, constraints, etc.
    preprocessing_config = Column(JSON)  # Preprocessing steps applied
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    processed_at = Column(DateTime(timezone=True))
    
    # Relationships
    user = relationship("User", back_populates="datasets")
    records = relationship("DatasetRecord", back_populates="dataset", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Dataset(id={self.id}, name='{self.name}', records={self.total_records})>"


class DatasetRecord(Base):
    """Model for storing individual dataset records (companies/startups)"""
    
    __tablename__ = "dataset_records"
    
    id = Column(Integer, primary_key=True, index=True)
    dataset_id = Column(Integer, ForeignKey("datasets.id"), nullable=False)
    
    # Company identification
    company_name = Column(String(255), nullable=False)
    company_id = Column(String(100))  # External ID (e.g., Crunchbase ID)
    website = Column(String(255))
    
    # Company basics
    founded_date = Column(DateTime)
    country = Column(String(100))
    state = Column(String(100))
    city = Column(String(100))
    industry = Column(String(100))
    sector = Column(String(100))
    
    # Business model and stage
    business_model = Column(String(100))
    funding_stage = Column(String(100))
    employee_count = Column(Integer)
    
    # Financial data
    total_funding = Column(Float)
    latest_funding_amount = Column(Float)
    latest_funding_date = Column(DateTime)
    valuation = Column(Float)
    revenue = Column(Float)
    
    # Target variable (for ML)
    target_outcome = Column(String(100))  # success, failure, ipo, acquired, etc.
    success_score = Column(Float)  # Numerical success metric
    
    # Raw features (JSON for flexibility)
    raw_features = Column(JSON)  # Store all features as JSON
    processed_features = Column(JSON)  # Processed/engineered features
    
    # Data source and quality
    source_reliability = Column(Float)  # 0-1 score of data reliability
    last_updated = Column(DateTime)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    dataset = relationship("Dataset", back_populates="records")
    
    def __repr__(self):
        return f"<DatasetRecord(id={self.id}, company='{self.company_name}', outcome='{self.target_outcome}')>"
