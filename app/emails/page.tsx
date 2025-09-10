'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { 
  Mail, 
  Plus,
  MoreHorizontal, 
  Eye,
  Edit,
  Trash,
  Play,
  Pause,
  Copy,
  BarChart3,
  Clock,
  CheckCircle,
  XCircle,
  Users,
  TrendingUp,
  Send,
  Calendar,
  Filter,
  Search,
  RefreshCw
} from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'
import { toast } from 'react-hot-toast'
import { CampaignCreationDialog } from '@/components/email/campaign-creation-dialog'

interface EmailCampaign {
  id: string
  name: string
  subject: string
  status: 'draft' | 'scheduled' | 'sending' | 'sent' | 'paused' | 'completed'
  scheduled_at?: string
  sent_at?: string
  recipient_count: number
  sent_count: number
  delivered_count: number
  opened_count: number
  clicked_count: number
  replied_count: number
  created_at: string
  template_name?: string
}

const DEMO_CAMPAIGNS: EmailCampaign[] = [
  {
    id: 'demo-1',
    name: 'Biotech CTO Outreach - Q4 2024',
    subject: 'Technology Due Diligence for {{company_name}}',
    status: 'completed',
    sent_at: '2024-09-01T10:00:00Z',
    recipient_count: 150,
    sent_count: 148,
    delivered_count: 145,
    opened_count: 89,
    clicked_count: 23,
    replied_count: 12,
    created_at: '2024-08-28T09:00:00Z',
    template_name: 'Biotech Introduction'
  },
  {
    id: 'demo-2',
    name: 'VC Partnership Series A-C',
    subject: 'Technology Due Diligence Partnership - {{vc_firm_name}}',
    status: 'sending',
    scheduled_at: '2024-09-08T14:00:00Z',
    recipient_count: 45,
    sent_count: 32,
    delivered_count: 31,
    opened_count: 18,
    clicked_count: 7,
    replied_count: 3,
    created_at: '2024-09-05T11:30:00Z',
    template_name: 'VC Partnership'
  },
  {
    id: 'demo-3',
    name: 'Follow-up Series B Companies',
    subject: 'Following up on {{company_name}} technology discussion',
    status: 'scheduled',
    scheduled_at: '2024-09-10T09:00:00Z',
    recipient_count: 23,
    sent_count: 0,
    delivered_count: 0,
    opened_count: 0,
    clicked_count: 0,
    replied_count: 0,
    created_at: '2024-09-07T16:20:00Z',
    template_name: 'Follow-up Meeting'
  },
  {
    id: 'demo-4',
    name: 'Neurotechnology Specialists',
    subject: 'Technology Due Diligence for {{company_name}}',
    status: 'draft',
    recipient_count: 67,
    sent_count: 0,
    delivered_count: 0,
    opened_count: 0,
    clicked_count: 0,
    replied_count: 0,
    created_at: '2024-09-06T13:45:00Z',
    template_name: 'Biotech Introduction'
  }
]

