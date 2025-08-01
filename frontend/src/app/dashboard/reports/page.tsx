"use client"

import { useState, useEffect } from 'react'
import { 
  FileText,
  Download,
  Calendar,
  Filter,
  Search,
  Eye,
  Share,
  BarChart3,
  TrendingUp,
  Users,
  Target,
  Clock,
  CheckCircle,
  AlertCircle,
  Plus
} from 'lucide-react'

interface Report {
  id: string
  title: string
  type: 'performance' | 'predictions' | 'models' | 'custom'
  status: 'completed' | 'generating' | 'failed'
  createdAt: string
  generatedBy: string
  description: string
  size: string
  format: 'pdf' | 'excel' | 'csv'
}

interface ReportTemplate {
  id: string
  name: string
  description: string
  type: 'performance' | 'predictions' | 'models' | 'custom'
  icon: React.ComponentType<any>
}

interface ReportCardProps {
  report: Report
  onDownload: (id: string) => void
  onView: (id: string) => void
  onShare: (id: string) => void
}

function ReportCard({ report, onDownload, onView, onShare }: ReportCardProps) {
  const statusColors = {
    completed: 'bg-green-100 text-green-800',
    generating: 'bg-yellow-100 text-yellow-800',
    failed: 'bg-red-100 text-red-800'
  }

  const statusIcons = {
    completed: CheckCircle,
    generating: Clock,
    failed: AlertCircle
  }

  const typeColors = {
    performance: 'bg-blue-50 text-blue-600',
    predictions: 'bg-green-50 text-green-600',
    models: 'bg-purple-50 text-purple-600',
    custom: 'bg-orange-50 text-orange-600'
  }

  const StatusIcon = statusIcons[report.status]

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-start justify-between">
        <div className="flex items-start space-x-3">
          <div className="h-10 w-10 bg-gray-100 rounded-lg flex items-center justify-center">
            <FileText className="h-5 w-5 text-gray-600" />
          </div>
          <div className="flex-1">
            <h3 className="text-sm font-semibold text-gray-900">{report.title}</h3>
            <p className="text-xs text-gray-500 mt-1">{report.description}</p>
            <div className="flex items-center space-x-4 mt-2">
              <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${typeColors[report.type]}`}>
                {report.type.charAt(0).toUpperCase() + report.type.slice(1)}
              </span>
              <span className="text-xs text-gray-500">{report.size}</span>
              <span className="text-xs text-gray-500">{report.format.toUpperCase()}</span>
            </div>
          </div>
        </div>
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusColors[report.status]}`}>
          <StatusIcon className={`h-3 w-3 mr-1 ${report.status === 'generating' ? 'animate-spin' : ''}`} />
          {report.status.charAt(0).toUpperCase() + report.status.slice(1)}
        </span>
      </div>

      <div className="mt-4 text-xs text-gray-500">
        <div className="flex justify-between">
          <span>Created: {new Date(report.createdAt).toLocaleDateString()}</span>
          <span>By: {report.generatedBy}</span>
        </div>
      </div>

      <div className="mt-6 flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <button
            onClick={() => onView(report.id)}
            disabled={report.status !== 'completed'}
            className="inline-flex items-center px-2 py-1 text-xs font-medium text-blue-700 bg-blue-100 rounded hover:bg-blue-200 disabled:opacity-50"
          >
            <Eye className="h-3 w-3 mr-1" />
            View
          </button>
          <button
            onClick={() => onDownload(report.id)}
            disabled={report.status !== 'completed'}
            className="inline-flex items-center px-2 py-1 text-xs font-medium text-green-700 bg-green-100 rounded hover:bg-green-200 disabled:opacity-50"
          >
            <Download className="h-3 w-3 mr-1" />
            Download
          </button>
          <button
            onClick={() => onShare(report.id)}
            disabled={report.status !== 'completed'}
            className="inline-flex items-center px-2 py-1 text-xs font-medium text-gray-700 bg-gray-100 rounded hover:bg-gray-200 disabled:opacity-50"
          >
            <Share className="h-3 w-3 mr-1" />
            Share
          </button>
        </div>
      </div>
    </div>
  )
}

