/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  
  // Essential image configuration only
  images: {
    domains: ['images.crunchbase.com', 'logo.clearbit.com'],
  },

  // Safe environment variables
  env: {
    COMPANY_NAME: process.env.COMPANY_NAME || 'Ferreira CTO',
    COMPANY_EMAIL: process.env.COMPANY_EMAIL || 'peter@ferreiracto.com',
  },

  // Disable problematic features during debugging
  eslint: {
    ignoreDuringBuilds: true,
  },

  // Simplified webpack config to avoid path issues
  webpack: (config, { dev, isServer }) => {
    // Only add watch options if we're in development and not server-side
    if (dev && !isServer) {
      config.watchOptions = {
        ...config.watchOptions,
        ignored: [
          '**/node_modules/**',
          '**/.git/**',
          '**/.next/**',
          '**/.*', // Ignore all dot files
        ],
      }
    }
    return config
  },

  // Experimental features that might help
  experimental: {
    // Disable features that might cause path issues
    serverComponentsExternalPackages: [],
  },
}

module.exports = nextConfig
