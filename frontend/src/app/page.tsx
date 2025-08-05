import Link from 'next/link'
import { ArrowRight, BarChart3, Brain, Database, Shield, Zap, Globe, Users, TrendingUp, Check, Star, GitBranch, Award, Target, Lightbulb, Activity, Cpu, Code, Layers } from 'lucide-react'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900">
      {/* Header */}
      <header className="relative z-50">
        <nav className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex h-16 items-center justify-between">
            <div className="flex items-center">
              <Link href="/" className="flex items-center space-x-2">
                <div className="relative">
                  <Brain className="h-8 w-8 text-blue-400" />
                </div>
                <span className="text-xl font-bold text-white">Decision</span>
              </Link>
            </div>
            <div className="hidden md:block">
              <div className="ml-10 flex items-baseline space-x-4">
                <Link href="#technology" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors">
                  Platform
                </Link>
                <Link href="#research" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors">
                  Architecture
                </Link>
                <Link href="#api" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors">
                  API
                </Link>
                <Link 
                  href="https://github.com/ramin-fazli/decision"
                  className="flex items-center text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  GitHub
                </Link>
                <Link href="/dashboard" className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-all duration-200 shadow-lg">
                  Live Preview
                </Link>
              </div>
            </div>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <main>
        <div className="relative px-4 sm:px-6 lg:px-8">
          {/* Background Elements */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl"></div>
            <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl"></div>
          </div>
          
          <div className="relative mx-auto max-w-5xl pt-20 pb-24 text-center">
            {/* Platform Badge */}
            <div className="mb-8 inline-flex items-center px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full text-sm text-blue-200">
              <Target className="h-4 w-4 mr-2" />
              AI-Powered Decision Intelligence for Investment Professionals
            </div>
            
            <h1 className="text-5xl md:text-7xl font-bold tracking-tight text-white mb-6">
              <span className="bg-gradient-to-r from-white via-blue-100 to-blue-200 bg-clip-text text-transparent">
                Investment
              </span>
              <br />
              <span className="text-blue-400">Decision Engine</span>
            </h1>
            
            <p className="mt-6 text-xl leading-8 text-gray-300 max-w-3xl mx-auto">
              Modular AI platform for predictive analytics across multiple asset classes. 
              API-first architecture with <span className="text-blue-400 font-semibold">data-source agnostic</span> ingestion, 
              advanced ML models, and real-time decision intelligence for VC, private equity, and public markets.
            </p>
            
            {/* Technical Highlights */}
            <div className="mt-8 flex flex-wrap justify-center gap-4 text-sm text-gray-400">
              <div className="flex items-center bg-white/5 px-3 py-1 rounded-full">
                <Activity className="h-3 w-3 mr-1 text-green-400" />
                API-First Architecture
              </div>
              <div className="flex items-center bg-white/5 px-3 py-1 rounded-full">
                <Cpu className="h-3 w-3 mr-1 text-blue-400" />
                SHAP/LIME Explainability
              </div>
              <div className="flex items-center bg-white/5 px-3 py-1 rounded-full">
                <Code className="h-3 w-3 mr-1 text-purple-400" />
                Multi-Asset Intelligence
              </div>
            </div>
            
            <div className="mt-12 flex flex-col sm:flex-row items-center justify-center gap-x-6 gap-y-4">
              <Link
                href="/dashboard"
                className="group relative overflow-hidden rounded-lg bg-gradient-to-r from-blue-600 to-purple-600 px-8 py-4 text-sm font-semibold text-white shadow-lg hover:from-blue-700 hover:to-purple-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 flex items-center transition-all duration-200"
              >
                <span className="relative z-10 flex items-center">
                  Explore Platform
                  <ArrowRight className="ml-2 h-4 w-4 group-hover:translate-x-1 transition-transform" />
                </span>
                <div className="absolute inset-0 bg-gradient-to-r from-blue-700 to-purple-700 opacity-0 group-hover:opacity-100 transition-opacity"></div>
              </Link>
              <Link
                href="https://calendly.com/raminfazli/freecall"
                target="_blank"
                className="text-sm font-semibold leading-6 text-white hover:text-blue-400 flex items-center transition-colors"
              >
                Request Enterprise Demo
                <span aria-hidden="true" className="ml-1 transition-transform hover:translate-x-1">→</span>
              </Link>
            </div>
          </div>
        </div>

        {/* Platform Architecture Section */}
        <div id="research" className="py-24 bg-gradient-to-b from-slate-900 to-gray-900">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <div className="inline-flex items-center px-4 py-2 bg-blue-600/20 rounded-full text-blue-300 text-sm mb-6">
                <GitBranch className="h-4 w-4 mr-2" />
                API-First Decision Intelligence Platform
              </div>
              <h2 className="text-4xl font-bold text-white mb-6">
                Modular AI Architecture for Investment Decisions
              </h2>
              <p className="text-lg text-gray-300 max-w-3xl mx-auto">
                Extensible platform supporting multiple asset classes with data-source agnostic ingestion, 
                advanced ML capabilities, and cloud-native deployment flexibility.
              </p>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              <div className="bg-white/5 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mb-4">
                  <Database className="h-6 w-6 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-2">Data Agnostic</h3>
                <p className="text-gray-400 text-sm">CSV, Excel, APIs, SQL/NoSQL databases with automated pipelines using Airflow/Prefect</p>
              </div>
              
              <div className="bg-white/5 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-purple-600 rounded-lg flex items-center justify-center mb-4">
                  <Cpu className="h-6 w-6 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-2">Modular ML Engine</h3>
                <p className="text-gray-400 text-sm">Cloud (Vertex AI, SageMaker, Azure ML) and local inference with state-of-the-art models</p>
              </div>
              
              <div className="bg-white/5 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-green-600 rounded-lg flex items-center justify-center mb-4">
                  <BarChart3 className="h-6 w-6 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-2">Model Explainability</h3>
                <p className="text-gray-400 text-sm">SHAP/LIME integration with comprehensive monitoring and performance tracking</p>
              </div>
              
              <div className="bg-white/5 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-orange-600 rounded-lg flex items-center justify-center mb-4">
                  <Layers className="h-6 w-6 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-2">Multi-Asset Support</h3>
                <p className="text-gray-400 text-sm">Extensible across VC, private equity, public markets with specialized feature pipelines</p>
              </div>
            </div>
            
            <div className="mt-16 text-center">
              <Link 
                href="#" 
                className="inline-flex items-center text-blue-400 hover:text-blue-300 transition-colors"
              >
                <Code className="h-4 w-4 mr-2" />
                Explore API Documentation
                <ArrowRight className="h-4 w-4 ml-2" />
              </Link>
            </div>
          </div>
        </div>
        {/* Technology Stack Section */}
        <div id="technology" className="py-24 bg-white">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl font-bold text-gray-900 mb-6">
                Decision Engine API
              </h2>
              <p className="text-lg text-gray-600 max-w-3xl mx-auto">
                Cloud-native ML infrastructure with flexible deployment options and enterprise-grade performance
              </p>
            </div>
            
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
              <div className="space-y-8">
                <div className="flex items-start space-x-4">
                  <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                    <Brain className="h-6 w-6 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="text-xl font-semibold text-gray-900 mb-2">Modular ML Engine</h3>
                    <p className="text-gray-600">
                      Support for cloud-based inference (Vertex AI, SageMaker, Azure ML) and local deployment. 
                      Advanced feature pipelines with automated model training and validation workflows.
                    </p>
                  </div>
                </div>
                
                <div className="flex items-start space-x-4">
                  <div className="flex-shrink-0 w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                    <Zap className="h-6 w-6 text-purple-600" />
                  </div>
                  <div>
                    <h3 className="text-xl font-semibold text-gray-900 mb-2">API-First Design</h3>
                    <p className="text-gray-600">
                      RESTful architecture with comprehensive OpenAPI documentation. 
                      Flexible integration with any system, data source, or visualization tool.
                    </p>
                  </div>
                </div>
                
                <div className="flex items-start space-x-4">
                  <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                    <Shield className="h-6 w-6 text-green-600" />
                  </div>
                  <div>
                    <h3 className="text-xl font-semibold text-gray-900 mb-2">Enterprise Ready</h3>
                    <p className="text-gray-600">
                      Production-grade security, monitoring, and compliance features. 
                      Docker containerization with Kubernetes orchestration and Terraform IaC.
                    </p>
                  </div>
                </div>
              </div>
              
              <div className="bg-gray-900 rounded-xl p-6 text-green-400 font-mono text-sm overflow-x-auto">
                <div className="mb-4 text-gray-400"># Decision Engine API</div>
                <div className="space-y-2">
                  <div><span className="text-blue-400">POST</span> /api/v1/decisions/predict</div>
                  <div className="text-gray-400">{`{`}</div>
                  <div className="ml-4">"asset_class": "venture_capital",</div>
                  <div className="ml-4">"model_type": "ensemble",</div>
                  <div className="ml-4">"features": {`{`}</div>
                  <div className="ml-8">"funding_stage": "Series A",</div>
                  <div className="ml-8">"market_size": 2000000000,</div>
                  <div className="ml-8">"team_experience": 8.5</div>
                  <div className="ml-4">{`}`}</div>
                  <div className="text-gray-400">{`}`}</div>
                  <div className="mt-4 text-yellow-400"># Explainable Response</div>
                  <div className="text-gray-400">{`{`}</div>
                  <div className="ml-4">"decision_score": 0.847,</div>
                  <div className="ml-4">"confidence": 0.92,</div>
                  <div className="ml-4">"shap_explanation": {`{...}`}</div>
                  <div className="text-gray-400">{`}`}</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* API Documentation Section */}
        <div id="api" className="py-24 bg-gray-50">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl font-bold text-gray-900 mb-6">
                Data Pipeline & Integration
              </h2>
              <p className="text-lg text-gray-600 max-w-3xl mx-auto">
                Data-source agnostic platform with automated pipelines and flexible connectors
              </p>
            </div>
            
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                <Database className="h-8 w-8 text-blue-600 mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Universal Data Ingestion</h3>
                <p className="text-gray-600 mb-4">CSV, Excel, REST APIs, SQL/NoSQL databases with automated validation</p>
                <div className="text-xs bg-gray-100 p-3 rounded font-mono">
                  POST /api/v1/data/ingest
                </div>
              </div>
              
              <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                <Layers className="h-8 w-8 text-purple-600 mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Pipeline Orchestration</h3>
                <p className="text-gray-600 mb-4">Airflow/Prefect connectors for automated feature engineering</p>
                <div className="text-xs bg-gray-100 p-3 rounded font-mono">
                  GET /api/v1/pipelines/status
                </div>
              </div>
              
              <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                <Code className="h-8 w-8 text-green-600 mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Model Management</h3>
                <p className="text-gray-600 mb-4">Deploy, monitor, and version ML models across environments</p>
                <div className="text-xs bg-gray-100 p-3 rounded font-mono">
                  GET /api/v1/models/performance
                </div>
              </div>
            </div>
            
            <div className="mt-12 text-center">
              <Link 
                href="#" 
                className="inline-flex items-center bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 py-3 rounded-lg hover:from-blue-700 hover:to-purple-700 transition-all duration-200"
              >
                <Code className="h-4 w-4 mr-2" />
                View API Documentation
                <ArrowRight className="h-4 w-4 ml-2" />
              </Link>
            </div>
          </div>
        </div>

        {/* Investment Intelligence Section */}
        <div className="py-24 bg-white">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl font-bold text-gray-900 mb-6">
                Multi-Asset Investment Intelligence
              </h2>
              <p className="text-lg text-gray-600 max-w-3xl mx-auto">
                Specialized ML models trained for different investment asset classes, 
                delivering actionable insights across your entire portfolio
              </p>
            </div>
            
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              <div className="group relative bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl p-8 border border-blue-100 hover:shadow-xl transition-all duration-300">
                <div className="absolute top-4 right-4">
                  <div className="w-3 h-3 bg-green-400 rounded-full animate-pulse"></div>
                </div>
                <Users className="h-12 w-12 text-blue-600 mb-6" />
                <h3 className="text-xl font-semibold text-gray-900 mb-4">Venture Capital Intelligence</h3>
                <p className="text-gray-600 mb-6">
                  Predictive analytics for startup success assessment. Analyze funding patterns, team dynamics, 
                  market opportunities, and exit potential with quantitative scoring models.
                </p>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center text-blue-600">
                    <Check className="h-4 w-4 mr-2" />
                    Multi-model ensemble scoring
                  </div>
                  <div className="flex items-center text-blue-600">
                    <Check className="h-4 w-4 mr-2" />
                    Feature importance analysis
                  </div>
                  <div className="flex items-center text-blue-600">
                    <Check className="h-4 w-4 mr-2" />
                    Risk-adjusted returns
                  </div>
                </div>
              </div>
              
              <div className="group relative bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl p-8 border border-purple-100 hover:shadow-xl transition-all duration-300">
                <div className="absolute top-4 right-4">
                  <div className="w-3 h-3 bg-orange-400 rounded-full"></div>
                </div>
                <Shield className="h-12 w-12 text-purple-600 mb-6" />
                <h3 className="text-xl font-semibold text-gray-900 mb-4">Private Equity Analytics</h3>
                <p className="text-gray-600 mb-6">
                  Advanced due diligence automation with risk assessment, performance forecasting, 
                  and value creation opportunity identification.
                </p>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center text-purple-600">
                    <Check className="h-4 w-4 mr-2" />
                    Financial model validation
                  </div>
                  <div className="flex items-center text-purple-600">
                    <Check className="h-4 w-4 mr-2" />
                    Market position analysis
                  </div>
                  <div className="flex items-center text-purple-600">
                    <Check className="h-4 w-4 mr-2" />
                    Exit scenario modeling
                  </div>
                </div>
              </div>
              
              <div className="group relative bg-gradient-to-br from-green-50 to-emerald-50 rounded-2xl p-8 border border-green-100 hover:shadow-xl transition-all duration-300">
                <div className="absolute top-4 right-4">
                  <div className="w-3 h-3 bg-blue-400 rounded-full animate-pulse"></div>
                </div>
                <TrendingUp className="h-12 w-12 text-green-600 mb-6" />
                <h3 className="text-xl font-semibold text-gray-900 mb-4">Public Markets Intelligence</h3>
                <p className="text-gray-600 mb-6">
                  Quantitative stock selection, sector rotation signals, and portfolio optimization 
                  using advanced statistical models and market microstructure analysis.
                </p>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center text-green-600">
                    <Check className="h-4 w-4 mr-2" />
                    Real-time market signals
                  </div>
                  <div className="flex items-center text-green-600">
                    <Check className="h-4 w-4 mr-2" />
                    Risk-adjusted returns
                  </div>
                  <div className="flex items-center text-green-600">
                    <Check className="h-4 w-4 mr-2" />
                    Portfolio optimization
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Performance & Deployment Section */}
        <div className="py-24 bg-gray-50">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl font-bold text-gray-900 mb-6">
                Enterprise-Grade Performance
              </h2>
              <p className="text-lg text-gray-600 max-w-3xl mx-auto">
                Scalable architecture with flexible deployment options and production monitoring
              </p>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              <div className="text-center">
                <div className="bg-white rounded-2xl p-8 shadow-sm border border-gray-200">
                  <div className="text-5xl font-bold text-blue-600 mb-2">API</div>
                  <div className="text-lg font-semibold text-gray-900 mb-2">First Design</div>
                  <div className="text-sm text-gray-600">Flexible integration with any system or visualization tool</div>
                </div>
              </div>
              
              <div className="text-center">
                <div className="bg-white rounded-2xl p-8 shadow-sm border border-gray-200">
                  <div className="text-5xl font-bold text-green-600 mb-2">Cloud</div>
                  <div className="text-lg font-semibold text-gray-900 mb-2">Agnostic</div>
                  <div className="text-sm text-gray-600">Deploy on AWS, GCP, Azure, or on-premises infrastructure</div>
                </div>
              </div>
              
              <div className="text-center">
                <div className="bg-white rounded-2xl p-8 shadow-sm border border-gray-200">
                  <div className="text-5xl font-bold text-purple-600 mb-2">Real</div>
                  <div className="text-lg font-semibold text-gray-900 mb-2">Time</div>
                  <div className="text-sm text-gray-600">Sub-second inference with horizontal auto-scaling</div>
                </div>
              </div>
              
              <div className="text-center">
                <div className="bg-white rounded-2xl p-8 shadow-sm border border-gray-200">
                  <div className="text-5xl font-bold text-orange-600 mb-2">MLOps</div>
                  <div className="text-lg font-semibold text-gray-900 mb-2">Ready</div>
                  <div className="text-sm text-gray-600">Model versioning, monitoring, and automated retraining</div>
                </div>
              </div>
            </div>
            
            <div className="mt-16">
              <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-2xl p-8 text-white">
                <div className="max-w-3xl mx-auto text-center">
                  <h3 className="text-2xl font-bold mb-4">Ready to Deploy Decision Intelligence?</h3>
                  <p className="text-lg mb-8 text-blue-100">
                    Experience the power of modular AI architecture designed for quantitative finance. 
                    From prototype to production in minutes, not months.
                  </p>
                  <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    <Link
                      href="/dashboard"
                      className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-blue-50 transition-colors"
                    >
                      Explore Platform
                    </Link>
                    <Link
                      href="https://calendly.com/raminfazli/freecall"
                      target="_blank"
                      className="border border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white/10 transition-colors"
                    >
                      Request Enterprise Access
                    </Link>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-slate-900">
        <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-8">
              <div className="flex items-center space-x-2">
                <Brain className="h-6 w-6 text-blue-400" />
                <span className="text-lg font-bold text-white">Decision</span>
              </div>
              <Link
                href="https://www.linkedin.com/company/decisionis/"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-blue-400 transition-colors"
              >
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                </svg>
              </Link>
            </div>
            <p className="text-sm text-gray-400">
              © 2025 Decision Platform. Transforming investment decisions through AI.
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}
