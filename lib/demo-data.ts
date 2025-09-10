export const DEMO_COMPANIES = [
  {
    id: 'demo-comp-1',
    name: 'BioTech Innovations Inc.',
    website: 'https://biotechinnovations.com',
    industry: 'Biotechnology',
    funding_stage: 'Series B',
    location: 'Boston, MA, USA',
    description: 'AI-powered drug discovery platform leveraging machine learning to accelerate pharmaceutical development and reduce time-to-market for life-saving medications.',
    total_funding: 45000000,
    last_funding_date: '2024-06-15',
    employee_count: 125,
    crunchbase_url: 'https://crunchbase.com/organization/biotech-innovations',
    linkedin_url: 'https://linkedin.com/company/biotech-innovations',
    created_at: '2024-01-15T10:00:00Z',
    updated_at: '2024-09-07T15:30:00Z'
  },
  {
    id: 'demo-comp-2',
    name: 'GenomeTherapeutics',
    website: 'https://genometherapeutics.com',
    industry: 'Gene Therapy',
    funding_stage: 'Series A',
    location: 'San Francisco, CA, USA',
    description: 'Revolutionary gene therapy platform developing treatments for rare genetic diseases using CRISPR and advanced delivery systems.',
    total_funding: 28000000,
    last_funding_date: '2024-03-22',
    employee_count: 67,
    crunchbase_url: 'https://crunchbase.com/organization/genome-therapeutics',
    linkedin_url: 'https://linkedin.com/company/genome-therapeutics',
    created_at: '2024-02-01T09:00:00Z',
    updated_at: '2024-09-06T12:15:00Z'
  },
  {
    id: 'demo-comp-3',
    name: 'NeuralBio Systems',
    website: 'https://neuralbio.com',
    industry: 'Neurotechnology',
    funding_stage: 'Series C',
    location: 'Cambridge, MA, USA',
    description: 'Brain-computer interface technology for treating neurological disorders and enhancing cognitive function through advanced neural signal processing.',
    total_funding: 125000000,
    last_funding_date: '2024-07-10',
    employee_count: 245,
    crunchbase_url: 'https://crunchbase.com/organization/neuralbio-systems',
    linkedin_url: 'https://linkedin.com/company/neuralbio-systems',
    created_at: '2023-12-15T14:00:00Z',
    updated_at: '2024-09-07T10:45:00Z'
  },
  {
    id: 'demo-comp-4',
    name: 'Precision Diagnostics',
    website: 'https://precisiondiagnostics.com',
    industry: 'Medical Devices',
    funding_stage: 'Series B',
    location: 'Seattle, WA, USA',
    description: 'Next-generation liquid biopsy platform for early cancer detection using AI-powered molecular analysis.',
    total_funding: 65000000,
    last_funding_date: '2024-05-18',
    employee_count: 89,
    crunchbase_url: null,
    linkedin_url: 'https://linkedin.com/company/precision-diagnostics',
    created_at: '2024-01-08T11:30:00Z',
    updated_at: '2024-09-05T16:20:00Z'
  },
  {
    id: 'demo-comp-5',
    name: 'CellRegenerate',
    website: 'https://cellregenerate.bio',
    industry: 'Regenerative Medicine',
    funding_stage: 'Series A',
    location: 'San Diego, CA, USA',
    description: 'Stem cell therapy platform developing treatments for degenerative diseases and tissue repair.',
    total_funding: 34000000,
    last_funding_date: '2024-04-30',
    employee_count: 78,
    crunchbase_url: 'https://crunchbase.com/organization/cell-regenerate',
    linkedin_url: null,
    created_at: '2024-01-22T13:45:00Z',
    updated_at: '2024-09-04T09:30:00Z'
  }
]

