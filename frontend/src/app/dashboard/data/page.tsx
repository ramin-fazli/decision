"use client"

import { useState, useRef } from 'react'
import { 
  Upload,
  Database,
  FileText,
  Download,
  Trash2,
  Eye,
  AlertCircle,
  CheckCircle,
  Clock,
  BarChart3,
  Search,
  Filter,
  Plus,
  Link as LinkIcon
} from 'lucide-react'

interface DataSource {
  id: string
  name: string
  type: 'csv' | 'excel' | 'json' | 'api' | 'database'
  status: 'processing' | 'ready' | 'error'
  size: string
  records: number
  uploadedAt: string
  lastModified: string
}

interface DataSourceCardProps {
  source: DataSource
  onDelete: (id: string) => void
  onPreview: (id: string) => void
}

function DataSourceCard({ source, onDelete, onPreview }: DataSourceCardProps) {
  const statusColors = {
    processing: 'bg-yellow-100 text-yellow-800',
    ready: 'bg-green-100 text-green-800',
    error: 'bg-red-100 text-red-800'
  }

  const statusIcons = {
    processing: Clock,
    ready: CheckCircle,
    error: AlertCircle
  }

  const typeIcons = {
    csv: FileText,
    excel: FileText,
    json: FileText,
    api: LinkIcon,
    database: Database
  }

  const StatusIcon = statusIcons[source.status]
  const TypeIcon = typeIcons[source.type]

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-start justify-between">
        <div className="flex items-start space-x-3">
          <div className="h-10 w-10 bg-blue-50 rounded-lg flex items-center justify-center">
            <TypeIcon className="h-5 w-5 text-blue-600" />
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-900">{source.name}</h3>
            <p className="text-xs text-gray-500 mt-1">{source.type.toUpperCase()}</p>
          </div>
        </div>
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusColors[source.status]}`}>
          <StatusIcon className={`h-3 w-3 mr-1 ${source.status === 'processing' ? 'animate-spin' : ''}`} />
          {source.status.charAt(0).toUpperCase() + source.status.slice(1)}
        </span>
      </div>

      <div className="mt-4 space-y-2">
        <div className="flex justify-between text-xs">
          <span className="text-gray-500">Size</span>
          <span className="font-medium">{source.size}</span>
        </div>
        <div className="flex justify-between text-xs">
          <span className="text-gray-500">Records</span>
          <span className="font-medium">{source.records.toLocaleString()}</span>
        </div>
        <div className="flex justify-between text-xs">
          <span className="text-gray-500">Uploaded</span>
          <span className="font-medium">{new Date(source.uploadedAt).toLocaleDateString()}</span>
        </div>
      </div>

      <div className="mt-6 flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <button
            onClick={() => onPreview(source.id)}
            className="inline-flex items-center px-2 py-1 text-xs font-medium text-blue-700 bg-blue-100 rounded hover:bg-blue-200"
          >
            <Eye className="h-3 w-3 mr-1" />
            Preview
          </button>
          <button className="inline-flex items-center px-2 py-1 text-xs font-medium text-green-700 bg-green-100 rounded hover:bg-green-200">
            <Download className="h-3 w-3 mr-1" />
            Download
          </button>
        </div>
        <button
          onClick={() => onDelete(source.id)}
          className="text-gray-400 hover:text-red-600"
        >
          <Trash2 className="h-4 w-4" />
        </button>
      </div>
    </div>
  )
}

export default function DataPage() {
  const [dataSources, setDataSources] = useState<DataSource[]>([
    {
      id: '1',
      name: 'Crunchbase Startups 2024',
      type: 'csv',
      status: 'ready',
      size: '2.4 MB',
      records: 15420,
      uploadedAt: '2025-01-10T00:00:00Z',
      lastModified: '2025-01-10T00:00:00Z'
    },
    {
      id: '2',
      name: 'Venture Capital Deals',
      type: 'excel',
      status: 'ready',
      size: '1.8 MB',
      records: 8750,
      uploadedAt: '2025-01-08T00:00:00Z',
      lastModified: '2025-01-08T00:00:00Z'
    },
    {
      id: '3',
      name: 'Company Financials API',
      type: 'api',
      status: 'processing',
      size: '5.2 MB',
      records: 23100,
      uploadedAt: '2025-01-15T00:00:00Z',
      lastModified: '2025-01-15T00:00:00Z'
    }
  ])

  const [showUpload, setShowUpload] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [dragActive, setDragActive] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true)
    } else if (e.type === "dragleave") {
      setDragActive(false)
    }
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setDragActive(false)
    
    const files = e.dataTransfer.files
    if (files && files[0]) {
      handleFiles(files)
    }
  }

  const handleFiles = (files: FileList) => {
    Array.from(files).forEach(file => {
      const newSource: DataSource = {
        id: Date.now().toString(),
        name: file.name,
        type: file.name.endsWith('.csv') ? 'csv' : 
              file.name.endsWith('.xlsx') || file.name.endsWith('.xls') ? 'excel' : 'json',
        status: 'processing',
        size: `${(file.size / 1024 / 1024).toFixed(1)} MB`,
        records: Math.floor(Math.random() * 20000) + 1000,
        uploadedAt: new Date().toISOString(),
        lastModified: new Date().toISOString()
      }

      setDataSources(prev => [newSource, ...prev])

      // Simulate processing
      setTimeout(() => {
        setDataSources(prev => prev.map(source => 
          source.id === newSource.id 
            ? { ...source, status: 'ready' }
            : source
        ))
      }, 3000)
    })
  }

  const handleFileInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files
    if (files) {
      handleFiles(files)
    }
  }

  const handleDelete = (id: string) => {
    setDataSources(prev => prev.filter(source => source.id !== id))
  }

  const handlePreview = (id: string) => {
    // TODO: Implement preview modal
    console.log('Preview data source:', id)
  }

  const filteredSources = dataSources.filter(source =>
    source.name.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const totalRecords = dataSources.reduce((acc, source) => acc + source.records, 0)
  const readySources = dataSources.filter(s => s.status === 'ready').length
  const processingSources = dataSources.filter(s => s.status === 'processing').length

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Data Management</h1>
          <p className="text-sm text-gray-600 mt-1">
            Upload, connect, and manage your data sources for ML training
          </p>
        </div>
        <button
          onClick={() => setShowUpload(true)}
          className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700"
        >
          <Plus className="h-4 w-4 mr-2" />
          Add Data Source
        </button>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-blue-100 rounded-lg flex items-center justify-center">
              <Database className="h-5 w-5 text-blue-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Data Sources</p>
              <p className="text-2xl font-semibold text-gray-900">{dataSources.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-green-100 rounded-lg flex items-center justify-center">
              <CheckCircle className="h-5 w-5 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Ready Sources</p>
              <p className="text-2xl font-semibold text-gray-900">{readySources}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center">
            <div className="h-10 w-10 bg-purple-100 rounded-lg flex items-center justify-center">
              <BarChart3 className="h-5 w-5 text-purple-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Records</p>
              <p className="text-2xl font-semibold text-gray-900">{totalRecords.toLocaleString()}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Upload Modal */}
      {showUpload && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex min-h-screen items-center justify-center p-4">
            <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setShowUpload(false)} />
            <div className="relative bg-white rounded-lg shadow-xl max-w-md w-full p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-lg font-semibold text-gray-900">Add Data Source</h2>
                <button
                  onClick={() => setShowUpload(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  ×
                </button>
              </div>

              <div className="space-y-4">
                {/* File Upload */}
                <div
                  className={`border-2 border-dashed rounded-lg p-6 text-center ${
                    dragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300'
                  }`}
                  onDragEnter={handleDrag}
                  onDragLeave={handleDrag}
                  onDragOver={handleDrag}
                  onDrop={handleDrop}
                >
                  <Upload className="mx-auto h-12 w-12 text-gray-400" />
                  <div className="mt-4">
                    <p className="text-sm text-gray-600">
                      Drop files here or{' '}
                      <button
                        onClick={() => fileInputRef.current?.click()}
                        className="text-blue-600 hover:text-blue-700 font-medium"
                      >
                        browse
                      </button>
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      Supports CSV, Excel, JSON files up to 50MB
                    </p>
                  </div>
                  <input
                    ref={fileInputRef}
                    type="file"
                    className="hidden"
                    onChange={handleFileInput}
                    accept=".csv,.xlsx,.xls,.json"
                    multiple
                  />
                </div>

                {/* API Connection */}
                <div className="border border-gray-200 rounded-lg p-4">
                  <div className="flex items-center mb-3">
                    <LinkIcon className="h-5 w-5 text-gray-400 mr-2" />
                    <span className="text-sm font-medium text-gray-900">Connect API</span>
                  </div>
                  <input
                    type="url"
                    placeholder="Enter API endpoint URL"
                    className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                  />
                  <button className="mt-2 w-full inline-flex items-center justify-center px-3 py-2 text-sm font-medium text-blue-700 bg-blue-100 rounded-md hover:bg-blue-200">
                    Test Connection
                  </button>
                </div>

                {/* Database Connection */}
                <div className="border border-gray-200 rounded-lg p-4">
                  <div className="flex items-center mb-3">
                    <Database className="h-5 w-5 text-gray-400 mr-2" />
                    <span className="text-sm font-medium text-gray-900">Database Connection</span>
                  </div>
                  <div className="space-y-2">
                    <input
                      type="text"
                      placeholder="Connection string"
                      className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                    />
                    <input
                      type="text"
                      placeholder="Table name"
                      className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                    />
                  </div>
                  <button className="mt-2 w-full inline-flex items-center justify-center px-3 py-2 text-sm font-medium text-green-700 bg-green-100 rounded-md hover:bg-green-200">
                    Connect Database
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Search and Filter */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search data sources..."
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
        </div>
      </div>

      {/* Data Sources Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredSources.map((source) => (
          <DataSourceCard
            key={source.id}
            source={source}
            onDelete={handleDelete}
            onPreview={handlePreview}
          />
        ))}
      </div>

      {filteredSources.length === 0 && (
        <div className="text-center py-12">
          <Database className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">No data sources</h3>
          <p className="mt-1 text-sm text-gray-500">
            Get started by uploading your first dataset.
          </p>
          <div className="mt-6">
            <button
              onClick={() => setShowUpload(true)}
              className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700"
            >
              <Plus className="h-4 w-4 mr-2" />
              Add Data Source
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
