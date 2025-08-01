"use client"

import { useState, useEffect } from 'react'
import { 
  BarChart3,
  TrendingUp,
  TrendingDown,
  Users,
  DollarSign,
  Calendar,
  Filter,
  Download,
  RefreshCw,
  PieChart,
  Activity,
  Target,
  Zap
} from 'lucide-react'

interface AnalyticsData {
  totalPredictions: number
  successRate: number
  avgConfidence: number
  topModel: string
  dailyPredictions: Array<{ date: string; count: number; accuracy: number }>
  modelPerformance: Array<{ name: string; accuracy: number; predictions: number }>
  industryBreakdown: Array<{ industry: string; count: number; successRate: number }>
  timeSeriesData: Array<{ date: string; predictions: number; success: number }>
}

interface MetricCardProps {
  title: string
  value: string | number
  change: number
  icon: React.ComponentType<any>
  trend: 'up' | 'down'
}

function MetricCard({ title, value, change, icon: Icon, trend }: MetricCardProps) {
  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="text-2xl font-semibold text-gray-900 mt-1">{value}</p>
        </div>
        <div className="h-12 w-12 bg-blue-50 rounded-lg flex items-center justify-center">
          <Icon className="h-6 w-6 text-blue-600" />
        </div>
      </div>
      <div className="mt-4 flex items-center">
        {trend === 'up' ? (
          <TrendingUp className="h-4 w-4 text-green-500 mr-1" />
        ) : (
          <TrendingDown className="h-4 w-4 text-red-500 mr-1" />
        )}
        <span className={`text-sm font-medium ${trend === 'up' ? 'text-green-600' : 'text-red-600'}`}>
          {Math.abs(change)}%
        </span>
        <span className="text-sm text-gray-500 ml-1">vs last month</span>
      </div>
    </div>
  )
}

