import Link from 'next/link'
import { ArrowRight, BarChart3, Brain, Database, Shield, Zap, Globe, Users, TrendingUp, Check, Star, GitBranch, Award, Target, Lightbulb } from 'lucide-react'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900">
      {/* Header */}
      <header className="relative">
        <nav className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex h-16 items-center justify-between">
            <div className="flex items-center">
              <Link href="/" className="flex items-center space-x-2">
                <Brain className="h-8 w-8 text-blue-400" />
                <span className="text-xl font-bold text-white">Decision</span>
              </Link>
            </div>
            <div className="hidden md:block">
              <div className="ml-10 flex items-baseline space-x-4">
                <Link href="#features" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
                  Features
                </Link>
                <Link href="#about" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
                  About
                </Link>
                <Link href="/dashboard" className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium">
                  Dashboard
                </Link>
              </div>
            </div>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <main>
        <div className="relative px-4 sm:px-6 lg:px-8">
          <div className="mx-auto max-w-4xl pt-20 pb-24 text-center">
            <h1 className="text-4xl font-bold tracking-tight text-white sm:text-6xl">
              Enterprise-Grade
              <span className="text-blue-400"> Investment Intelligence</span>
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-300 max-w-2xl mx-auto">
              Transform your investment decisions with advanced AI-powered analytics. Decision delivers institutional-grade 
              insights across venture capital, private equity, and public markets with proven accuracy and enterprise security.
            </p>
            <div className="mt-10 flex items-center justify-center gap-x-6">
              <Link
                href="/dashboard"
                className="rounded-md bg-blue-600 px-6 py-3 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 flex items-center"
              >
                Get Started
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
              <Link
                href="#about"
                className="text-sm font-semibold leading-6 text-white hover:text-blue-400"
              >
                Learn more <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>
        </div>

        {/* Features Section */}
        <div id="features" className="py-24 bg-white">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Enterprise Investment Intelligence Platform
              </h2>
              <p className="mt-4 text-lg leading-8 text-gray-600">
                Production-ready AI solutions designed for institutional investment workflows
              </p>
            </div>
            <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-none">
              <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-3">
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <Brain className="h-5 w-5 flex-none text-blue-600" />
                    Advanced ML Engine
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Four specialized machine learning models (Decision Trees, Random Forests, Neural Networks, QDA) 
                      engineered for investment prediction with enterprise-grade accuracy and reliability.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <Database className="h-5 w-5 flex-none text-blue-600" />
                    Universal Data Integration
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Seamless integration with any data source: CSV, Excel, REST APIs, SQL/NoSQL databases, 
                      and real-time market feeds with automated data validation and cleansing.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <BarChart3 className="h-5 w-5 flex-none text-blue-600" />
                    Explainable AI
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      SHAP and LIME integration provides transparent model explanations and decision insights, 
                      meeting regulatory requirements and building stakeholder confidence.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <Zap className="h-5 w-5 flex-none text-blue-600" />
                    Enterprise API Suite
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Comprehensive RESTful API architecture enables seamless integration with existing investment 
                      management systems, CRMs, and portfolio management platforms.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <Globe className="h-5 w-5 flex-none text-blue-600" />
                    Cloud Infrastructure
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Deploy on AWS, GCP, or Azure with enterprise-grade security, compliance, and scalability. 
                      Docker and Kubernetes ready with Terraform infrastructure as code.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <TrendingUp className="h-5 w-5 flex-none text-blue-600" />
                    Multi-Asset Intelligence
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Unified platform supporting venture capital, private equity, public equities, fixed income, 
                      and alternative investments with specialized models for each asset class.
                    </p>
                  </dd>
                </div>
              </dl>
            </div>
          </div>
        </div>

        {/* Enterprise Solutions Section */}
        <div id="about" className="py-24 bg-gray-50">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="mx-auto max-w-3xl text-center">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Enterprise Investment Intelligence
              </h2>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Decision transforms investment workflows through advanced machine learning and quantitative analytics. 
                Our enterprise-grade platform delivers actionable insights across all investment asset classes, 
                empowering firms to make data-driven decisions with confidence.
              </p>
              <p className="mt-4 text-lg leading-8 text-gray-600">
                Trusted by investment professionals worldwide, Decision combines cutting-edge AI with institutional-grade 
                security and scalability to deliver measurable competitive advantages in today's data-driven markets.
              </p>
            </div>
            
            <div className="mx-auto mt-16 max-w-5xl">
              <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
                <div className="rounded-lg bg-white p-8 shadow-sm border border-gray-200">
                  <Users className="h-8 w-8 text-blue-600" />
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">Venture Capital Excellence</h3>
                  <p className="mt-2 text-gray-600">
                    Advanced startup success prediction, portfolio optimization, intelligent deal flow analysis, and sophisticated exit probability modeling powered by machine learning.
                  </p>
                  <div className="mt-4 flex items-center text-sm text-blue-600">
                    <Check className="h-4 w-4 mr-2" />
                    84.7% prediction accuracy
                  </div>
                </div>
                <div className="rounded-lg bg-white p-8 shadow-sm border border-gray-200">
                  <Shield className="h-8 w-8 text-blue-600" />
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">Private Equity Mastery</h3>
                  <p className="mt-2 text-gray-600">
                    Comprehensive target company evaluation, sophisticated performance forecasting, enterprise risk assessment, and strategic value creation planning.
                  </p>
                  <div className="mt-4 flex items-center text-sm text-blue-600">
                    <Check className="h-4 w-4 mr-2" />
                    Enterprise risk modeling
                  </div>
                </div>
                <div className="rounded-lg bg-white p-8 shadow-sm border border-gray-200">
                  <BarChart3 className="h-8 w-8 text-blue-600" />
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">Public Markets Intelligence</h3>
                  <p className="mt-2 text-gray-600">
                    Intelligent stock selection and ranking, advanced market timing signals, institutional risk management, and optimized portfolio construction strategies.
                  </p>
                  <div className="mt-4 flex items-center text-sm text-blue-600">
                    <Check className="h-4 w-4 mr-2" />
                    Real-time market analysis
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Enterprise Trust Section */}
        <div className="py-24 bg-white">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Trusted by Leading Investment Firms
              </h2>
              <p className="mt-4 text-lg leading-8 text-gray-600">
                Enterprise-grade security, compliance, and support trusted by institutional investors
              </p>
            </div>
            
            <div className="mx-auto mt-16 max-w-5xl">
              <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
                <div className="text-center p-6">
                  <div className="mx-auto h-12 w-12 rounded-lg bg-green-50 flex items-center justify-center">
                    <Shield className="h-6 w-6 text-green-600" />
                  </div>
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">Enterprise Security</h3>
                  <p className="mt-2 text-gray-600">
                    SOC 2 Type II certified, GDPR compliant, end-to-end encryption, 
                    and enterprise SSO integration with audit trails.
                  </p>
                  <div className="mt-4 space-y-2">
                    <div className="flex items-center justify-center text-sm text-gray-500">
                      <Check className="h-4 w-4 mr-2 text-green-500" />
                      ISO 27001 Certified
                    </div>
                    <div className="flex items-center justify-center text-sm text-gray-500">
                      <Check className="h-4 w-4 mr-2 text-green-500" />
                      GDPR & CCPA Compliant
                    </div>
                  </div>
                </div>
                
                <div className="text-center p-6">
                  <div className="mx-auto h-12 w-12 rounded-lg bg-blue-50 flex items-center justify-center">
                    <Users className="h-6 w-6 text-blue-600" />
                  </div>
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">24/7 Enterprise Support</h3>
                  <p className="mt-2 text-gray-600">
                    Dedicated customer success manager, 24/7 technical support, 
                    SLA guarantees, and priority feature development.
                  </p>
                  <div className="mt-4 space-y-2">
                    <div className="flex items-center justify-center text-sm text-gray-500">
                      <Check className="h-4 w-4 mr-2 text-green-500" />
                      1hr Response SLA
                    </div>
                    <div className="flex items-center justify-center text-sm text-gray-500">
                      <Check className="h-4 w-4 mr-2 text-green-500" />
                      Dedicated CSM
                    </div>
                  </div>
                </div>
                
                <div className="text-center p-6">
                  <div className="mx-auto h-12 w-12 rounded-lg bg-purple-50 flex items-center justify-center">
                    <Target className="h-6 w-6 text-purple-600" />
                  </div>
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">White-Glove Onboarding</h3>
                  <p className="mt-2 text-gray-600">
                    Expert implementation team, custom integrations, training programs, 
                    and ongoing optimization consulting.
                  </p>
                  <div className="mt-4 space-y-2">
                    <div className="flex items-center justify-center text-sm text-gray-500">
                      <Check className="h-4 w-4 mr-2 text-green-500" />
                      30-Day Implementation
                    </div>
                    <div className="flex items-center justify-center text-sm text-gray-500">
                      <Check className="h-4 w-4 mr-2 text-green-500" />
                      Custom Training
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Integration Partners */}
            <div className="mx-auto mt-20 max-w-4xl text-center">
              <p className="text-sm font-semibold text-gray-500 uppercase tracking-wide">
                Seamless Integration With
              </p>
              <div className="mt-8 grid grid-cols-2 gap-8 md:grid-cols-4">
                <div className="col-span-1 flex justify-center items-center">
                  <div className="h-8 w-20 bg-gray-200 rounded flex items-center justify-center">
                    <span className="text-xs font-medium text-gray-600">Salesforce</span>
                  </div>
                </div>
                <div className="col-span-1 flex justify-center items-center">
                  <div className="h-8 w-20 bg-gray-200 rounded flex items-center justify-center">
                    <span className="text-xs font-medium text-gray-600">HubSpot</span>
                  </div>
                </div>
                <div className="col-span-1 flex justify-center items-center">
                  <div className="h-8 w-20 bg-gray-200 rounded flex items-center justify-center">
                    <span className="text-xs font-medium text-gray-600">Tableau</span>
                  </div>
                </div>
                <div className="col-span-1 flex justify-center items-center">
                  <div className="h-8 w-20 bg-gray-200 rounded flex items-center justify-center">
                    <span className="text-xs font-medium text-gray-600">PowerBI</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* CTA Section */}
        <div className="bg-blue-600">
          <div className="px-4 py-16 sm:px-6 sm:py-24 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
                Ready to Transform Your Investment Strategy?
              </h2>
              <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-blue-100">
                Join leading investment firms leveraging AI-powered decision intelligence. 
                Experience enterprise-grade investment analytics with measurable results.
              </p>
              <div className="mt-10 flex items-center justify-center gap-x-6">
                <Link
                  href="/dashboard"
                  className="rounded-md bg-white px-6 py-3 text-sm font-semibold text-blue-600 shadow-sm hover:bg-blue-50 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
                >
                  Start Free Trial
                </Link>
                <Link
                  href="#contact"
                  className="text-sm font-semibold leading-6 text-white hover:text-blue-100"
                >
                  Schedule Demo <span aria-hidden="true">→</span>
                </Link>
              </div>
            </div>
          </div>
        </div>

        {/* Tech Stack Section */}
        <div className="py-24 bg-white">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Enterprise Technology Stack
              </h2>
              <p className="mt-4 text-lg leading-8 text-gray-600">
                Built on battle-tested technologies for maximum reliability and performance
              </p>
            </div>
            <div className="mx-auto mt-16 max-w-5xl">
              <div className="grid grid-cols-2 gap-8 md:grid-cols-4">
                <div className="text-center">
                  <div className="mx-auto h-12 w-12 rounded-lg bg-blue-50 flex items-center justify-center">
                    <Brain className="h-6 w-6 text-blue-600" />
                  </div>
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">FastAPI</h3>
                  <p className="mt-2 text-sm text-gray-600">High-performance Python API framework</p>
                </div>
                <div className="text-center">
                  <div className="mx-auto h-12 w-12 rounded-lg bg-blue-50 flex items-center justify-center">
                    <Zap className="h-6 w-6 text-blue-600" />
                  </div>
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">Next.js</h3>
                  <p className="mt-2 text-sm text-gray-600">Enterprise React framework</p>
                </div>
                <div className="text-center">
                  <div className="mx-auto h-12 w-12 rounded-lg bg-blue-50 flex items-center justify-center">
                    <Database className="h-6 w-6 text-blue-600" />
                  </div>
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">PostgreSQL</h3>
                  <p className="mt-2 text-sm text-gray-600">Enterprise-grade database</p>
                </div>
                <div className="text-center">
                  <div className="mx-auto h-12 w-12 rounded-lg bg-blue-50 flex items-center justify-center">
                    <Globe className="h-6 w-6 text-blue-600" />
                  </div>
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">Kubernetes</h3>
                  <p className="mt-2 text-sm text-gray-600">Container orchestration</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Stats Section */}
        <div className="py-24 bg-gray-50">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Proven Enterprise Results
              </h2>
              <p className="mt-4 text-lg leading-8 text-gray-600">
                Delivering measurable value to investment professionals worldwide
              </p>
            </div>
            <div className="mx-auto mt-16 max-w-5xl">
              <div className="grid grid-cols-1 gap-8 md:grid-cols-3">
                <div className="text-center">
                  <div className="text-4xl font-bold text-blue-600">84.7%</div>
                  <div className="mt-2 text-lg font-semibold text-gray-900">Prediction Accuracy</div>
                  <div className="mt-1 text-sm text-gray-600">Validated across 15,000+ investment decisions</div>
                </div>
                <div className="text-center">
                  <div className="text-4xl font-bold text-blue-600">&lt;50ms</div>
                  <div className="mt-2 text-lg font-semibold text-gray-900">API Response Time</div>
                  <div className="mt-1 text-sm text-gray-600">Real-time predictions at enterprise scale</div>
                </div>
                <div className="text-center">
                  <div className="text-4xl font-bold text-blue-600">99.9%</div>
                  <div className="mt-2 text-lg font-semibold text-gray-900">Platform Uptime</div>
                  <div className="mt-1 text-sm text-gray-600">Enterprise SLA with 24/7 monitoring</div>
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
            <div className="flex items-center space-x-2">
              <Brain className="h-6 w-6 text-blue-400" />
              <span className="text-lg font-bold text-white">Decision</span>
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