export default function EmailCampaignsPage() {
  const { isDemoMode } = useDemoMode()
  const { fetchWithDemo } = useDemoMode()
  const [campaigns, setCampaigns] = useState<EmailCampaign[]>([])
  const [selectedCampaign, setSelectedCampaign] = useState<EmailCampaign | null>(null)
  const [showCampaignDialog, setShowCampaignDialog] = useState(false)
  const [showCreateDialog, setShowCreateDialog] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')
  const [loading, setLoading] = useState(true)
  const [refreshing, setRefreshing] = useState(false)

  useEffect(() => {
    loadCampaigns()
  }, [isDemoMode])

  const loadCampaigns = async () => {
    setLoading(true)
    try {
      if (isDemoMode) {
        await new Promise(resolve => setTimeout(resolve, 800))
        setCampaigns(DEMO_CAMPAIGNS)
        toast.success(`Loaded ${DEMO_CAMPAIGNS.length} demo campaigns`)
      } else {
        const response = await fetchWithDemo('/api/campaigns')
        if (response.ok) {
          const data = await response.json()
          setCampaigns(data.campaigns || [])
          toast.success(`Loaded ${data.campaigns?.length || 0} campaigns`)
        } else {
          throw new Error('Failed to fetch campaigns')
        }
      }
    } catch (error) {
      console.error('Error loading campaigns:', error)
      toast.error('Failed to load campaigns')
      setCampaigns([])
    } finally {
      setLoading(false)
    }
  }

  const handleRefresh = async () => {
    setRefreshing(true)
    await loadCampaigns()
    setRefreshing(false)
  }

  const filteredCampaigns = campaigns.filter(campaign => {
    const matchesSearch = campaign.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         campaign.subject.toLowerCase().includes(searchTerm.toLowerCase())
    
    const matchesStatus = filterStatus === 'all' || campaign.status === filterStatus
    
    return matchesSearch && matchesStatus
  })

  const handleViewCampaign = (campaign: EmailCampaign) => {
    setSelectedCampaign(campaign)
    setShowCampaignDialog(true)
  }

  const handlePauseCampaign = async (campaignId: string) => {
    try {
      if (isDemoMode) {
        setCampaigns(prev => prev.map(c => 
          c.id === campaignId ? { ...c, status: 'paused' } : c
        ))
        toast.success('Demo: Campaign paused')
        return
      }

      const response = await fetch(`/api/campaigns/${campaignId}/pause`, {
        method: 'POST'
      })

      if (response.ok) {
        loadCampaigns()
        toast.success('Campaign paused')
      } else {
        throw new Error('Failed to pause campaign')
      }
    } catch (error) {
      console.error('Error pausing campaign:', error)
      toast.error('Failed to pause campaign')
    }
  }

  const handleResumeCampaign = async (campaignId: string) => {
    try {
      if (isDemoMode) {
        setCampaigns(prev => prev.map(c => 
          c.id === campaignId ? { ...c, status: 'sending' } : c
        ))
        toast.success('Demo: Campaign resumed')
        return
      }

      const response = await fetch(`/api/campaigns/${campaignId}/resume`, {
        method: 'POST'
      })

      if (response.ok) {
        loadCampaigns()
        toast.success('Campaign resumed')
      } else {
        throw new Error('Failed to resume campaign')
      }
    } catch (error) {
      console.error('Error resuming campaign:', error)
      toast.error('Failed to resume campaign')
    }
  }

  const getStatusBadge = (status: string) => {
    const colors: { [key: string]: string } = {
      draft: 'bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-400',
      scheduled: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400',
      sending: 'bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400',
      sent: 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400',
      paused: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400',
      completed: 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400'
    }
    return colors[status] || colors.draft
  }

  const getStatusIcon = (status: string): JSX.Element => {
    switch (status) {
      case 'draft': return <Edit className="w-3 h-3" />
      case 'scheduled': return <Clock className="w-3 h-3" />
      case 'sending': return <Send className="w-3 h-3" />
      case 'sent': return <CheckCircle className="w-3 h-3" />
      case 'paused': return <Pause className="w-3 h-3" />
      case 'completed': return <CheckCircle className="w-3 h-3" />
      default: return <Mail className="w-3 h-3" />
    }
  }

  const calculateOpenRate = (campaign: EmailCampaign) => {
    return campaign.delivered_count > 0 
      ? Math.round((campaign.opened_count / campaign.delivered_count) * 100) 
      : 0
  }

  const calculateClickRate = (campaign: EmailCampaign) => {
    return campaign.opened_count > 0 
      ? Math.round((campaign.clicked_count / campaign.opened_count) * 100) 
      : 0
  }

  const totalStats = campaigns.reduce((acc, campaign) => ({
    totalSent: acc.totalSent + campaign.sent_count,
    totalOpened: acc.totalOpened + campaign.opened_count,
    totalClicked: acc.totalClicked + campaign.clicked_count,
    totalReplied: acc.totalReplied + campaign.replied_count
  }), { totalSent: 0, totalOpened: 0, totalClicked: 0, totalReplied: 0 })

  const avgOpenRate = totalStats.totalSent > 0 
    ? Math.round((totalStats.totalOpened / totalStats.totalSent) * 100) 
    : 0

  const avgClickRate = totalStats.totalOpened > 0 
    ? Math.round((totalStats.totalClicked / totalStats.totalOpened) * 100) 
    : 0

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Email Campaigns</h1>
          <p className="text-gray-600 dark:text-gray-400">
            Manage your biotech outreach campaigns • {isDemoMode ? 'Demo Data' : 'Production Data'}
          </p>
        </div>
        <div className="flex space-x-3">
          <Button 
            variant="outline" 
            onClick={handleRefresh}
            disabled={refreshing}
            className="flex items-center space-x-2"
          >
            <RefreshCw className={`w-4 h-4 ${refreshing ? 'animate-spin' : ''}`} />
            <span>{refreshing ? 'Syncing...' : 'Refresh'}</span>
          </Button>
          <Button variant="outline" className="flex items-center space-x-2">
            <BarChart3 className="w-4 h-4" />
            <span>Analytics</span>
          </Button>
          <Button 
            onClick={() => setShowCreateDialog(true)}
            className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600"
          >
            <Plus className="w-4 h-4" />
            <span>New Campaign</span>
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <Mail className="w-6 h-6 mx-auto mb-2 text-blue-500" />
            <p className="text-xl font-bold text-gray-900 dark:text-white">{campaigns.length}</p>
            <p className="text-xs text-gray-600 dark:text-gray-400">Total Campaigns</p>
          </CardContent>
        </Card>
        
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <Send className="w-6 h-6 mx-auto mb-2 text-green-500" />
            <p className="text-xl font-bold text-gray-900 dark:text-white">
              {totalStats.totalSent.toLocaleString()}
            </p>
            <p className="text-xs text-gray-600 dark:text-gray-400">Emails Sent</p>
          </CardContent>
        </Card>

        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <Eye className="w-6 h-6 mx-auto mb-2 text-purple-500" />
            <p className="text-xl font-bold text-gray-900 dark:text-white">{avgOpenRate}%</p>
            <p className="text-xs text-gray-600 dark:text-gray-400">Avg Open Rate</p>
          </CardContent>
        </Card>

        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <TrendingUp className="w-6 h-6 mx-auto mb-2 text-orange-500" />
            <p className="text-xl font-bold text-gray-900 dark:text-white">{avgClickRate}%</p>
            <p className="text-xs text-gray-600 dark:text-gray-400">Avg Click Rate</p>
          </CardContent>
        </Card>

        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <CheckCircle className="w-6 h-6 mx-auto mb-2 text-indigo-500" />
            <p className="text-xl font-bold text-gray-900 dark:text-white">
              {totalStats.totalReplied}
            </p>
            <p className="text-xs text-gray-600 dark:text-gray-400">Total Replies</p>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                <Input
                  placeholder="Search campaigns..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
            <div className="flex gap-3">
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value)}
                className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-sm bg-white dark:bg-gray-800"
              >
                <option value="all">All Status</option>
                <option value="draft">Draft</option>
                <option value="scheduled">Scheduled</option>
                <option value="sending">Sending</option>
                <option value="sent">Sent</option>
                <option value="paused">Paused</option>
                <option value="completed">Completed</option>
              </select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Campaigns Table */}
      {loading ? (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-12 text-center">
            <div className="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full mx-auto mb-4"></div>
            <p className="text-gray-600 dark:text-gray-400">Loading campaigns...</p>
          </CardContent>
        </Card>
      ) : filteredCampaigns.length === 0 ? (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-12 text-center">
            <Mail className="w-16 h-16 mx-auto mb-4 text-gray-400" />
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">No Campaigns Found</h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              {searchTerm || filterStatus !== 'all'
                ? 'No campaigns match your current filters'
                : 'No email campaigns created yet'
              }
            </p>
            <Button 
              onClick={() => setShowCreateDialog(true)}
              className="bg-gradient-to-r from-blue-500 to-purple-600"
            >
              <Plus className="w-4 h-4 mr-2" />
              Create Your First Campaign
            </Button>
          </CardContent>
        </Card>
      ) : (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">
              Campaigns ({filteredCampaigns.length})
            </CardTitle>
            <CardDescription>Your email marketing campaigns and their performance</CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-gray-200 dark:border-gray-700">
                  <TableHead className="text-gray-900 dark:text-white">Campaign</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Status</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Recipients</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Sent</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Open Rate</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Click Rate</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Replies</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Date</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredCampaigns.map((campaign) => (
                  <TableRow key={campaign.id} className="border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700">
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">{campaign.name}</p>
                        <p className="text-sm text-gray-500 dark:text-gray-400 truncate max-w-md">
                          {campaign.subject}
                        </p>
                        {campaign.template_name && (
                          <Badge variant="outline" className="mt-1 text-xs">
                            {campaign.template_name}
                          </Badge>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className={`${getStatusBadge(campaign.status)} flex items-center space-x-1 w-fit`}>
                        {getStatusIcon(campaign.status)}
                        <span className="capitalize">{campaign.status}</span>
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center text-sm text-gray-600 dark:text-gray-400">
                        <Users className="w-3 h-3 mr-1" />
                        {campaign.recipient_count}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">
                          {campaign.sent_count}/{campaign.recipient_count}
                        </p>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          {campaign.recipient_count > 0 
                            ? Math.round((campaign.sent_count / campaign.recipient_count) * 100) 
                            : 0}% sent
                        </p>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">
                          {calculateOpenRate(campaign)}%
                        </p>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          {campaign.opened_count} opens
                        </p>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">
                          {calculateClickRate(campaign)}%
                        </p>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          {campaign.clicked_count} clicks
                        </p>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className="font-medium text-gray-900 dark:text-white">
                        {campaign.replied_count}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="text-sm text-gray-600 dark:text-gray-400">
                        {campaign.sent_at ? (
                          <div>
                            <p>Sent</p>
                            <p className="text-xs">
                              {new Date(campaign.sent_at).toLocaleDateString()}
                            </p>
                          </div>
                        ) : campaign.scheduled_at ? (
                          <div>
                            <p>Scheduled</p>
                            <p className="text-xs">
                              {new Date(campaign.scheduled_at).toLocaleDateString()}
                            </p>
                          </div>
                        ) : (
                          <div>
                            <p>Created</p>
                            <p className="text-xs">
                              {new Date(campaign.created_at).toLocaleDateString()}
                            </p>
                          </div>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="sm">
                            <MoreHorizontal className="w-4 h-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Actions</DropdownMenuLabel>
                          <DropdownMenuItem onClick={() => handleViewCampaign(campaign)}>
                            <Eye className="w-4 h-4 mr-2" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <BarChart3 className="w-4 h-4 mr-2" />
                            View Analytics
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Edit className="w-4 h-4 mr-2" />
                            Edit Campaign
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Copy className="w-4 h-4 mr-2" />
                            Duplicate
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          {campaign.status === 'sending' ? (
                            <DropdownMenuItem onClick={() => handlePauseCampaign(campaign.id)}>
                              <Pause className="w-4 h-4 mr-2" />
                              Pause Campaign
                            </DropdownMenuItem>
                          ) : campaign.status === 'paused' ? (
                            <DropdownMenuItem onClick={() => handleResumeCampaign(campaign.id)}>
                              <Play className="w-4 h-4 mr-2" />
                              Resume Campaign
                            </DropdownMenuItem>
                          ) : null}
                          <DropdownMenuSeparator />
                          <DropdownMenuItem className="text-red-600">
                            <Trash className="w-4 h-4 mr-2" />
                            Delete
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {/* Campaign Creation Dialog */}
      <CampaignCreationDialog
        open={showCreateDialog}
        onOpenChange={setShowCreateDialog}
        onCampaignCreated={loadCampaigns}
      />

      {/* Campaign Detail Dialog */}
      {showCampaignDialog && selectedCampaign && (
        <Dialog open={showCampaignDialog} onOpenChange={setShowCampaignDialog}>
          <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle className="flex items-center space-x-2">
                <Mail className="w-5 h-5" />
                <span>{selectedCampaign.name}</span>
                <Badge className={getStatusBadge(selectedCampaign.status)}>
                  {selectedCampaign.status}
                </Badge>
              </DialogTitle>
              <DialogDescription>
                Campaign performance and detailed analytics
              </DialogDescription>
            </DialogHeader>
            
            <div className="space-y-6">
              {/* Campaign Overview */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold mb-3 text-gray-900 dark:text-white">Campaign Details</h4>
                  <div className="space-y-2 text-sm">
                    <p><strong>Subject:</strong> {selectedCampaign.subject}</p>
                    <p><strong>Template:</strong> {selectedCampaign.template_name || 'Custom'}</p>
                    <p><strong>Recipients:</strong> {selectedCampaign.recipient_count}</p>
                    {selectedCampaign.scheduled_at && (
                      <p><strong>Scheduled:</strong> {new Date(selectedCampaign.scheduled_at).toLocaleString()}</p>
                    )}
                    {selectedCampaign.sent_at && (
                      <p><strong>Sent:</strong> {new Date(selectedCampaign.sent_at).toLocaleString()}</p>
                    )}
                    <p><strong>Created:</strong> {new Date(selectedCampaign.created_at).toLocaleString()}</p>
                  </div>
                </div>
                
                <div>
                  <h4 className="font-semibold mb-3 text-gray-900 dark:text-white">Performance Metrics</h4>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center">
                      <span className="text-sm">Delivery Rate:</span>
                      <span className="font-medium">
                        {selectedCampaign.sent_count > 0 
                          ? Math.round((selectedCampaign.delivered_count / selectedCampaign.sent_count) * 100) 
                          : 0}%
                      </span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm">Open Rate:</span>
                      <span className="font-medium">{calculateOpenRate(selectedCampaign)}%</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm">Click Rate:</span>
                      <span className="font-medium">{calculateClickRate(selectedCampaign)}%</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm">Reply Rate:</span>
                      <span className="font-medium">
                        {selectedCampaign.sent_count > 0 
                          ? Math.round((selectedCampaign.replied_count / selectedCampaign.sent_count) * 100) 
                          : 0}%
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200 dark:border-gray-700">
                <Button variant="outline" onClick={() => setShowCampaignDialog(false)}>
                  Close
                </Button>
                <Button variant="outline">
                  <BarChart3 className="w-4 h-4 mr-2" />
                  Full Analytics
                </Button>
                <Button>
                  <Edit className="w-4 h-4 mr-2" />
                  Edit Campaign
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}
