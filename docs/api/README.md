# Decision Platform API Documentation

## Overview

The Decision Platform API provides AI-powered investment intelligence through a RESTful interface. Built on FastAPI, it offers high-performance endpoints for machine learning predictions, data management, and model explainability.

## Base URL

- **Development**: `http://localhost:8000`
- **Production**: `https://api.decision.is`

## Authentication

The API uses JWT (JSON Web Token) based authentication.

### Getting Started

1. **Register a new account**
2. **Login to get access tokens**
3. **Include the access token in your requests**

```bash
# Login to get tokens
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=your_email@example.com&password=your_password"
```

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### Using Tokens

Include the access token in the Authorization header:

```bash
curl -X GET "http://localhost:8000/api/v1/predictions/history" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Endpoints

### Authentication Endpoints

#### POST `/api/v1/auth/register`
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "secure_password",
  "full_name": "John Doe"
}
```

**Response:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "full_name": "John Doe",
  "is_active": true,
  "created_at": "2025-01-01T00:00:00Z"
}
```

#### POST `/api/v1/auth/login`
Login and get access tokens.

**Request Body (Form Data):**
```
username=user@example.com
password=secure_password
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### Prediction Endpoints

#### POST `/api/v1/predictions/predict`
Make a single investment prediction.

**Request Body:**
```json
{
  "model_name": "random_forest",
  "model_version": "1.0.0",
  "features": {
    "funding_total_usd": 1000000,
    "funding_rounds": 3,
    "founded_at_year": 2018,
    "category_code": "fintech",
    "country_code": "USA",
    "employee_count": 50,
    "has_angel_investors": true,
    "has_vc_investors": true,
    "time_to_first_funding": 12
  }
}
```

**Response:**
```json
{
  "id": 123,
  "prediction": 1,
  "confidence": 0.85,
  "model_name": "random_forest",
  "model_version": "1.0.0",
  "features": {
    "funding_total_usd": 1000000,
    "funding_rounds": 3,
    "founded_at_year": 2018,
    "category_code": "fintech",
    "country_code": "USA",
    "employee_count": 50,
    "has_angel_investors": true,
    "has_vc_investors": true,
    "time_to_first_funding": 12
  },
  "created_at": "2025-01-01T12:00:00Z"
}
```

#### POST `/api/v1/predictions/predict/batch`
Make batch predictions for multiple companies.

**Request Body:**
```json
{
  "model_name": "random_forest",
  "model_version": "1.0.0",
  "features_list": [
    {
      "funding_total_usd": 1000000,
      "funding_rounds": 3,
      "founded_at_year": 2018,
      "category_code": "fintech",
      "country_code": "USA",
      "employee_count": 50
    },
    {
      "funding_total_usd": 500000,
      "funding_rounds": 2,
      "founded_at_year": 2019,
      "category_code": "healthtech",
      "country_code": "USA",
      "employee_count": 25
    }
  ]
}
```

**Response:**
```json
{
  "predictions": [
    {
      "id": 124,
      "prediction": 1,
      "confidence": 0.85,
      "model_name": "random_forest",
      "model_version": "1.0.0",
      "features": {...},
      "created_at": "2025-01-01T12:00:00Z"
    },
    {
      "id": 125,
      "prediction": 0,
      "confidence": 0.72,
      "model_name": "random_forest",
      "model_version": "1.0.0",
      "features": {...},
      "created_at": "2025-01-01T12:00:00Z"
    }
  ],
  "total_predictions": 2,
  "successful_predictions": 2,
  "failed_predictions": 0
}
```

#### POST `/api/v1/predictions/predict/file`
Make predictions from uploaded CSV/Excel file.

**Request (Multipart Form Data):**
- `model_name`: string (required)
- `file`: CSV or Excel file (required)
- `model_version`: string (optional)

**Example:**
```bash
curl -X POST "http://localhost:8000/api/v1/predictions/predict/file" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "model_name=random_forest" \
  -F "file=@startups.csv"
```

#### GET `/api/v1/predictions/explain/{prediction_id}`
Get explanation for a specific prediction.

**Response:**
```json
{
  "prediction_id": 123,
  "feature_importance": {
    "funding_total_usd": 0.35,
    "employee_count": 0.22,
    "funding_rounds": 0.18,
    "time_to_first_funding": 0.15,
    "category_code": 0.10
  },
  "shap_values": {
    "base_value": 0.3,
    "values": [0.15, -0.05, 0.08, 0.12, -0.02]
  },
  "explanation_method": "shap"
}
```

#### GET `/api/v1/predictions/history`
Get user's prediction history.

**Query Parameters:**
- `skip`: int (default: 0) - Number of records to skip
- `limit`: int (default: 100) - Maximum number of records to return
- `model_name`: string (optional) - Filter by model name

