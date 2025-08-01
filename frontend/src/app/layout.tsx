import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'
import { Toaster } from 'react-hot-toast'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Decision - AI-Powered Investment Intelligence',
  description: 'Transform investment decisions through advanced AI and quantitative analytics. From thesis research to production-ready investment intelligence platform.',
  keywords: ['AI', 'Machine Learning', 'Investment', 'Venture Capital', 'Decision Intelligence', 'Quantitative Finance'],
  authors: [{ name: 'Ramin Fazli' }],
  creator: 'Ramin Fazli',
  metadataBase: new URL('https://decision.is'),
  openGraph: {
    title: 'Decision - AI-Powered Investment Intelligence',
    description: 'Transform investment decisions through advanced AI and quantitative analytics.',
    url: 'https://decision.is',
    siteName: 'Decision Platform',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Decision Platform - AI-Powered Investment Intelligence',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Decision - AI-Powered Investment Intelligence',
    description: 'Transform investment decisions through advanced AI and quantitative analytics.',
    images: ['/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'your-google-verification-code',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className="h-full">
      <body className={`${inter.className} h-full bg-gray-50 antialiased`}>
        <Providers>
          {children}
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#363636',
                color: '#fff',
              },
              success: {
                iconTheme: {
                  primary: '#22c55e',
                  secondary: '#fff',
                },
              },
              error: {
                iconTheme: {
                  primary: '#ef4444',
                  secondary: '#fff',
                },
              },
            }}
          />
        </Providers>
      </body>
    </html>
  )
}