export const DEMO_CONTACTS = [
  // BioTech Innovations contacts
  {
    id: 'demo-contact-1',
    company_id: 'demo-comp-1',
    first_name: 'Dr. Sarah',
    last_name: 'Chen',
    email: 'sarah.chen@biotechinnovations.com',
    phone: '+1 (617) 555-0123',
    title: 'CEO & Co-Founder',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/sarahchen-biotech',
    address: '100 Cambridge St, Boston, MA 02114',
    bio: 'Former MIT professor turned biotech entrepreneur. Expert in AI applications for drug discovery with 15+ years experience.',
    contact_status: 'not_contacted',
    last_contacted_at: null,
    created_at: '2024-01-15T10:30:00Z',
    updated_at: '2024-01-15T10:30:00Z'
  },
  {
    id: 'demo-contact-2',
    company_id: 'demo-comp-1',
    first_name: 'Michael',
    last_name: 'Rodriguez',
    email: 'm.rodriguez@biotechinnovations.com',
    phone: '+1 (617) 555-0124',
    title: 'Chief Technology Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/mrodriguez-cto',
    address: '100 Cambridge St, Boston, MA 02114',
    bio: 'Lead architect of the AI drug discovery platform. Previously CTO at two successful biotech exits.',
    contact_status: 'contacted',
    last_contacted_at: '2024-09-05T14:22:00Z',
    created_at: '2024-01-15T10:35:00Z',
    updated_at: '2024-09-05T14:22:00Z'
  },
  {
    id: 'demo-contact-3',
    company_id: 'demo-comp-1',
    first_name: 'Jennifer',
    last_name: 'Walsh',
    email: 'j.walsh@biotechinnovations.com',
    phone: null,
    title: 'VP of Technology',
    role_category: 'Executive',
    linkedin_url: null,
    address: '100 Cambridge St, Boston, MA 02114',
    bio: 'Leads the engineering team responsible for scalable cloud infrastructure and ML pipeline development.',
    contact_status: 'responded',
    last_contacted_at: '2024-09-03T11:15:00Z',
    created_at: '2024-01-15T10:40:00Z',
    updated_at: '2024-09-03T11:15:00Z'
  },
  // GenomeTherapeutics contacts
  {
    id: 'demo-contact-4',
    company_id: 'demo-comp-2',
    first_name: 'Dr. James',
    last_name: 'Liu',
    email: 'james.liu@genometherapeutics.com',
    phone: '+1 (415) 555-0201',
    title: 'CEO & Founder',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/jamesliu-genomics',
    address: '455 Mission Bay Blvd, San Francisco, CA 94158',
    bio: 'Pioneer in CRISPR gene editing with 20+ publications. Founded GenomeTherapeutics after breakthrough research at UCSF.',
    contact_status: 'interested',
    last_contacted_at: '2024-08-28T16:45:00Z',
    created_at: '2024-02-01T09:15:00Z',
    updated_at: '2024-08-28T16:45:00Z'
  },
  {
    id: 'demo-contact-5',
    company_id: 'demo-comp-2',
    first_name: 'Rachel',
    last_name: 'Kim',
    email: 'r.kim@genometherapeutics.com',
    phone: '+1 (415) 555-0202',
    title: 'Head of Technology',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/rachelkim-tech',
    address: '455 Mission Bay Blvd, San Francisco, CA 94158',
    bio: 'Technology leader with expertise in bioinformatics and clinical trial data systems.',
    contact_status: 'not_contacted',
    last_contacted_at: null,
    created_at: '2024-02-01T09:20:00Z',
    updated_at: '2024-02-01T09:20:00Z'
  },
  // NeuralBio Systems contacts
  {
    id: 'demo-contact-6',
    company_id: 'demo-comp-3',
    first_name: 'Dr. Amanda',
    last_name: 'Foster',
    email: 'amanda.foster@neuralbio.com',
    phone: '+1 (617) 555-0301',
    title: 'Co-Founder & CEO',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/amandafoster-neuro',
    address: '75 Sidney St, Cambridge, MA 02139',
    bio: 'Neuroscientist and entrepreneur leading the brain-computer interface revolution. Former Harvard Medical School faculty.',
    contact_status: 'contacted',
    last_contacted_at: '2024-09-02T13:30:00Z',
    created_at: '2023-12-15T14:15:00Z',
    updated_at: '2024-09-02T13:30:00Z'
  },
  {
    id: 'demo-contact-7',
    company_id: 'demo-comp-3',
    first_name: 'David',
    last_name: 'Park',
    email: 'd.park@neuralbio.com',
    phone: '+1 (617) 555-0302',
    title: 'Chief Technology Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/davidpark-neuralbio',
    address: '75 Sidney St, Cambridge, MA 02139',
    bio: 'Expert in real-time neural signal processing and brain-machine interfaces. 10+ years at leading neurotechnology companies.',
    contact_status: 'responded',
    last_contacted_at: '2024-08-25T10:20:00Z',
    created_at: '2023-12-15T14:20:00Z',
    updated_at: '2024-08-25T10:20:00Z'
  },
  {
    id: 'demo-contact-8',
    company_id: 'demo-comp-3',
    first_name: 'Lisa',
    last_name: 'Zhang',
    email: 'l.zhang@neuralbio.com',
    phone: null,
    title: 'VP Engineering',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/lisazhang-engineering',
    address: '75 Sidney St, Cambridge, MA 02139',
    bio: 'Engineering leader specializing in embedded systems and medical device development.',
    contact_status: 'not_contacted',
    last_contacted_at: null,
    created_at: '2023-12-15T14:25:00Z',
    updated_at: '2023-12-15T14:25:00Z'
  },
  // Precision Diagnostics contacts
  {
    id: 'demo-contact-9',
    company_id: 'demo-comp-4',
    first_name: 'Mark',
    last_name: 'Thompson',
    email: 'mark.thompson@precisiondiagnostics.com',
    phone: '+1 (206) 555-0401',
    title: 'CEO',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/markthompson-diagnostics',
    address: '1201 3rd Ave, Seattle, WA 98101',
    bio: 'Medical device entrepreneur with multiple successful exits in the diagnostics space.',
    contact_status: 'not_interested',
    last_contacted_at: '2024-08-15T09:45:00Z',
    created_at: '2024-01-08T11:45:00Z',
    updated_at: '2024-08-15T09:45:00Z'
  },
  {
    id: 'demo-contact-10',
    company_id: 'demo-comp-4',
    first_name: 'Dr. Elena',
    last_name: 'Vasquez',
    email: 'elena.vasquez@precisiondiagnostics.com',
    phone: '+1 (206) 555-0402',
    title: 'Chief Scientific Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/elenavasquez-science',
    address: '1201 3rd Ave, Seattle, WA 98101',
    bio: 'Leading oncologist and researcher in liquid biopsy technologies. 25+ years in cancer diagnostics.',
    contact_status: 'contacted',
    last_contacted_at: '2024-09-01T15:10:00Z',
    created_at: '2024-01-08T11:50:00Z',
    updated_at: '2024-09-01T15:10:00Z'
  },
  // CellRegenerate contacts
  {
    id: 'demo-contact-11',
    company_id: 'demo-comp-5',
    first_name: 'Dr. Robert',
    last_name: 'Martinez',
    email: 'robert.martinez@cellregenerate.bio',
    phone: '+1 (858) 555-0501',
    title: 'Founder & CEO',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/robertmartinez-stemcells',
    address: '10975 Torreyana Rd, San Diego, CA 92121',
    bio: 'Stem cell researcher and serial entrepreneur. Founded three biotech companies with focus on regenerative medicine.',
    contact_status: 'interested',
    last_contacted_at: '2024-08-30T12:00:00Z',
    created_at: '2024-01-22T14:00:00Z',
    updated_at: '2024-08-30T12:00:00Z'
  },
  {
    id: 'demo-contact-12',
    company_id: 'demo-comp-5',
    first_name: 'Anna',
    last_name: 'Williams',
    email: 'anna.williams@cellregenerate.bio',
    phone: '+1 (858) 555-0502',
    title: 'VP of Technology',
    role_category: 'Executive',
    linkedin_url: null,
    address: '10975 Torreyana Rd, San Diego, CA 92121',
    bio: 'Technology executive with expertise in bioprocessing and manufacturing systems for cell therapies.',
    contact_status: 'not_contacted',
    last_contacted_at: null,
    created_at: '2024-01-22T14:05:00Z',
    updated_at: '2024-01-22T14:05:00Z'
  }
]