export default function AnalyticsPage() {
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null)
  const [loading, setLoading] = useState(true)
  const [timeRange, setTimeRange] = useState('30d')

  useEffect(() => {
    // Mock analytics data - replace with actual API call
    const mockAnalytics: AnalyticsData = {
      totalPredictions: 15432,
      successRate: 84.7,
      avgConfidence: 0.78,
      topModel: 'Random Forest Predictor',
      dailyPredictions: Array.from({ length: 30 }, (_, i) => ({
        date: new Date(Date.now() - (29 - i) * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        count: Math.floor(Math.random() * 50) + 20,
        accuracy: Math.random() * 0.3 + 0.7
      })),
      modelPerformance: [
        { name: 'Random Forest', accuracy: 84.7, predictions: 5234 },
        { name: 'Decision Tree', accuracy: 82.3, predictions: 4567 },
        { name: 'Neural Network', accuracy: 79.8, predictions: 3456 },
        { name: 'QDA', accuracy: 76.4, predictions: 2175 }
      ],
      industryBreakdown: [
        { industry: 'FinTech', count: 3456, successRate: 87.2 },
        { industry: 'HealthTech', count: 2890, successRate: 83.5 },
        { industry: 'EdTech', count: 2234, successRate: 79.8 },
        { industry: 'E-commerce', count: 1987, successRate: 81.3 },
        { industry: 'AI/ML', count: 1765, successRate: 85.6 }
      ],
      timeSeriesData: Array.from({ length: 12 }, (_, i) => ({
        date: new Date(2024 + Math.floor(i / 12), i % 12, 1).toLocaleDateString('en-US', { month: 'short' }),
        predictions: Math.floor(Math.random() * 500) + 800,
        success: Math.floor(Math.random() * 400) + 600
      }))
    }

    setTimeout(() => {
      setAnalytics(mockAnalytics)
      setLoading(false)
    }, 1000)
  }, [timeRange])

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="flex items-center space-x-2">
          <RefreshCw className="h-6 w-6 animate-spin text-blue-600" />
          <span className="text-lg text-gray-600">Loading analytics...</span>
        </div>
      </div>
    )
  }

  if (!analytics) return null

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Analytics Dashboard</h1>
          <p className="text-sm text-gray-600 mt-1">
            Comprehensive insights into model performance and prediction patterns
          </p>
        </div>
        <div className="flex items-center space-x-3">
          <select
            value={timeRange}
            onChange={(e) => setTimeRange(e.target.value)}
            className="rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
          >
            <option value="7d">Last 7 days</option>
            <option value="30d">Last 30 days</option>
            <option value="90d">Last 3 months</option>
            <option value="1y">Last year</option>
          </select>
          <button className="inline-flex items-center px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
            <Filter className="h-4 w-4 mr-2" />
            Filter
          </button>
          <button className="inline-flex items-center px-3 py-2 text-sm font-medium text-blue-700 bg-blue-100 rounded-md hover:bg-blue-200">
            <Download className="h-4 w-4 mr-2" />
            Export
          </button>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <MetricCard
          title="Total Predictions"
          value={analytics.totalPredictions.toLocaleString()}
          change={12.5}
          icon={Target}
          trend="up"
        />
        <MetricCard
          title="Success Rate"
          value={`${analytics.successRate}%`}
          change={2.3}
          icon={TrendingUp}
          trend="up"
        />
        <MetricCard
          title="Avg Confidence"
          value={`${(analytics.avgConfidence * 100).toFixed(1)}%`}
          change={-1.2}
          icon={Zap}
          trend="down"
        />
        <MetricCard
          title="Top Model"
          value={analytics.topModel}
          change={5.7}
          icon={BarChart3}
          trend="up"
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Daily Predictions Chart */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Daily Predictions</h3>
            <Activity className="h-5 w-5 text-gray-400" />
          </div>
          <div className="space-y-3">
            {analytics.dailyPredictions.slice(-7).map((day, index) => (
              <div key={day.date} className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-2 h-2 bg-blue-600 rounded-full"></div>
                  <span className="text-sm font-medium text-gray-900">
                    {new Date(day.date).toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })}
                  </span>
                </div>
                <div className="flex items-center space-x-4">
                  <span className="text-sm text-gray-600">{day.count} predictions</span>
                  <span className="text-sm font-medium text-green-600">
                    {(day.accuracy * 100).toFixed(1)}% accuracy
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Model Performance */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Model Performance</h3>
            <BarChart3 className="h-5 w-5 text-gray-400" />
          </div>
          <div className="space-y-4">
            {analytics.modelPerformance.map((model, index) => (
              <div key={model.name}>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm font-medium text-gray-900">{model.name}</span>
                  <span className="text-sm text-gray-600">{model.accuracy}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-blue-600 h-2 rounded-full" 
                    style={{ width: `${model.accuracy}%` }}
                  ></div>
                </div>
                <div className="text-xs text-gray-500 mt-1">
                  {model.predictions.toLocaleString()} predictions
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Industry Breakdown */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-gray-900">Industry Breakdown</h3>
          <PieChart className="h-5 w-5 text-gray-400" />
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Industry
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Predictions
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Success Rate
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Trend
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {analytics.industryBreakdown.map((industry, index) => (
                <tr key={industry.industry} className="hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div className="flex items-center">
                      <div className={`w-3 h-3 rounded-full mr-3 ${
                        index === 0 ? 'bg-blue-600' :
                        index === 1 ? 'bg-green-600' :
                        index === 2 ? 'bg-yellow-600' :
                        index === 3 ? 'bg-purple-600' : 'bg-red-600'
                      }`}></div>
                      <span className="text-sm font-medium text-gray-900">{industry.industry}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-600">
                    {industry.count.toLocaleString()}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center">
                      <div className="w-16 bg-gray-200 rounded-full h-2 mr-2">
                        <div 
                          className="bg-green-600 h-2 rounded-full" 
                          style={{ width: `${industry.successRate}%` }}
                        ></div>
                      </div>
                      <span className="text-sm font-medium">{industry.successRate}%</span>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center">
                      <TrendingUp className="h-4 w-4 text-green-500 mr-1" />
                      <span className="text-sm font-medium text-green-600">
                        +{Math.floor(Math.random() * 10) + 1}%
                      </span>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Time Series Comparison */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-gray-900">Monthly Trends</h3>
          <Calendar className="h-5 w-5 text-gray-400" />
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
          {analytics.timeSeriesData.slice(-6).map((month, index) => (
            <div key={month.date} className="text-center">
              <div className="text-2xl font-bold text-blue-600 mb-1">
                {month.predictions}
              </div>
              <div className="text-xs text-gray-500 mb-2">{month.date}</div>
              <div className="w-full bg-gray-200 rounded-full h-1">
                <div 
                  className="bg-green-600 h-1 rounded-full" 
                  style={{ width: `${(month.success / month.predictions) * 100}%` }}
                ></div>
              </div>
              <div className="text-xs text-green-600 mt-1">
                {((month.success / month.predictions) * 100).toFixed(0)}% success
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
