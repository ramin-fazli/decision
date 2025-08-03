"use client"

import { useState, useEffect } from 'react'
import { 
  Brain,
  Activity,
  TrendingUp,
  Settings,
  Play,
  Pause,
  BarChart3,
  Info,
  Zap,
  Target,
  RefreshCw
} from 'lucide-react'

interface ModelInfo {
  id: string
  name: string
  type: string
  status: 'active' | 'training' | 'inactive'
  accuracy: number
  precision: number
  recall: number
  f1_score: number
  last_trained: string
  total_predictions: number
  description: string
}

interface ModelCardProps {
  model: ModelInfo
  onToggleStatus: (id: string) => void
  onRetrain: (id: string) => void
}

function ModelCard({ model, onToggleStatus, onRetrain }: ModelCardProps) {
  const statusColors = {
    active: 'bg-green-100 text-green-800',
    training: 'bg-yellow-100 text-yellow-800',
    inactive: 'bg-gray-100 text-gray-800'
  }

  const statusIcons = {
    active: Play,
    training: RefreshCw,
    inactive: Pause
  }

  const StatusIcon = statusIcons[model.status]

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-start justify-between">
        <div className="flex items-start space-x-3">
          <div className="h-12 w-12 bg-blue-50 rounded-lg flex items-center justify-center">
            <Brain className="h-6 w-6 text-blue-600" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-900">{model.name}</h3>
            <p className="text-sm text-gray-600">{model.type}</p>
            <p className="text-xs text-gray-500 mt-1">{model.description}</p>
          </div>
        </div>
        <div className="flex items-center space-x-2">
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusColors[model.status]}`}>
            <StatusIcon className={`h-3 w-3 mr-1 ${model.status === 'training' ? 'animate-spin' : ''}`} />
            {model.status.charAt(0).toUpperCase() + model.status.slice(1)}
          </span>
        </div>
      </div>

      <div className="mt-6 grid grid-cols-2 gap-4">
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">{(model.accuracy * 100).toFixed(1)}%</div>
          <div className="text-sm text-gray-500">Accuracy</div>
        </div>
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">{model.total_predictions.toLocaleString()}</div>
          <div className="text-sm text-gray-500">Predictions</div>
        </div>
      </div>

      <div className="mt-6 space-y-3">
        <div className="flex justify-between text-sm">
          <span className="text-gray-600">Precision</span>
          <span className="font-medium">{(model.precision * 100).toFixed(1)}%</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-600">Recall</span>
          <span className="font-medium">{(model.recall * 100).toFixed(1)}%</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-600">F1 Score</span>
          <span className="font-medium">{(model.f1_score * 100).toFixed(1)}%</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-600">Last Trained</span>
          <span className="font-medium">{new Date(model.last_trained).toLocaleDateString()}</span>
        </div>
      </div>

      <div className="mt-6 flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <button
            onClick={() => onToggleStatus(model.id)}
            className={`inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-md ${
              model.status === 'active' 
                ? 'text-red-700 bg-red-100 hover:bg-red-200' 
                : 'text-green-700 bg-green-100 hover:bg-green-200'
            }`}
          >
            {model.status === 'active' ? (
              <>
                <Pause className="h-3 w-3 mr-1" />
                Deactivate
              </>
            ) : (
              <>
                <Play className="h-3 w-3 mr-1" />
                Activate
              </>
            )}
          </button>
          <button
            onClick={() => onRetrain(model.id)}
            disabled={model.status === 'training'}
            className="inline-flex items-center px-3 py-1.5 text-xs font-medium text-blue-700 bg-blue-100 rounded-md hover:bg-blue-200 disabled:opacity-50"
          >
            <RefreshCw className={`h-3 w-3 mr-1 ${model.status === 'training' ? 'animate-spin' : ''}`} />
            {model.status === 'training' ? 'Training...' : 'Retrain'}
          </button>
        </div>
        <button className="text-gray-400 hover:text-gray-600">
          <Settings className="h-4 w-4" />
        </button>
      </div>
    </div>
  )
}

export default function ModelsPage() {
  const [models, setModels] = useState<ModelInfo[]>([])
  const [loading, setLoading] = useState(true)

  // Status colors for model status badges
  const statusColors = {
    active: 'bg-green-100 text-green-800',
    training: 'bg-yellow-100 text-yellow-800',
    inactive: 'bg-gray-100 text-gray-800'
  }

  useEffect(() => {
    // Mock data - replace with actual API call
    const mockModels: ModelInfo[] = [
      {
        id: 'random_forest',
        name: 'Random Forest Predictor',
        type: 'Ensemble Learning',
        status: 'active',
        accuracy: 0.847,
        precision: 0.832,
        recall: 0.861,
        f1_score: 0.846,
        last_trained: '2025-01-10T00:00:00Z',
        total_predictions: 1247,
        description: 'Optimized for startup success prediction with high accuracy'
      },
      {
        id: 'decision_tree',
        name: 'Decision Tree Analyzer',
        type: 'Tree-based Learning',
        status: 'active',
        accuracy: 0.823,
        precision: 0.810,
        recall: 0.835,
        f1_score: 0.822,
        last_trained: '2025-01-08T00:00:00Z',
        total_predictions: 980,
        description: 'Interpretable model for understanding decision patterns'
      },
      {
        id: 'neural_network',
        name: 'Neural Network Model',
        type: 'Deep Learning',
        status: 'training',
        accuracy: 0.798,
        precision: 0.785,
        recall: 0.812,
        f1_score: 0.798,
        last_trained: '2025-01-05T00:00:00Z',
        total_predictions: 756,
        description: 'Deep learning approach for complex pattern recognition'
      },
      {
        id: 'qda',
        name: 'QDA Classifier',
        type: 'Statistical Learning',
        status: 'inactive',
        accuracy: 0.764,
        precision: 0.751,
        recall: 0.778,
        f1_score: 0.764,
        last_trained: '2025-01-03T00:00:00Z',
        total_predictions: 423,
        description: 'Quadratic discriminant analysis for statistical classification'
      }
    ]

    setTimeout(() => {
      setModels(mockModels)
      setLoading(false)
    }, 1000)
  }, [])

  const handleToggleStatus = (id: string) => {
    setModels(models.map(model => 
      model.id === id 
        ? { ...model, status: model.status === 'active' ? 'inactive' : 'active' }
        : model
    ))
  }

  const handleRetrain = (id: string) => {
    setModels(models.map(model => 
      model.id === id 
        ? { ...model, status: 'training' }
        : model
    ))

    // Simulate training completion
    setTimeout(() => {
      setModels(models.map(model => 
        model.id === id 
          ? { 
              ...model, 
              status: 'active',
              accuracy: model.accuracy + (Math.random() - 0.5) * 0.05,
              last_trained: new Date().toISOString()
            }
          : model
      ))
    }, 5000)
  }

  const activeModels = models.filter(m => m.status === 'active').length
  const avgAccuracy = models.reduce((acc, model) => acc + model.accuracy, 0) / models.length
  const totalPredictions = models.reduce((acc, model) => acc + model.total_predictions, 0)

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-2"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="animate-pulse bg-white rounded-lg p-6 border">
              <div className="h-6 bg-gray-200 rounded w-3/4 mb-4"></div>
              <div className="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
              <div className="h-4 bg-gray-200 rounded w-2/3"></div>
            </div>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">ML Models</h1>
          <p className="text-sm text-gray-600 mt-1">
            Manage and monitor your machine learning models
          </p>
        </div>
        <button className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700">
          <Brain className="h-4 w-4 mr-2" />
          Train New Model
        </button>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-green-100 rounded-lg flex items-center justify-center">
              <Activity className="h-5 w-5 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Active Models</p>
              <p className="text-2xl font-semibold text-gray-900">{activeModels}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-blue-100 rounded-lg flex items-center justify-center">
              <TrendingUp className="h-5 w-5 text-blue-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Avg. Accuracy</p>
              <p className="text-2xl font-semibold text-gray-900">{(avgAccuracy * 100).toFixed(1)}%</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-purple-100 rounded-lg flex items-center justify-center">
              <Target className="h-5 w-5 text-purple-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Predictions</p>
              <p className="text-2xl font-semibold text-gray-900">{totalPredictions.toLocaleString()}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Models Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {models.map((model) => (
          <ModelCard
            key={model.id}
            model={model}
            onToggleStatus={handleToggleStatus}
            onRetrain={handleRetrain}
          />
        ))}
      </div>

      {/* Model Comparison */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Model Performance Comparison</h2>
        </div>
        <div className="p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 font-semibold text-sm text-gray-600">Model</th>
                  <th className="text-left py-3 px-4 font-semibold text-sm text-gray-600">Accuracy</th>
                  <th className="text-left py-3 px-4 font-semibold text-sm text-gray-600">Precision</th>
                  <th className="text-left py-3 px-4 font-semibold text-sm text-gray-600">Recall</th>
                  <th className="text-left py-3 px-4 font-semibold text-sm text-gray-600">F1 Score</th>
                  <th className="text-left py-3 px-4 font-semibold text-sm text-gray-600">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {models.map((model) => (
                  <tr key={model.id} className="hover:bg-gray-50">
                    <td className="py-3 px-4">
                      <div className="flex items-center">
                        <Brain className="h-4 w-4 mr-2 text-blue-600" />
                        <span className="font-medium text-sm">{model.name}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <div className="flex items-center">
                        <div className="w-16 bg-gray-200 rounded-full h-2 mr-2">
                          <div 
                            className="bg-blue-600 h-2 rounded-full" 
                            style={{ width: `${model.accuracy * 100}%` }}
                          ></div>
                        </div>
                        <span className="text-sm font-medium">{(model.accuracy * 100).toFixed(1)}%</span>
                      </div>
                    </td>
                    <td className="py-3 px-4 text-sm">{(model.precision * 100).toFixed(1)}%</td>
                    <td className="py-3 px-4 text-sm">{(model.recall * 100).toFixed(1)}%</td>
                    <td className="py-3 px-4 text-sm">{(model.f1_score * 100).toFixed(1)}%</td>
                    <td className="py-3 px-4">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusColors[model.status]}`}>
                        {model.status.charAt(0).toUpperCase() + model.status.slice(1)}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
