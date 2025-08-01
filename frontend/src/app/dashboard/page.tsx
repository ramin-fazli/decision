"use client"

import { useState, useEffect } from 'react'
import { 
  TrendingUp, 
  TrendingDown,
  Activity,
  Target,
  Brain,
  Database,
  Users,
  BarChart3,
  ArrowUpRight,
  ArrowDownRight,
  Calendar,
  Clock
} from 'lucide-react'

interface MetricCardProps {
  title: string
  value: string
  change: string
  changeType: 'positive' | 'negative' | 'neutral'
  icon: React.ComponentType<any>
}

function MetricCard({ title, value, change, changeType, icon: Icon }: MetricCardProps) {
  const changeColors = {
    positive: 'text-green-600',
    negative: 'text-red-600',
    neutral: 'text-gray-600'
  }

  const changeIcons = {
    positive: TrendingUp,
    negative: TrendingDown,
    neutral: Activity
  }

  const ChangeIcon = changeIcons[changeType]

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="text-2xl font-semibold text-gray-900 mt-2">{value}</p>
        </div>
        <div className="h-12 w-12 bg-blue-50 rounded-lg flex items-center justify-center">
          <Icon className="h-6 w-6 text-blue-600" />
        </div>
      </div>
      <div className="mt-4 flex items-center">
        <ChangeIcon className={`h-4 w-4 ${changeColors[changeType]}`} />
        <span className={`text-sm font-medium ml-1 ${changeColors[changeType]}`}>
          {change}
        </span>
        <span className="text-sm text-gray-500 ml-1">from last month</span>
      </div>
    </div>
  )
}

interface RecentPrediction {
  id: number
  company: string
  model: string
  prediction: number
  confidence: number
  timestamp: string
}

