"""
Feature extraction utilities for the Decision platform.
"""

import logging
from typing import Dict, Any, List, Optional
import pandas as pd
import numpy as np
from datetime import datetime, date

logger = logging.getLogger(__name__)


class FeatureExtractor:
    """
    Feature extractor for preprocessing investment data.
    Handles feature engineering and transformation for ML models.
    """
    
    def __init__(self):
        self.feature_mappings = self._initialize_feature_mappings()
    
    def _initialize_feature_mappings(self) -> Dict[str, Any]:
        """Initialize feature mappings and encodings"""
        return {
            "funding_stages": {
                "Pre-Seed": 1,
                "Seed": 2,
                "Series A": 3,
                "Series B": 4,
                "Series C": 5,
                "Series D": 6,
                "Later Stage": 7,
                "IPO": 8
            },
            "sectors": {
                "AI/ML": 1,
                "FinTech": 2,
                "HealthTech": 3,
                "E-commerce": 4,
                "SaaS": 5,
                "Biotech": 6,
                "CleanTech": 7,
                "EdTech": 8,
                "Gaming": 9,
                "Hardware": 10,
                "Other": 0
            },
            "competition_levels": {
                "low": 1,
                "medium": 2,
                "high": 3
            },
            "business_models": {
                "B2B": 1,
                "B2C": 2,
                "B2B2C": 3,
                "Marketplace": 4,
                "SaaS": 5,
                "Hardware": 6,
                "Subscription": 7,
                "Freemium": 8
            }
        }
    
    def extract_features(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Extract and engineer features from raw input data.
        
        Args:
            data: Raw input data dictionary
        
        Returns:
            Dictionary of processed features
        """
        try:
            features = {}
            
            # Financial features
            features.update(self._extract_financial_features(data))
            
            # Company features
            features.update(self._extract_company_features(data))
            
            # Market features
            features.update(self._extract_market_features(data))
            
            # Temporal features
            features.update(self._extract_temporal_features(data))
            
            # Team features
            features.update(self._extract_team_features(data))
            
            # Product features
            features.update(self._extract_product_features(data))
            
            logger.debug(f"Extracted {len(features)} features")
            return features
            
        except Exception as e:
            logger.error(f"Feature extraction failed: {e}")
            return self._get_default_features()
    
    def _extract_financial_features(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract financial-related features"""
        features = {}
        
        # Revenue metrics
        features["revenue"] = self._safe_float(data.get("revenue", 0))
        features["revenue_growth"] = self._safe_float(data.get("revenue_growth", 0))
        features["recurring_revenue_ratio"] = self._safe_float(data.get("recurring_revenue_ratio", 0))
        
        # Funding metrics
        features["funding_amount"] = self._safe_float(data.get("funding_amount", 0))
        features["previous_funding"] = self._safe_float(data.get("previous_funding", 0))
        features["funding_stage_numeric"] = self.feature_mappings["funding_stages"].get(
            data.get("funding_stage", "Other"), 0
        )
        
        # Financial health
        features["burn_rate"] = self._safe_float(data.get("burn_rate", 0))
        features["runway_months"] = self._safe_float(data.get("runway_months", 0))
        features["unit_economics_score"] = self._safe_float(data.get("unit_economics_score", 0))
        
        return features
    
    def _extract_company_features(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract company-related features"""
        features = {}
        
        # Basic company info
        features["company_age"] = self._calculate_company_age(data.get("founded_date"))
        features["sector_numeric"] = self.feature_mappings["sectors"].get(
            data.get("sector", "Other"), 0
        )
        features["business_model_numeric"] = self.feature_mappings["business_models"].get(
            data.get("business_model", "Other"), 0
        )
        
        # Geography (simplified)
        geography = data.get("geography", "Other")
        features["geography_tier"] = self._get_geography_tier(geography)
        
        # Company size
        features["employee_count"] = self._safe_int(data.get("employee_count", 0))
        features["employee_growth"] = self._safe_float(data.get("employee_growth", 0))
        
        return features
    
    def _extract_market_features(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract market-related features"""
        features = {}
        
        features["market_size"] = self._safe_float(data.get("market_size", 0))
        features["competition_level_numeric"] = self.feature_mappings["competition_levels"].get(
            data.get("competition_level", "medium"), 2
        )
        features["market_growth_rate"] = self._safe_float(data.get("market_growth_rate", 0))
        features["market_penetration"] = self._safe_float(data.get("market_penetration", 0))
        
        return features
    
    def _extract_temporal_features(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract time-based features"""
        features = {}
        
        # Current date features
        now = datetime.now()
        features["current_year"] = now.year
        features["current_month"] = now.month
        features["current_quarter"] = (now.month - 1) // 3 + 1
        
        # Founded date features
        founded_date = data.get("founded_date")
        if founded_date:
            if isinstance(founded_date, str):
                try:
                    founded_date = datetime.strptime(founded_date, "%Y-%m-%d")
                except:
                    founded_date = None
            
            if founded_date:
                features["founded_year"] = founded_date.year
                features["founded_quarter"] = (founded_date.month - 1) // 3 + 1
                features["is_recent_company"] = 1 if (now - founded_date).days < 365 * 3 else 0
        
        return features
    
    def _extract_team_features(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract team-related features"""
        features = {}
        
        features["founder_experience"] = self._safe_float(data.get("founder_experience", 0))
        features["team_size"] = self._safe_int(data.get("team_size", 0))
        features["technical_team_ratio"] = self._safe_float(data.get("technical_team_ratio", 0))
        features["advisor_count"] = self._safe_int(data.get("advisor_count", 0))
        features["previous_exits"] = self._safe_int(data.get("previous_exits", 0))
        
        return features
    
    def _extract_product_features(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract product-related features"""
        features = {}
        
        features["product_readiness"] = self._safe_float(data.get("product_readiness", 0))
        features["customer_count"] = self._safe_int(data.get("customer_count", 0))
        features["customer_acquisition_cost"] = self._safe_float(data.get("customer_acquisition_cost", 0))
        features["customer_lifetime_value"] = self._safe_float(data.get("customer_lifetime_value", 0))
        features["churn_rate"] = self._safe_float(data.get("churn_rate", 0))
        features["nps_score"] = self._safe_float(data.get("nps_score", 0))
        
        # Calculate LTV/CAC ratio
        ltv = features["customer_lifetime_value"]
        cac = features["customer_acquisition_cost"]
        features["ltv_cac_ratio"] = ltv / cac if cac > 0 else 0
        
        return features
    
    def _calculate_company_age(self, founded_date: Any) -> float:
        """Calculate company age in years"""
        if not founded_date:
            return 0.0
        
        try:
            if isinstance(founded_date, str):
                founded_date = datetime.strptime(founded_date, "%Y-%m-%d")
            elif isinstance(founded_date, date):
                founded_date = datetime.combine(founded_date, datetime.min.time())
            
            age_days = (datetime.now() - founded_date).days
            return max(0.0, age_days / 365.25)
            
        except Exception as e:
            logger.warning(f"Could not calculate company age: {e}")
            return 0.0
    
    def _get_geography_tier(self, geography: str) -> int:
        """Map geography to tier (1=top tier, 2=second tier, 3=other)"""
        top_tier = ["United States", "San Francisco", "New York", "Boston", "London", "Singapore"]
        second_tier = ["Canada", "Germany", "France", "Israel", "Australia"]
        
        if any(tier in geography for tier in top_tier):
            return 1
        elif any(tier in geography for tier in second_tier):
            return 2
        else:
            return 3
    
    def _safe_float(self, value: Any) -> float:
        """Safely convert value to float"""
        try:
            if value is None:
                return 0.0
            return float(value)
        except (ValueError, TypeError):
            return 0.0
    
    def _safe_int(self, value: Any) -> int:
        """Safely convert value to int"""
        try:
            if value is None:
                return 0
            return int(float(value))
        except (ValueError, TypeError):
            return 0
    
    def _get_default_features(self) -> Dict[str, Any]:
        """Get default feature values when extraction fails"""
        return {
            "revenue": 0.0,
            "revenue_growth": 0.0,
            "funding_amount": 0.0,
            "company_age": 0.0,
            "sector_numeric": 0,
            "funding_stage_numeric": 0,
            "business_model_numeric": 0,
            "market_size": 0.0,
            "competition_level_numeric": 2,
            "employee_count": 0,
            "founder_experience": 0.0,
            "product_readiness": 0.0,
            "customer_count": 0,
            "ltv_cac_ratio": 0.0,
            "geography_tier": 3
        }
    
    def get_feature_names(self) -> List[str]:
        """Get list of all possible feature names"""
        return list(self._get_default_features().keys())
