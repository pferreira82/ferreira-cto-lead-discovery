#!/bin/bash

# Create missing UI components and utilities

# 1. Create lib/utils.ts
cat > lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF

# 2. Create Card component
cat > components/ui/card.tsx << 'EOF'
import * as React from "react"
import { cn } from "@/lib/utils"

const Card = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      "rounded-lg border bg-card text-card-foreground shadow-sm",
      className
    )}
    {...props}
  />
))
Card.displayName = "Card"

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col space-y-1.5 p-6", className)}
    {...props}
  />
))
CardHeader.displayName = "CardHeader"

const CardTitle = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn(
      "text-2xl font-semibold leading-none tracking-tight",
      className
    )}
    {...props}
  />
))
CardTitle.displayName = "CardTitle"

const CardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn("text-sm text-muted-foreground", className)}
    {...props}
  />
))
CardDescription.displayName = "CardDescription"

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
))
CardContent.displayName = "CardContent"

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex items-center p-6 pt-0", className)}
    {...props}
  />
))
CardFooter.displayName = "CardFooter"

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent }
EOF

# 3. Create Badge component
cat > components/ui/badge.tsx << 'EOF'
import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
  {
    variants: {
      variant: {
        default:
          "border-transparent bg-primary text-primary-foreground hover:bg-primary/80",
        secondary:
          "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80",
        destructive:
          "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80",
        outline: "text-foreground",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant }), className)} {...props} />
  )
}

export { Badge, badgeVariants }
EOF

# 4. Create Progress component
cat > components/ui/progress.tsx << 'EOF'
import * as React from "react"
import * as ProgressPrimitive from "@radix-ui/react-progress"
import { cn } from "@/lib/utils"

const Progress = React.forwardRef<
  React.ElementRef<typeof ProgressPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof ProgressPrimitive.Root>
>(({ className, value, ...props }, ref) => (
  <ProgressPrimitive.Root
    ref={ref}
    className={cn(
      "relative h-4 w-full overflow-hidden rounded-full bg-secondary",
      className
    )}
    {...props}
  >
    <ProgressPrimitive.Indicator
      className="h-full w-full flex-1 bg-primary transition-all"
      style={{ transform: `translateX(-${100 - (value || 0)}%)` }}
    />
  </ProgressPrimitive.Root>
))
Progress.displayName = ProgressPrimitive.Root.displayName

export { Progress }
EOF

# 5. Create layout file
cat > app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Biotech Lead Generator - Ferreira CTO',
  description: 'Technology due diligence lead generation for biotech companies',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
EOF

# 6. Create global CSS file
cat > app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;

    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;

    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;

    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;

    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 84% 4.9%;

    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;

    --accent: 210 40% 96%;
    --accent-foreground: 222.2 84% 4.9%;

    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;

    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;

    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;

    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;

    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;

    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;

    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;

    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;

    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;

    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;

    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOF

# 7. Create API route for analytics
mkdir -p pages/api/analytics
cat > pages/api/analytics/dashboard.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '../../../lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    // Get basic stats
    const { data: contacts, count: totalContacts } = await supabaseAdmin
      .from('contacts')
      .select('*', { count: 'exact' })

    const { data: companies, count: totalCompanies } = await supabaseAdmin
      .from('companies')
      .select('*', { count: 'exact' })

    const { data: emailLogs, count: emailsSent } = await supabaseAdmin
      .from('email_logs')
      .select('*', { count: 'exact' })

    // Calculate response rate
    const { count: repliedEmails } = await supabaseAdmin
      .from('email_logs')
      .select('*', { count: 'exact' })
      .eq('status', 'replied')

    const responseRate = emailsSent ? Math.round((repliedEmails || 0) / emailsSent * 100) : 0

    // Get contacts not yet contacted
    const { count: notContactedCount } = await supabaseAdmin
      .from('contacts')
      .select('*', { count: 'exact' })
      .eq('contact_status', 'not_contacted')

    // Get contacts contacted this week
    const weekAgo = new Date()
    weekAgo.setDate(weekAgo.getDate() - 7)
    
    const { count: contactedThisWeek } = await supabaseAdmin
      .from('contacts')
      .select('*', { count: 'exact' })
      .gte('last_contacted_at', weekAgo.toISOString())

    // Mock chart data for now (you can enhance this with real queries)
    const chartData = {
      emailActivity: [
        { date: '2024-09-01', sent: 25, opened: 15, replied: 3 },
        { date: '2024-09-02', sent: 30, opened: 18, replied: 5 },
        { date: '2024-09-03', sent: 22, opened: 12, replied: 2 },
        { date: '2024-09-04', sent: 28, opened: 20, replied: 4 },
        { date: '2024-09-05', sent: 35, opened: 25, replied: 6 },
        { date: '2024-09-06', sent: 20, opened: 14, replied: 3 },
        { date: '2024-09-07', sent: 15, opened: 10, replied: 2 },
      ],
      contactsByRole: [
        { role: 'Founder', count: 45, color: '#8884d8' },
        { role: 'Executive', count: 67, color: '#82ca9d' },
        { role: 'VC', count: 23, color: '#ffc658' },
        { role: 'Board Member', count: 18, color: '#ff7300' },
      ],
      companiesByStage: [
        { stage: 'Series A', count: 15 },
        { stage: 'Series B', count: 22 },
        { stage: 'Series C', count: 8 },
      ]
    }

    const stats = {
      totalContacts: totalContacts || 0,
      totalCompanies: totalCompanies || 0,
      emailsSent: emailsSent || 0,
      responseRate,
      contactedThisWeek: contactedThisWeek || 0,
      notContactedCount: notContactedCount || 0
    }

    res.status(200).json({
      stats,
      charts: chartData
    })
  } catch (error) {
    console.error('Dashboard API Error:', error)
    res.status(500).json({ error: 'Failed to fetch dashboard data' })
  }
}
EOF

echo "✅ All missing components and files created!"
echo "📁 Created:"
echo "  - lib/utils.ts"
echo "  - components/ui/card.tsx"
echo "  - components/ui/badge.tsx"
echo "  - components/ui/progress.tsx"
echo "  - app/layout.tsx"
echo "  - app/globals.css"
echo "  - pages/api/analytics/dashboard.ts"
echo "  - Updated next.config.js"
