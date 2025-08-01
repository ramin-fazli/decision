"""
Predictions router for Decision platform.
Handles ML model predictions and related operations.
"""

from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session

from api.schemas.prediction import (
    PredictionRequest,
    PredictionResponse,
    BatchPredictionRequest,
    BatchPredictionResponse,
    ModelExplanation
)
from core.database import get_db
from core.security import get_current_user
from services.prediction_service import PredictionService
from ml.engine import MLEngine

router = APIRouter()


@router.post("/predict", response_model=PredictionResponse)
async def make_prediction(
    request: PredictionRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
) -> Any:
    """
    Make a single prediction using the specified model.
    """
    prediction_service = PredictionService(db)
    ml_engine = MLEngine()
    
    try:
        # Make prediction
        result = await ml_engine.predict(
            model_name=request.model_name,
            features=request.features,
            model_version=request.model_version
        )
        
        # Store prediction in database
        prediction_record = await prediction_service.create_prediction(
            user_id=current_user.id,
            model_name=request.model_name,
            features=request.features,
            prediction=result["prediction"],
            confidence=result.get("confidence"),
            model_version=request.model_version
        )
        
        return PredictionResponse(
            id=prediction_record.id,
            prediction=result["prediction"],
            confidence=result.get("confidence"),
            model_name=request.model_name,
            model_version=request.model_version,
            features=request.features,
            created_at=prediction_record.created_at
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Prediction failed: {str(e)}"
        )


@router.post("/predict/batch", response_model=BatchPredictionResponse)
async def make_batch_prediction(
    request: BatchPredictionRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
) -> Any:
    """
    Make batch predictions using the specified model.
    """
    prediction_service = PredictionService(db)
    ml_engine = MLEngine()
    
    try:
        # Make batch predictions
        results = await ml_engine.predict_batch(
            model_name=request.model_name,
            features_list=request.features_list,
            model_version=request.model_version
        )
        
        # Store predictions in database
        prediction_records = []
        for i, result in enumerate(results):
            record = await prediction_service.create_prediction(
                user_id=current_user.id,
                model_name=request.model_name,
                features=request.features_list[i],
                prediction=result["prediction"],
                confidence=result.get("confidence"),
                model_version=request.model_version
            )
            prediction_records.append(record)
        
        return BatchPredictionResponse(
            predictions=[
                PredictionResponse(
                    id=record.id,
                    prediction=result["prediction"],
                    confidence=result.get("confidence"),
                    model_name=request.model_name,
                    model_version=request.model_version,
                    features=request.features_list[i],
                    created_at=record.created_at
                )
                for i, (record, result) in enumerate(zip(prediction_records, results))
            ],
            total_predictions=len(results),
            successful_predictions=len([r for r in results if r.get("error") is None]),
            failed_predictions=len([r for r in results if r.get("error") is not None])
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Batch prediction failed: {str(e)}"
        )


@router.post("/predict/file", response_model=BatchPredictionResponse)
async def predict_from_file(
    model_name: str,
    file: UploadFile = File(...),
    model_version: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
) -> Any:
    """
    Make predictions from uploaded CSV/Excel file.
    """
    if not file.filename.lower().endswith(('.csv', '.xlsx', '.xls')):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only CSV and Excel files are supported"
        )
    
    prediction_service = PredictionService(db)
    
    try:
        # Process file and make predictions
        results = await prediction_service.predict_from_file(
            file=file,
            model_name=model_name,
            model_version=model_version,
            user_id=current_user.id
        )
        
        return results
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"File prediction failed: {str(e)}"
        )


@router.get("/explain/{prediction_id}", response_model=ModelExplanation)
async def explain_prediction(
    prediction_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
) -> Any:
    """
    Get explanation for a specific prediction.
    """
    prediction_service = PredictionService(db)
    
    # Get prediction record
    prediction = await prediction_service.get_prediction(prediction_id, current_user.id)
    if not prediction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Prediction not found"
        )
    
    ml_engine = MLEngine()
    
    try:
        # Generate explanation
        explanation = await ml_engine.explain_prediction(
            model_name=prediction.model_name,
            features=prediction.features,
            model_version=prediction.model_version
        )
        
        return ModelExplanation(
            prediction_id=prediction_id,
            feature_importance=explanation["feature_importance"],
            shap_values=explanation.get("shap_values"),
            lime_explanation=explanation.get("lime_explanation"),
            explanation_method=explanation["method"]
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Explanation generation failed: {str(e)}"
        )


@router.get("/history", response_model=List[PredictionResponse])
async def get_prediction_history(
    skip: int = 0,
    limit: int = 100,
    model_name: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
) -> Any:
    """
    Get user's prediction history.
    """
    prediction_service = PredictionService(db)
    
    predictions = await prediction_service.get_user_predictions(
        user_id=current_user.id,
        skip=skip,
        limit=limit,
        model_name=model_name
    )
    
    return [
        PredictionResponse(
            id=p.id,
            prediction=p.prediction,
            confidence=p.confidence,
            model_name=p.model_name,
            model_version=p.model_version,
            features=p.features,
            created_at=p.created_at
        )
        for p in predictions
    ]


@router.delete("/{prediction_id}")
async def delete_prediction(
    prediction_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
) -> Any:
    """
    Delete a specific prediction.
    """
    prediction_service = PredictionService(db)
    
    success = await prediction_service.delete_prediction(prediction_id, current_user.id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Prediction not found"
        )
    
    return {"message": "Prediction deleted successfully"}
