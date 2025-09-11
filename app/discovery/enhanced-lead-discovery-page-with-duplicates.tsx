// Enhanced Discovery Page with Duplicate Detection
'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import {
    Search,
    Users,
    Building,
    Save,
    Filter,
    Target,
    Brain,
    Eye,
    Mail,
    Globe,
    MapPin,
    Star,
    SlidersHorizontal,
    X,
    DollarSign,
    Briefcase,
    Crown,
    TrendingUp,
    Check,
    Plus,
    Trash2,
    Download,
    Calendar,
    Building2,
    UserCheck,
    FileDown,
    AlertTriangle,
    Database
} from 'lucide-react'
import { toast } from 'react-hot-toast'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'

// ... (keeping all the existing interfaces as they are)

const [searchParams, setSearchParams] = useState({
    industries: ['Biotechnology', 'Pharmaceuticals'],
    fundingStages: ['Series A', 'Series B', 'Series C'],
    locations: ['United States', 'United Kingdom'],
    employeeRanges: ['51,200', '201,500', '501,1000'],
    includeVCs: true,
    excludeExisting: false,  // NEW: Option to exclude existing data
    maxResults: 10
})

// Add state for existing data tracking
const [existingDataCount, setExistingDataCount] = useState(0)
const [isCheckingExisting, setIsCheckingExisting] = useState(false)

// Function to check existing data
const checkExistingData = async () => {
    setIsCheckingExisting(true)
    try {
        const response = await fetchWithDemo('/api/discovery/check-existing', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(searchParams)
        })

        if (response.ok) {
            const data = await response.json()
            setExistingDataCount(data.count)
            toast.success(`Found ${data.count} existing companies in your database`)
        }
    } catch (error) {
        console.error('Error checking existing data:', error)
        toast.error('Failed to check existing data')
    } finally {
        setIsCheckingExisting(false)
    }
}

// Update your search configuration section to include the new toggle:

{/* Settings */}
<div>
    <label className="block text-sm font-medium mb-2">Settings</label>
    <div className="space-y-3">
        <div>
            <label className="text-sm font-medium">Max Results:</label>
            <Input
                type="number"
                value={searchParams.maxResults}
                onChange={(e) => setSearchParams(prev => ({
                    ...prev,
                    maxResults: parseInt(e.target.value) || 10
                }))}
                min="5"
                max="20"
                className="w-24 mt-1"
            />
            <p className="text-xs text-gray-500 mt-1">Lower for faster results</p>
        </div>

        <div className="flex items-center space-x-2">
            <Checkbox
                checked={searchParams.includeVCs}
                onCheckedChange={(checked) =>
                    setSearchParams(prev => ({ ...prev, includeVCs: checked as boolean }))
                }
            />
            <span className="text-sm">Include VCs & Investors</span>
        </div>

        {/* NEW: Exclude existing data toggle */}
        <div className="flex items-center space-x-2">
            <Checkbox
                checked={searchParams.excludeExisting}
                onCheckedChange={(checked) =>
                    setSearchParams(prev => ({ ...prev, excludeExisting: checked as boolean }))
                }
            />
            <span className="text-sm">Exclude existing companies</span>
        </div>

        {/* NEW: Check existing data button */}
        <div className="pt-2">
            <Button
                variant="outline"
                size="sm"
                onClick={checkExistingData}
                disabled={isCheckingExisting}
                className="flex items-center space-x-2 w-full"
            >
                <Database className="w-4 h-4" />
                <span>{isCheckingExisting ? 'Checking...' : 'Check Existing Data'}</span>
            </Button>
            {existingDataCount > 0 && (
                <p className="text-xs text-gray-600 mt-1">
                    {existingDataCount} companies already in your database
                </p>
            )}
        </div>
    </div>
</div>
