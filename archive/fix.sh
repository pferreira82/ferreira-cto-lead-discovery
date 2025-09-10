#!/bin/bash

echo "Quick fix for supabaseAdmin null errors"
echo "======================================"

# Quick fix for the immediate error in app/api/companies/[id].ts
if [ -f "app/api/companies/[id].ts" ]; then
    echo "Fixing app/api/companies/[id].ts..."
    
    # Create backup
    cp "app/api/companies/[id].ts" "app/api/companies/[id].ts.backup"
    
    # Add null check at the beginning of each function
    sed -i.tmp '/async function getCompany/,/try {/c\
async function getCompany(req: NextApiRequest, res: NextApiResponse, id: string) {\
  try {\
    if (!supabaseAdmin) {\
      return res.status(500).json({ error: "Database not configured" })\
    }' "app/api/companies/[id].ts"
    
    sed -i.tmp '/async function updateCompany/,/try {/c\
async function updateCompany(req: NextApiRequest, res: NextApiResponse, id: string) {\
  try {\
    if (!supabaseAdmin) {\
      return res.status(500).json({ error: "Database not configured" })\
    }' "app/api/companies/[id].ts"
    
    sed -i.tmp '/async function deleteCompany/,/try {/c\
async function deleteCompany(req: NextApiRequest, res: NextApiResponse, id: string) {\
  try {\
    if (!supabaseAdmin) {\
      return res.status(500).json({ error: "Database not configured" })\
    }' "app/api/companies/[id].ts"
    
    rm -f "app/api/companies/[id].ts.tmp"
    echo "✅ Fixed app/api/companies/[id].ts"
fi

# Fix app/api/contacts/[id].ts if it exists
if [ -f "app/api/contacts/[id].ts" ]; then
    echo "Fixing app/api/contacts/[id].ts..."
    
    cp "app/api/contacts/[id].ts" "app/api/contacts/[id].ts.backup"
    
    sed -i.tmp '/async function getContact/,/try {/c\
async function getContact(req: NextApiRequest, res: NextApiResponse, id: string) {\
  try {\
    if (!supabaseAdmin) {\
      return res.status(500).json({ error: "Database not configured" })\
    }' "app/api/contacts/[id].ts"
    
    sed -i.tmp '/async function updateContact/,/try {/c\
async function updateContact(req: NextApiRequest, res: NextApiResponse, id: string) {\
  try {\
    if (!supabaseAdmin) {\
      return res.status(500).json({ error: "Database not configured" })\
    }' "app/api/contacts/[id].ts"
    
    sed -i.tmp '/async function deleteContact/,/try {/c\
async function deleteContact(req: NextApiRequest, res: NextApiResponse, id: string) {\
  try {\
    if (!supabaseAdmin) {\
      return res.status(500).json({ error: "Database not configured" })\
    }' "app/api/contacts/[id].ts"
    
    rm -f "app/api/contacts/[id].ts.tmp"
    echo "✅ Fixed app/api/contacts/[id].ts"
fi

echo ""
echo "Quick fixes applied! Try building now:"
echo "npm run build"