export const DEMO_EMAIL_CAMPAIGNS = [
  {
    id: 'demo-campaign-1',
    name: 'Biotech CTO Introduction',
    subject: 'Technology Leadership Partnership - {{company_name}}',
    template: `Hi {{first_name}},

I hope this email finds you well. I'm Peter Ferreira, CTO consultant specializing in technology due diligence for biotech companies like {{company_name}}.

I've been following {{company_name}}'s progress in {{industry}} and am impressed by your {{funding_stage}} growth. Companies at your stage often face complex technology challenges around:

• Scalable cloud infrastructure for {{industry}} applications
• AI/ML pipeline optimization for research workflows  
• Regulatory compliance and data management systems
• Strategic technology roadmap planning

I help biotech CTOs and leadership teams navigate these challenges with hands-on expertise in AI, robotics, and SaaS platforms.

Would you be open to a brief 15-minute conversation about {{company_name}}'s technology priorities? I'd be happy to share some insights relevant to your {{industry}} focus.

{{sender_name}}
{{sender_company}}
{{sender_email}}
www.ferreiracto.com`,
    target_role_category: 'Executive',
    active: true,
    created_at: '2024-08-15T10:00:00Z',
    updated_at: '2024-09-01T14:30:00Z'
  },
  {
    id: 'demo-campaign-2',
    name: 'Founder Outreach - Strategic Technology',
    subject: 'Strategic Technology Partnership Opportunity',
    template: `Hello {{first_name}},

Congratulations on {{company_name}}'s recent {{funding_stage}} progress! As a founder in the {{industry}} space, you're building at an exciting intersection of technology and healthcare.

I'm Peter Ferreira, fractional CTO specializing in biotech technology strategy. I help {{funding_stage}} companies like yours accelerate growth through:

✓ Strategic technology architecture and scalability planning
✓ AI/ML platform optimization for {{industry}} applications  
✓ Technical due diligence for fundraising and partnerships
✓ CTO-level guidance without full-time commitment

Many founders find value in having an experienced technology advisor during rapid growth phases. Would you be interested in a brief conversation about {{company_name}}'s technology roadmap?

Best regards,
{{sender_name}}
Ferreira CTO - Technology Due Diligence
{{sender_email}}`,
    target_role_category: 'Founder',
    active: true,
    created_at: '2024-08-20T09:30:00Z',
    updated_at: '2024-09-02T11:15:00Z'
  }
]