export default function ReportsPage() {
  const [reports, setReports] = useState<Report[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [typeFilter, setTypeFilter] = useState<string>('all')
  const [showNewReport, setShowNewReport] = useState(false)

  const reportTemplates: ReportTemplate[] = [
    {
      id: 'performance',
      name: 'Performance Report',
      description: 'Comprehensive model performance analysis',
      type: 'performance',
      icon: BarChart3
    },
    {
      id: 'predictions',
      name: 'Predictions Summary',
      description: 'Recent predictions and outcomes analysis',
      type: 'predictions',
      icon: Target
    },
    {
      id: 'models',
      name: 'Model Comparison',
      description: 'Compare accuracy across different models',
      type: 'models',
      icon: TrendingUp
    },
    {
      id: 'custom',
      name: 'Custom Report',
      description: 'Build a report with custom parameters',
      type: 'custom',
      icon: Users
    }
  ]

  useEffect(() => {
    // Mock reports data - replace with actual API call
    const mockReports: Report[] = [
      {
        id: '1',
        title: 'Q4 2024 Performance Analysis',
        type: 'performance',
        status: 'completed',
        createdAt: '2025-01-15T00:00:00Z',
        generatedBy: 'Admin User',
        description: 'Quarterly performance analysis of all ML models',
        size: '2.4 MB',
        format: 'pdf'
      },
      {
        id: '2',
        title: 'Weekly Predictions Summary',
        type: 'predictions',
        status: 'completed',
        createdAt: '2025-01-14T00:00:00Z',
        generatedBy: 'System Auto',
        description: 'Automatic weekly predictions summary report',
        size: '856 KB',
        format: 'excel'
      },
      {
        id: '3',
        title: 'Model Accuracy Comparison',
        type: 'models',
        status: 'generating',
        createdAt: '2025-01-15T00:00:00Z',
        generatedBy: 'Data Scientist',
        description: 'Comparing accuracy metrics across all active models',
        size: 'Generating...',
        format: 'pdf'
      },
      {
        id: '4',
        title: 'FinTech Sector Analysis',
        type: 'custom',
        status: 'completed',
        createdAt: '2025-01-12T00:00:00Z',
        generatedBy: 'Analyst',
        description: 'Custom analysis focused on FinTech startup predictions',
        size: '1.8 MB',
        format: 'csv'
      },
      {
        id: '5',
        title: 'December Model Training Report',
        type: 'models',
        status: 'failed',
        createdAt: '2025-01-10T00:00:00Z',
        generatedBy: 'ML Engineer',
        description: 'Training metrics and model optimization results',
        size: 'Failed',
        format: 'pdf'
      }
    ]

    setTimeout(() => {
      setReports(mockReports)
      setLoading(false)
    }, 1000)
  }, [])

  const handleDownload = (id: string) => {
    // TODO: Implement actual download
    console.log('Download report:', id)
  }

  const handleView = (id: string) => {
    // TODO: Implement report viewer
    console.log('View report:', id)
  }

  const handleShare = (id: string) => {
    // TODO: Implement share functionality
    console.log('Share report:', id)
  }

  const handleGenerateReport = (templateId: string) => {
    // TODO: Implement report generation
    console.log('Generate report from template:', templateId)
    setShowNewReport(false)
  }

  const filteredReports = reports.filter(report => {
    const matchesSearch = report.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         report.description.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || report.status === statusFilter
    const matchesType = typeFilter === 'all' || report.type === typeFilter
    
    return matchesSearch && matchesStatus && matchesType
  })

  const completedReports = reports.filter(r => r.status === 'completed').length
  const generatingReports = reports.filter(r => r.status === 'generating').length
  const failedReports = reports.filter(r => r.status === 'failed').length

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="flex items-center space-x-2">
          <Clock className="h-6 w-6 animate-spin text-blue-600" />
          <span className="text-lg text-gray-600">Loading reports...</span>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Reports</h1>
          <p className="text-sm text-gray-600 mt-1">
            Generate and manage performance reports and analytics
          </p>
        </div>
        <button
          onClick={() => setShowNewReport(true)}
          className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700"
        >
          <Plus className="h-4 w-4 mr-2" />
          New Report
        </button>
      </div>

      {/* Statistics Overview */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-green-100 rounded-lg flex items-center justify-center">
              <CheckCircle className="h-5 w-5 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Completed Reports</p>
              <p className="text-2xl font-semibold text-gray-900">{completedReports}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-yellow-100 rounded-lg flex items-center justify-center">
              <Clock className="h-5 w-5 text-yellow-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Generating</p>
              <p className="text-2xl font-semibold text-gray-900">{generatingReports}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-red-100 rounded-lg flex items-center justify-center">
              <AlertCircle className="h-5 w-5 text-red-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Failed</p>
              <p className="text-2xl font-semibold text-gray-900">{failedReports}</p>
            </div>
          </div>
        </div>
      </div>

      {/* New Report Modal */}
      {showNewReport && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex min-h-screen items-center justify-center p-4">
            <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setShowNewReport(false)} />
            <div className="relative bg-white rounded-lg shadow-xl max-w-2xl w-full p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-lg font-semibold text-gray-900">Generate New Report</h2>
                <button
                  onClick={() => setShowNewReport(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  ×
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {reportTemplates.map((template) => {
                  const IconComponent = template.icon
                  return (
                    <button
                      key={template.id}
                      onClick={() => handleGenerateReport(template.id)}
                      className="text-left p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors"
                    >
                      <div className="flex items-center mb-3">
                        <div className="h-8 w-8 bg-blue-100 rounded-lg flex items-center justify-center mr-3">
                          <IconComponent className="h-4 w-4 text-blue-600" />
                        </div>
                        <h3 className="font-medium text-gray-900">{template.name}</h3>
                      </div>
                      <p className="text-sm text-gray-600">{template.description}</p>
                    </button>
                  )
                })}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-3 sm:space-y-0">
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search reports..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-md text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
            >
              <option value="all">All Status</option>
              <option value="completed">Completed</option>
              <option value="generating">Generating</option>
              <option value="failed">Failed</option>
            </select>
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
            >
              <option value="all">All Types</option>
              <option value="performance">Performance</option>
              <option value="predictions">Predictions</option>
              <option value="models">Models</option>
              <option value="custom">Custom</option>
            </select>
          </div>
        </div>
      </div>

      {/* Reports Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredReports.map((report) => (
          <ReportCard
            key={report.id}
            report={report}
            onDownload={handleDownload}
            onView={handleView}
            onShare={handleShare}
          />
        ))}
      </div>

      {filteredReports.length === 0 && (
        <div className="text-center py-12">
          <FileText className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">No reports found</h3>
          <p className="mt-1 text-sm text-gray-500">
            {searchTerm || statusFilter !== 'all' || typeFilter !== 'all'
              ? 'Try adjusting your search or filters.'
              : 'Get started by generating your first report.'}
          </p>
          <div className="mt-6">
            <button
              onClick={() => setShowNewReport(true)}
              className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700"
            >
              <Plus className="h-4 w-4 mr-2" />
              Generate Report
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
