#!/bin/bash

# Biotech Lead Generator Installation Script
echo "🧬 Setting up Biotech Lead Generator for Ferreira CTO..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node --version | cut -d v -f 2)
REQUIRED_VERSION="18.0.0"

if [ "$(printf '%s
' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Node.js version $NODE_VERSION is too old. Please upgrade to Node.js 18+."
    exit 1
fi

echo "✅ Node.js version $NODE_VERSION detected"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create environment file
if [ ! -f .env.local ]; then
    echo "📝 Creating environment configuration..."
    cp .env.example .env.local
    echo "🔧 Please edit .env.local with your API keys and configuration"
else
    echo "✅ Environment file already exists"
fi

# Install global dependencies
echo "🌐 Installing global dependencies..."
npm install -g @supabase/cli

# Setup complete
echo "🎉 Installation complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env.local with your API keys"
echo "2. Set up your Supabase database: supabase db push"
echo "3. Start the development server: npm run dev"
echo ""
echo "For detailed setup instructions, see README.md"
echo ""
echo "Ferreira CTO - Technology Due Diligence"
