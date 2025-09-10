const fetch = require('node-fetch');
require('dotenv').config({ path: '.env.local' });

async function testApolloAPI() {
  const apiKey = process.env.APOLLO_API_KEY;
  
  console.log('Testing Apollo API...');
  console.log('API Key configured:', !!apiKey);
  console.log('API Key length:', apiKey?.length || 0);
  
  if (!apiKey) {
    console.error('❌ No Apollo API key found in .env.local');
    return;
  }

  try {
    const response = await fetch('https://api.apollo.io/v1/organizations/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': apiKey
      },
      body: JSON.stringify({
        page: 1,
        per_page: 5,
        organization_locations: ['United States'],
        industry_tag_ids: ['5567cd4073696424b10b0000'], // Biotechnology
        organization_num_employees_ranges: ['11-50'],
        funding_stage_list: ['Series A']
      })
    });

    console.log('Response status:', response.status);
    
    if (response.ok) {
      const data = await response.json();
      console.log('✅ Success! Found', data.organizations?.length || 0, 'organizations');
      console.log('Sample company:', data.organizations?.[0]?.name || 'No companies found');
    } else {
      const error = await response.text();
      console.error('❌ Error:', error);
    }
  } catch (error) {
    console.error('❌ Request failed:', error.message);
  }
}

testApolloAPI();