export default function DashboardPage() {
  const [recentPredictions, setRecentPredictions] = useState<RecentPrediction[]>([])
  const [loading, setLoading] = useState(true)

  // Mock data - replace with actual API calls
  useEffect(() => {
    const mockData: RecentPrediction[] = [
      {
        id: 1,
        company: "TechStart AI",
        model: "Random Forest",
        prediction: 1,
        confidence: 0.87,
        timestamp: "2025-01-15T10:30:00Z"
      },
      {
        id: 2,
        company: "FinTech Solutions",
        model: "Neural Network",
        prediction: 0,
        confidence: 0.73,
        timestamp: "2025-01-15T09:45:00Z"
      },
      {
        id: 3,
        company: "Green Energy Co",
        model: "Decision Tree",
        prediction: 1,
        confidence: 0.91,
        timestamp: "2025-01-15T08:20:00Z"
      },
      {
        id: 4,
        company: "HealthTech Plus",
        model: "QDA",
        prediction: 1,
        confidence: 0.79,
        timestamp: "2025-01-14T16:15:00Z"
      }
    ]

    setTimeout(() => {
      setRecentPredictions(mockData)
      setLoading(false)
    }, 1000)
  }, [])

  const formatTimestamp = (timestamp: string) => {
    const date = new Date(timestamp)
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Dashboard Overview</h1>
          <p className="text-sm text-gray-600 mt-1">
            Welcome back, Ramin. Here's what's happening with your investment intelligence platform.
          </p>
        </div>
        <div className="flex items-center space-x-3">
          <button className="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
            <Calendar className="h-4 w-4 mr-2" />
            Last 30 days
          </button>
        </div>
      </div>

      {/* Metrics Cards */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <MetricCard
          title="Total Predictions"
          value="1,247"
          change="+12.5%"
          changeType="positive"
          icon={Target}
        />
        <MetricCard
          title="Model Accuracy"
          value="84.7%"
          change="+2.1%"
          changeType="positive"
          icon={Brain}
        />
        <MetricCard
          title="Active Models"
          value="4"
          change="0%"
          changeType="neutral"
          icon={Activity}
        />
        <MetricCard
          title="Data Points"
          value="15.2K"
          change="+8.3%"
          changeType="positive"
          icon={Database}
        />
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Predictions */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow-sm border border-gray-200">
            <div className="p-6 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h2 className="text-lg font-semibold text-gray-900">Recent Predictions</h2>
                <button className="text-sm text-blue-600 hover:text-blue-700 font-medium">
                  View all
                </button>
              </div>
            </div>
            <div className="p-6">
              {loading ? (
                <div className="space-y-4">
                  {[...Array(4)].map((_, i) => (
                    <div key={i} className="animate-pulse">
                      <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                      <div className="h-3 bg-gray-200 rounded w-1/2"></div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="space-y-4">
                  {recentPredictions.map((prediction) => (
                    <div key={prediction.id} className="flex items-center justify-between py-3 border-b border-gray-100 last:border-b-0">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3">
                          <div className={`w-3 h-3 rounded-full ${
                            prediction.prediction === 1 ? 'bg-green-400' : 'bg-red-400'
                          }`}></div>
                          <div>
                            <p className="text-sm font-medium text-gray-900">{prediction.company}</p>
                            <p className="text-xs text-gray-500">{prediction.model}</p>
                          </div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="flex items-center space-x-2">
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            prediction.prediction === 1 
                              ? 'bg-green-100 text-green-800' 
                              : 'bg-red-100 text-red-800'
                          }`}>
                            {prediction.prediction === 1 ? 'Success' : 'Risk'}
                          </span>
                          <span className="text-sm text-gray-500">
                            {(prediction.confidence * 100).toFixed(0)}%
                          </span>
                        </div>
                        <p className="text-xs text-gray-400 mt-1">
                          {formatTimestamp(prediction.timestamp)}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Quick Actions & Model Status */}
        <div className="space-y-6">
          {/* Quick Actions */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
            <div className="space-y-3">
              <button className="w-full flex items-center justify-between p-3 text-left text-sm font-medium text-gray-700 bg-gray-50 rounded-lg hover:bg-gray-100">
                <div className="flex items-center">
                  <Target className="h-4 w-4 mr-3 text-blue-600" />
                  New Prediction
                </div>
                <ArrowUpRight className="h-4 w-4" />
              </button>
              <button className="w-full flex items-center justify-between p-3 text-left text-sm font-medium text-gray-700 bg-gray-50 rounded-lg hover:bg-gray-100">
                <div className="flex items-center">
                  <Database className="h-4 w-4 mr-3 text-green-600" />
                  Upload Data
                </div>
                <ArrowUpRight className="h-4 w-4" />
              </button>
              <button className="w-full flex items-center justify-between p-3 text-left text-sm font-medium text-gray-700 bg-gray-50 rounded-lg hover:bg-gray-100">
                <div className="flex items-center">
                  <BarChart3 className="h-4 w-4 mr-3 text-purple-600" />
                  View Analytics
                </div>
                <ArrowUpRight className="h-4 w-4" />
              </button>
            </div>
          </div>

          {/* Model Performance */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Model Performance</h3>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-900">Random Forest</p>
                  <p className="text-xs text-gray-500">84.7% accuracy</p>
                </div>
                <div className="w-16 bg-gray-200 rounded-full h-2">
                  <div className="bg-green-600 h-2 rounded-full" style={{ width: '84.7%' }}></div>
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-900">Decision Tree</p>
                  <p className="text-xs text-gray-500">82.3% accuracy</p>
                </div>
                <div className="w-16 bg-gray-200 rounded-full h-2">
                  <div className="bg-blue-600 h-2 rounded-full" style={{ width: '82.3%' }}></div>
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-900">Neural Network</p>
                  <p className="text-xs text-gray-500">79.8% accuracy</p>
                </div>
                <div className="w-16 bg-gray-200 rounded-full h-2">
                  <div className="bg-purple-600 h-2 rounded-full" style={{ width: '79.8%' }}></div>
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-900">QDA</p>
                  <p className="text-xs text-gray-500">76.4% accuracy</p>
                </div>
                <div className="w-16 bg-gray-200 rounded-full h-2">
                  <div className="bg-orange-600 h-2 rounded-full" style={{ width: '76.4%' }}></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
