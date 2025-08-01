import Link from 'next/link'
import { ArrowRight, BarChart3, Brain, Database, Shield, Zap, Globe, Users, TrendingUp } from 'lucide-react'

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
              AI-Powered
              <span className="text-blue-400"> Investment Intelligence</span>
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-300 max-w-2xl mx-auto">
              Transform investment decisions through advanced machine learning and quantitative analytics. 
              From academic research to production-ready decision intelligence platform.
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
                Powerful Features for Investment Intelligence
              </h2>
              <p className="mt-4 text-lg leading-8 text-gray-600">
                Built on proven research with production-grade architecture
              </p>
            </div>
            <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-none">
              <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-3">
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <Brain className="h-5 w-5 flex-none text-blue-600" />
                    Advanced ML Models
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Decision Trees, Random Forests, Neural Networks, and QDA models optimized for investment predictions.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <Database className="h-5 w-5 flex-none text-blue-600" />
                    Data Source Agnostic
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Connect any data source: CSV, Excel, APIs, SQL/NoSQL databases with seamless integration.
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
                      SHAP and LIME integration for transparent model explanations and decision insights.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <Zap className="h-5 w-5 flex-none text-blue-600" />
                    API-First Architecture
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      RESTful API design allows flexible integration with any system, tool, or visualization platform.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <Globe className="h-5 w-5 flex-none text-blue-600" />
                    Cloud-Agnostic
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Deploy on AWS, GCP, or Azure with Docker, Kubernetes, and Terraform support.
                    </p>
                  </dd>
                </div>
                <div className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <TrendingUp className="h-5 w-5 flex-none text-blue-600" />
                    Multi-Asset Classes
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">
                      Extensible across venture capital, private equity, and public market investments.
                    </p>
                  </dd>
                </div>
              </dl>
            </div>
          </div>
        </div>

        {/* About Section */}
        <div id="about" className="py-24 bg-gray-50">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="mx-auto max-w-3xl text-center">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                From Research to Reality
              </h2>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                My journey began with completing a master's thesis titled <em>"The Impact of AI-powered Decision-Making 
                on Venture Capital Investments"</em>. In that research, I implemented and evaluated four machine learning 
                models using Python and scikit-learn on Crunchbase data to predict startup success.
              </p>
              <p className="mt-4 text-lg leading-8 text-gray-600">
                Now, I've evolved that academic foundation into <strong>Decision</strong> - a robust, scalable SaaS 
                platform that brings cutting-edge AI to investment professionals across multiple asset classes.
              </p>
            </div>
            
            <div className="mx-auto mt-16 max-w-5xl">
              <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
                <div className="rounded-lg bg-white p-8 shadow-sm">
                  <Users className="h-8 w-8 text-blue-600" />
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">For Venture Capital</h3>
                  <p className="mt-2 text-gray-600">
                    Startup success prediction, portfolio optimization, deal flow analysis, and exit probability modeling.
                  </p>
                </div>
                <div className="rounded-lg bg-white p-8 shadow-sm">
                  <Shield className="h-8 w-8 text-blue-600" />
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">For Private Equity</h3>
                  <p className="mt-2 text-gray-600">
                    Target company evaluation, performance forecasting, risk assessment, and value creation planning.
                  </p>
                </div>
                <div className="rounded-lg bg-white p-8 shadow-sm">
                  <BarChart3 className="h-8 w-8 text-blue-600" />
                  <h3 className="mt-4 text-lg font-semibold text-gray-900">For Public Markets</h3>
                  <p className="mt-2 text-gray-600">
                    Stock selection and ranking, market timing signals, risk management, and portfolio construction.
                  </p>
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
                Ready to Transform Your Investment Decisions?
              </h2>
              <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-blue-100">
                Join the next generation of AI-powered investment intelligence. Start making data-driven decisions today.
              </p>
              <div className="mt-10 flex items-center justify-center gap-x-6">
                <Link
                  href="/dashboard"
                  className="rounded-md bg-white px-6 py-3 text-sm font-semibold text-blue-600 shadow-sm hover:bg-blue-50 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
                >
                  Get Started Now
                </Link>
                <Link
                  href="https://github.com/ramin-fazli/decision"
                  className="text-sm font-semibold leading-6 text-white hover:text-blue-100"
                >
                  View on GitHub <span aria-hidden="true">→</span>
                </Link>
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