export const DEMO_EMAIL_LOGS = [
  {
    id: 'demo-log-1',
    contact_id: 'demo-contact-2',
    campaign_id: 'demo-campaign-1',
    subject: 'Technology Leadership Partnership - BioTech Innovations Inc.',
    content: 'Personalized email content...',
    sent_at: '2024-09-05T14:22:00Z',
    opened_at: '2024-09-05T15:45:00Z',
    clicked_at: '2024-09-05T15:50:00Z',
    replied_at: null,
    bounced: false,
    status: 'clicked'
  },
  {
    id: 'demo-log-2',
    contact_id: 'demo-contact-3',
    campaign_id: 'demo-campaign-1',
    subject: 'Technology Leadership Partnership - BioTech Innovations Inc.',
    content: 'Personalized email content...',
    sent_at: '2024-09-03T11:15:00Z',
    opened_at: '2024-09-03T12:30:00Z',
    clicked_at: null,
    replied_at: '2024-09-03T16:20:00Z',
    bounced: false,
    status: 'replied'
  },
  {
    id: 'demo-log-3',
    contact_id: 'demo-contact-6',
    campaign_id: 'demo-campaign-2',
    subject: 'Strategic Technology Partnership Opportunity',
    content: 'Personalized email content...',
    sent_at: '2024-09-02T13:30:00Z',
    opened_at: '2024-09-02T14:15:00Z',
    clicked_at: null,
    replied_at: null,
    bounced: false,
    status: 'opened'
  }
]