**Response:**
```json
[
  {
    "id": 123,
    "prediction": 1,
    "confidence": 0.85,
    "model_name": "random_forest",
    "model_version": "1.0.0",
    "features": {...},
    "created_at": "2025-01-01T12:00:00Z"
  }
]
```

### Model Management Endpoints

#### GET `/api/v1/models`
List all available models.

**Response:**
```json
[
  {
    "name": "random_forest",
    "version": "1.0.0",
    "type": "ensemble",
    "description": "Random Forest model for startup success prediction",
    "features": ["funding_total_usd", "funding_rounds", "founded_at_year"],
    "performance_metrics": {
      "accuracy": 0.87,
      "precision": 0.85,
      "recall": 0.83,
      "f1_score": 0.84
    },
    "training_date": "2025-01-01T00:00:00Z",
    "is_trained": true
  }
]
```

#### GET `/api/v1/models/{model_name}`
Get detailed information about a specific model.

#### POST `/api/v1/models/{model_name}/retrain`
Retrain a model with new data.

**Request Body:**
```json
{
  "training_data": "base64_encoded_csv_data",
  "target_column": "success"
}
```

### Data Management Endpoints

#### POST `/api/v1/data/upload`
Upload and validate dataset.

**Request (Multipart Form Data):**
- `file`: CSV or Excel file
- `dataset_name`: string
- `description`: string (optional)

#### GET `/api/v1/data/datasets`
List user's datasets.

#### GET `/api/v1/data/datasets/{dataset_id}`
Get dataset information and preview.

#### DELETE `/api/v1/data/datasets/{dataset_id}`
Delete a dataset.

## Error Handling

The API uses standard HTTP status codes and returns detailed error information.

### Error Response Format

```json
{
  "detail": "Error message describing what went wrong",
  "error_code": "SPECIFIC_ERROR_CODE",
  "timestamp": "2025-01-01T12:00:00Z"
}
```

### Common Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

## Rate Limiting

The API implements rate limiting to ensure fair usage:

- **Default limit**: 100 requests per minute per user
- **Burst limit**: 10 requests per second

Rate limit information is included in response headers:
- `X-RateLimit-Limit`: Request limit per window
- `X-RateLimit-Remaining`: Remaining requests in current window
- `X-RateLimit-Reset`: Time when the rate limit resets

## SDKs and Examples

### Python SDK Example

```python
import requests
import json

class DecisionAPI:
    def __init__(self, base_url, access_token):
        self.base_url = base_url
        self.headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
    
    def predict(self, model_name, features):
        payload = {
            'model_name': model_name,
            'features': features
        }
        response = requests.post(
            f'{self.base_url}/api/v1/predictions/predict',
            headers=self.headers,
            json=payload
        )
        return response.json()

# Usage
api = DecisionAPI('http://localhost:8000', 'your_access_token')

result = api.predict('random_forest', {
    'funding_total_usd': 1000000,
    'funding_rounds': 3,
    'founded_at_year': 2018,
    'category_code': 'fintech',
    'country_code': 'USA',
    'employee_count': 50
})

print(f"Prediction: {result['prediction']}")
print(f"Confidence: {result['confidence']}")
```

### JavaScript/Node.js Example

```javascript
const axios = require('axios');

class DecisionAPI {
    constructor(baseUrl, accessToken) {
        this.baseUrl = baseUrl;
        this.client = axios.create({
            baseURL: baseUrl,
            headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json'
            }
        });
    }

    async predict(modelName, features) {
        try {
            const response = await this.client.post('/api/v1/predictions/predict', {
                model_name: modelName,
                features: features
            });
            return response.data;
        } catch (error) {
            throw new Error(`Prediction failed: ${error.response?.data?.detail || error.message}`);
        }
    }
}

// Usage
const api = new DecisionAPI('http://localhost:8000', 'your_access_token');

api.predict('random_forest', {
    funding_total_usd: 1000000,
    funding_rounds: 3,
    founded_at_year: 2018,
    category_code: 'fintech',
    country_code: 'USA',
    employee_count: 50
}).then(result => {
    console.log(`Prediction: ${result.prediction}`);
    console.log(`Confidence: ${result.confidence}`);
}).catch(error => {
    console.error('Error:', error.message);
});
```

## Webhooks

The API supports webhooks for real-time notifications:

- Model training completion
- Batch prediction completion
- Data processing status updates

### Webhook Configuration

```json
{
  "url": "https://your-app.com/webhooks/decision",
  "events": ["model.training.completed", "prediction.batch.completed"],
  "secret": "your_webhook_secret"
}
```

## Support

For API support and questions:
- Documentation: [https://docs.decision.is](https://docs.decision.is)
- GitHub Issues: [https://github.com/ramin-fazli/decision/issues](https://github.com/ramin-fazli/decision/issues)
- Email: support@decision.is
