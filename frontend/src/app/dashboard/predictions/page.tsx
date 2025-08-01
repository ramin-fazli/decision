"use client"

import { useState, useEffect } from 'react'
import { 
  Target,
  Brain,
  Plus,
  Search,
  Filter,
  Download,
  Eye,
  TrendingUp,
  TrendingDown,
  Calendar,
  BarChart3
} from 'lucide-react'

interface PredictionFormData {
  model_name: string
  features: {
    funding_total_usd: number
    funding_rounds: number
    founded_at_year: number
    category_code: string
    country_code: string
    employee_count: number
    has_angel_investors: boolean
    has_vc_investors: boolean
    time_to_first_funding: number
  }
}

interface PredictionResult {
  id: number
  prediction: number
  confidence: number
  model_name: string
  features: any
  created_at: string
}

export default function PredictionsPage() {
  const [showNewPrediction, setShowNewPrediction] = useState(false)
  const [predictions, setPredictions] = useState<PredictionResult[]>([])
  const [loading, setLoading] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  
  const [formData, setFormData] = useState<PredictionFormData>({
    model_name: 'random_forest',
    features: {
      funding_total_usd: 1000000,
      funding_rounds: 3,
      founded_at_year: 2020,
      category_code: 'fintech',
      country_code: 'USA',
      employee_count: 25,
      has_angel_investors: true,
      has_vc_investors: true,
      time_to_first_funding: 12
    }
  })

  // Mock predictions data
  useEffect(() => {
    const mockPredictions: PredictionResult[] = [
      {
        id: 1,
        prediction: 1,
        confidence: 0.87,
        model_name: 'random_forest',
        features: { company: 'TechStart AI', sector: 'AI/ML' },
        created_at: '2025-01-15T10:30:00Z'
      },
      {
        id: 2,
        prediction: 0,
        confidence: 0.73,
        model_name: 'neural_network',
        features: { company: 'FinTech Solutions', sector: 'FinTech' },
        created_at: '2025-01-15T09:45:00Z'
      },
      {
        id: 3,
        prediction: 1,
        confidence: 0.91,
        model_name: 'decision_tree',
        features: { company: 'Green Energy Co', sector: 'CleanTech' },
        created_at: '2025-01-15T08:20:00Z'
      }
    ]
    setPredictions(mockPredictions)
  }, [])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      // Mock API call - replace with actual API endpoint
      await new Promise(resolve => setTimeout(resolve, 2000))
      
      const newPrediction: PredictionResult = {
        id: predictions.length + 1,
        prediction: Math.random() > 0.5 ? 1 : 0,
        confidence: 0.75 + Math.random() * 0.25,
        model_name: formData.model_name,
        features: { company: 'New Company', sector: formData.features.category_code },
        created_at: new Date().toISOString()
      }

      setPredictions([newPrediction, ...predictions])
      setShowNewPrediction(false)
      setLoading(false)
    } catch (error) {
      setLoading(false)
      console.error('Prediction failed:', error)
    }
  }

  const filteredPredictions = predictions.filter(prediction =>
    prediction.features.company.toLowerCase().includes(searchTerm.toLowerCase()) ||
    prediction.model_name.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const formatTimestamp = (timestamp: string) => {
    const date = new Date(timestamp)
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Predictions</h1>
          <p className="text-sm text-gray-600 mt-1">
            Create and manage investment predictions using AI models
          </p>
        </div>
        <button
          onClick={() => setShowNewPrediction(true)}
          className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700"
        >
          <Plus className="h-4 w-4 mr-2" />
          New Prediction
        </button>
      </div>

      {/* New Prediction Form */}
      {showNewPrediction && (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-semibold text-gray-900">Create New Prediction</h2>
            <button
              onClick={() => setShowNewPrediction(false)}
              className="text-gray-400 hover:text-gray-600"
            >
              ×
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Model
                </label>
                <select
                  value={formData.model_name}
                  onChange={(e) => setFormData({ ...formData, model_name: e.target.value })}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                >
                  <option value="random_forest">Random Forest</option>
                  <option value="decision_tree">Decision Tree</option>
                  <option value="neural_network">Neural Network</option>
                  <option value="qda">QDA</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Funding Total (USD)
                </label>
                <input
                  type="number"
                  value={formData.features.funding_total_usd}
                  onChange={(e) => setFormData({
                    ...formData,
                    features: { ...formData.features, funding_total_usd: parseInt(e.target.value) }
                  })}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Funding Rounds
                </label>
                <input
                  type="number"
                  value={formData.features.funding_rounds}
                  onChange={(e) => setFormData({
                    ...formData,
                    features: { ...formData.features, funding_rounds: parseInt(e.target.value) }
                  })}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Founded Year
                </label>
                <input
                  type="number"
                  value={formData.features.founded_at_year}
                  onChange={(e) => setFormData({
                    ...formData,
                    features: { ...formData.features, founded_at_year: parseInt(e.target.value) }
                  })}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Category
                </label>
                <select
                  value={formData.features.category_code}
                  onChange={(e) => setFormData({
                    ...formData,
                    features: { ...formData.features, category_code: e.target.value }
                  })}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                >
                  <option value="fintech">FinTech</option>
                  <option value="ai">AI/ML</option>
                  <option value="healthcare">Healthcare</option>
                  <option value="cleantech">CleanTech</option>
                  <option value="ecommerce">E-commerce</option>
                  <option value="saas">SaaS</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Country
                </label>
                <select
                  value={formData.features.country_code}
                  onChange={(e) => setFormData({
                    ...formData,
                    features: { ...formData.features, country_code: e.target.value }
                  })}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                >
                  <option value="USA">United States</option>
                  <option value="UK">United Kingdom</option>
                  <option value="CAN">Canada</option>
                  <option value="DEU">Germany</option>
                  <option value="FRA">France</option>
                </select>
              </div>
            </div>

            <div className="flex items-center justify-end space-x-3">
              <button
                type="button"
                onClick={() => setShowNewPrediction(false)}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={loading}
                className="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 disabled:opacity-50"
              >
                {loading ? 'Predicting...' : 'Create Prediction'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Filters and Search */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search predictions..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-md text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
            <button className="inline-flex items-center px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
              <Filter className="h-4 w-4 mr-2" />
              Filter
            </button>
          </div>
          <button className="inline-flex items-center px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
            <Download className="h-4 w-4 mr-2" />
            Export
          </button>
        </div>
      </div>

      {/* Predictions Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Recent Predictions</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Company
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Model
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Prediction
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Confidence
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredPredictions.map((prediction) => (
                <tr key={prediction.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {prediction.features.company}
                    </div>
                    <div className="text-sm text-gray-500">
                      {prediction.features.sector}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <Brain className="h-4 w-4 mr-2 text-blue-600" />
                      <span className="text-sm text-gray-900 capitalize">
                        {prediction.model_name.replace('_', ' ')}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      prediction.prediction === 1 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {prediction.prediction === 1 ? (
                        <>
                          <TrendingUp className="h-3 w-3 mr-1" />
                          Success
                        </>
                      ) : (
                        <>
                          <TrendingDown className="h-3 w-3 mr-1" />
                          Risk
                        </>
                      )}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-16 bg-gray-200 rounded-full h-2 mr-2">
                        <div 
                          className="bg-blue-600 h-2 rounded-full" 
                          style={{ width: `${prediction.confidence * 100}%` }}
                        ></div>
                      </div>
                      <span className="text-sm text-gray-900">
                        {(prediction.confidence * 100).toFixed(1)}%
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {formatTimestamp(prediction.created_at)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <div className="flex items-center space-x-2">
                      <button className="text-blue-600 hover:text-blue-700">
                        <Eye className="h-4 w-4" />
                      </button>
                      <button className="text-green-600 hover:text-green-700">
                        <BarChart3 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
