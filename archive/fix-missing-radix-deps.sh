#!/bin/bash

echo "🔍 Scanning for missing Radix UI dependencies..."
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in a Next.js project
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ No package.json found. Make sure you're in the root of your Next.js project.${NC}"
    exit 1
fi

# Check if components/ui directory exists
if [ ! -d "components/ui" ]; then
    echo -e "${RED}❌ No components/ui directory found.${NC}"
    exit 1
fi

echo "📦 Checking current Radix UI packages..."
current_radix_packages=$(grep -o '"@radix-ui/[^"]*"' package.json | sed 's/"//g' | sort)
echo "Current packages:"
echo "$current_radix_packages"
echo ""

echo "🔎 Scanning UI components for Radix imports..."
# Find all TypeScript/TSX files in components/ui
ui_files=$(find components/ui -name "*.tsx" -o -name "*.ts" 2>/dev/null)

if [ -z "$ui_files" ]; then
    echo -e "${YELLOW}⚠️  No UI component files found.${NC}"
    exit 0
fi

# Extract Radix UI imports from all UI files
required_packages=()
missing_packages=()

for file in $ui_files; do
    if [ -f "$file" ]; then
        # Extract @radix-ui imports
        radix_imports=$(grep -o '@radix-ui/[a-zA-Z0-9-]*' "$file" 2>/dev/null | sort -u)
        
        if [ ! -z "$radix_imports" ]; then
            echo "📄 $file:"
            for import in $radix_imports; do
                echo "   → $import"
                required_packages+=("$import")
                
                # Check if package is installed
                if ! grep -q "\"$import\"" package.json; then
                    missing_packages+=("$import")
                    echo -e "   ${RED}❌ MISSING${NC}"
                else
                    echo -e "   ${GREEN}✅ INSTALLED${NC}"
                fi
            done
            echo ""
        fi
    fi
done

# Remove duplicates from required_packages
required_packages=($(printf "%s\n" "${required_packages[@]}" | sort -u))

echo "📋 Summary:"
echo "Required packages: ${#required_packages[@]}"
echo "Missing packages: ${#missing_packages[@]}"
echo ""

if [ ${#missing_packages[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All required Radix UI packages are installed!${NC}"
    exit 0
fi

echo -e "${YELLOW}📦 Missing packages to install:${NC}"
for package in "${missing_packages[@]}"; do
    echo "   • $package"
done
echo ""

# Ask for confirmation
read -p "Do you want to install the missing packages? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Installing missing Radix UI packages..."
    
    # Convert array to string for npm install
    packages_to_install=$(printf "%s " "${missing_packages[@]}")
    
    # Install packages
    echo "Running: npm install $packages_to_install"
    if npm install $packages_to_install; then
        echo -e "${GREEN}✅ Successfully installed missing packages!${NC}"
        echo ""
        
        # Verify installation
        echo "🔍 Verifying installation..."
        all_installed=true
        for package in "${missing_packages[@]}"; do
            if grep -q "\"$package\"" package.json; then
                echo -e "   ${GREEN}✅ $package${NC}"
            else
                echo -e "   ${RED}❌ $package${NC}"
                all_installed=false
            fi
        done
        
        if [ "$all_installed" = true ]; then
            echo ""
            echo -e "${GREEN}🎉 All packages successfully installed!${NC}"
            echo "You can now run: npm run build"
        else
            echo ""
            echo -e "${YELLOW}⚠️  Some packages may not have installed correctly. Check the output above.${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to install packages. Check the error messages above.${NC}"
        exit 1
    fi
else
    echo "Installation cancelled."
    echo ""
    echo "To install manually, run:"
    echo "npm install $packages_to_install"
fi

echo ""
echo "🔧 Additional steps:"
echo "1. Restart your development server: npm run dev"
echo "2. Clear Next.js cache if needed: rm -rf .next"
echo "3. Try building again: npm run build"
