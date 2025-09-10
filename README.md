# Biotech Lead Generator

A comprehensive Next.js application for biotech technology due diligence lead generation, built for Ferreira CTO.

## Features

### 🎯 Lead Generation
- **Automated Contact Discovery**: Search for VCs, founders, and board members of Series A-C biotech companies
- **Apollo API Integration**: Professional contact data enrichment
- **Real-time Database Updates**: Automated refresh of contact information
- **Smart Filtering**: Target specific roles, funding stages, and locations

### 📧 Email Automation  
- **Template Management**: Create and customize email templates
- **Bulk Email Campaigns**: Send personalized emails to multiple contacts
- **Email Tracking**: Monitor opens, clicks, and replies
- **Contact Status Tracking**: Track communication history and responses

### 📊 Analytics Dashboard
- **Performance Metrics**: Email response rates, contact conversion
- **Visual Charts**: Contact distribution, email activity trends  
- **Company Insights**: Funding stage breakdown, industry analysis
- **Real-time Updates**: Live dashboard with latest metrics

### 🔧 Integrations
- **Supabase**: PostgreSQL database with real-time subscriptions
- **Apollo API**: Contact and company data discovery
- **HubSpot CRM**: Sync contacts and track engagement
- **Email Service**: SMTP integration for automated outreach

## Technology Stack

- **Framework**: Next.js 14 with TypeScript
- **Database**: Supabase (PostgreSQL)
- **Styling**: Tailwind CSS
- **Charts**: Recharts
- **APIs**: Apollo, HubSpot, Custom REST endpoints
- **Email**: Nodemailer
- **Web Scraping**: Puppeteer, Cheerio

## Quick Start

### Prerequisites
- Node.js 18+ and npm
- Supabase account
- Apollo API key
- HubSpot API key (optional)
- SMTP email credentials

### Installation

1. **Clone and install dependencies**:
```bash
cd biotech-lead-generator
npm install
```

2. **Set up environment variables**:
```bash
cp .env.example .env.local
```

Edit `.env.local` with your API keys:
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Apollo API
APOLLO_API_KEY=your_apollo_api_key

# HubSpot (optional)
HUBSPOT_API_KEY=your_hubspot_api_key

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=peter@ferreiracto.com
SMTP_PASS=your_email_app_password

# Company Information
COMPANY_NAME=Ferreira CTO
COMPANY_EMAIL=peter@ferreiracto.com
```

3. **Set up Supabase database**:
```bash
# Install Supabase CLI
npm install -g @supabase/cli

# Initialize Supabase
supabase init

# Run migrations
supabase db push
```

4. **Start development server**:
```bash
npm run dev
```

Visit `http://localhost:3000` to access your lead generation dashboard.

## Usage Guide

### 1. Dashboard Overview
- View total contacts, companies, and email performance
- Monitor response rates and engagement metrics
- Access quick actions for lead generation and email campaigns

### 2. Contact Management  
- **Search & Filter**: Find contacts by role, company, or status
- **Bulk Actions**: Update multiple contacts or send bulk emails
- **Contact Details**: View complete profiles with engagement history

### 3. Email Campaigns
- **Create Templates**: Design reusable email templates with variables
- **Send Campaigns**: Target specific contact segments
- **Track Performance**: Monitor email opens, clicks, and replies

### 4. Data Automation
- **Automated Scraping**: Schedule regular data updates
- **Contact Enrichment**: Enhance existing contacts with fresh data
- **API Integrations**: Sync with Apollo and HubSpot automatically

## API Endpoints

### Contacts
- `GET /api/contacts` - List contacts with filtering
- `POST /api/contacts` - Create new contact
- `PUT /api/contacts/[id]` - Update contact
- `DELETE /api/contacts/[id]` - Delete contact

### Email Campaigns  
- `GET /api/emails` - List email templates
- `POST /api/emails` - Send single email
- `POST /api/emails?action=send-bulk` - Send bulk campaign

### Data Integration
- `POST /api/integrations/scrape` - Run automated data scraping
- `GET /api/analytics/dashboard` - Get dashboard metrics

## Database Schema

### Companies Table
- Company information, funding stage, industry
- Website, location, employee count
- Crunchbase and LinkedIn URLs

### Contacts Table  
- Personal and professional information
- Role category (VC, Founder, Board Member, Executive)
- Contact status and engagement history
- Linked to company records

### Email Campaigns & Logs
- Template management and versioning
- Email tracking and analytics
- Performance metrics and engagement data

## Configuration

### Email Templates
Templates support variables for personalization:
- `{{first_name}}`, `{{last_name}}`, `{{full_name}}`
- `{{title}}`, `{{company_name}}`, `{{funding_stage}}`
- `{{sender_name}}`, `{{sender_company}}`, `{{sender_email}}`

### Automation Settings
- Configure scraping frequency and targets
- Set email rate limits and delays
- Customize data enrichment parameters

## Compliance & Best Practices

⚠️ **Important Legal Considerations**:

1. **Data Privacy**: Ensure compliance with GDPR, CCPA, and other data protection laws
2. **Email Regulations**: Follow CAN-SPAM Act and other email marketing regulations  
3. **Rate Limiting**: Respect API rate limits and implement appropriate delays
4. **Terms of Service**: Review and comply with Apollo, HubSpot, and other service terms
5. **Consent Management**: Implement proper opt-in/opt-out mechanisms

### Recommended Practices
- Always include unsubscribe links in emails
- Respect "do not contact" requests
- Use professional, value-focused email content
- Monitor and maintain sender reputation
- Regular data cleanup and validation

## Development

### Project Structure
```
biotech-lead-generator/
├── app/                    # Next.js 13+ app directory
├── components/            # Reusable UI components  
├── lib/                   # Utility libraries and services
├── pages/api/            # API routes
├── supabase/             # Database migrations
├── types/                # TypeScript type definitions
└── utils/                # Helper functions
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable  
5. Submit a pull request

## Support

For questions or issues:
- **Email**: peter@ferreiracto.com
- **Company**: Ferreira CTO

## License

This project is proprietary software developed for Ferreira CTO's internal use.

---

**Ferreira CTO** - Technology Due Diligence & Strategic Consulting
