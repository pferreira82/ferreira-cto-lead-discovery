import { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '../../../lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query

  switch (req.method) {
    case 'GET':
      return getContact(req, res, id as string)
    case 'PUT':
      return updateContact(req, res, id as string)
    case 'DELETE':
      return deleteContact(req, res, id as string)
    default:
      res.setHeader('Allow', ['GET', 'PUT', 'DELETE'])
      res.status(405).end(`Method ${req.method} Not Allowed`)
  }
}

async function getContact(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    const { data, error } = await supabaseAdmin
      .from('contacts')
      .select(`
        *,
        companies (
          id,
          name,
          industry,
          funding_stage,
          location
        )
      `)
      .eq('id', id)
      .single()

    if (error) throw error

    res.status(200).json(data)
  } catch (error) {
    console.error('Get Contact Error:', error)
    res.status(500).json({ error: 'Failed to fetch contact' })
  }
}

async function updateContact(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    const updateData = req.body

    const { data, error } = await supabaseAdmin
      .from('contacts')
      .update({
        ...updateData,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    res.status(200).json(data)
  } catch (error) {
    console.error('Update Contact Error:', error)
    res.status(500).json({ error: 'Failed to update contact' })
  }
}

async function deleteContact(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    const { error } = await supabaseAdmin
      .from('contacts')
      .delete()
      .eq('id', id)

    if (error) throw error

    res.status(204).end()
  } catch (error) {
    console.error('Delete Contact Error:', error)
    res.status(500).json({ error: 'Failed to delete contact' })
  }
}
