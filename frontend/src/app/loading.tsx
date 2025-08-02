import { Brain } from 'lucide-react'

export default function Loading() {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center items-center">
      <div className="text-center">
        <div className="flex justify-center mb-6">
          <Brain className="h-16 w-16 text-blue-600 animate-pulse" />
        </div>
        <h2 className="text-2xl font-semibold text-gray-700 mb-4">Loading...</h2>
        <div className="w-64 h-2 bg-gray-200 rounded-full overflow-hidden">
          <div className="w-full h-full bg-blue-600 rounded-full animate-pulse"></div>
        </div>
      </div>
    </div>
  )
}
