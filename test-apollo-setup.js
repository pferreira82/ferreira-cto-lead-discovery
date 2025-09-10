const fetch = require('node-fetch');

async function testSetup() {
  const baseUrl = 'http://localhost:3000/api/debug';
  
  console.log('🧪 Testing Apollo Setup...\n');
  
  try {
    // Test 1: Apollo Status
    console.log('1. Testing Apollo API status...');
    const statusRes = await fetch(`${baseUrl}/apollo-status`);
    const statusData = await statusRes.json();
    console.log(`   Status: ${statusData.diagnosis}`);
    console.log(`   Working: ${statusData.working}`);
    console.log(`   Companies returned: ${statusData.companiesReturned}\n`);
    
    // Test 2: Paid Plan Test
    console.log('2. Testing paid plan functionality...');
    const paidRes = await fetch(`${baseUrl}/apollo-paid-test`);
    const paidData = await paidRes.json();
    console.log(`   Status: ${paidData.status}`);
    console.log(`   Unique companies: ${paidData.uniqueCompaniesAcrossSearches}`);
    console.log(`   Biotech companies found: ${paidData.biotechCompaniesFound}`);
    console.log(`   Recommendation: ${paidData.recommendation}\n`);
    
    // Test 3: Discovery API
    console.log('3. Testing discovery search...');
    const discoveryRes = await fetch('http://localhost:3000/api/discovery/search', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        industries: ['Biotechnology'],
        fundingStages: ['Series A', 'Series B', 'Series C'],
        maxResults: 10
      })
    });
    const discoveryData = await discoveryRes.json();
    console.log(`   Companies found: ${discoveryData.totalCount}`);
    console.log(`   Data source: ${discoveryData.source}`);
    console.log(`   Message: ${discoveryData.message}\n`);
    
    // Summary
    console.log('📊 SUMMARY:');
    console.log(`   Apollo API: ${statusData.working ? 'Working' : 'Not working'}`);
    console.log(`   Paid Plan: ${paidData.isPaidPlanWorking ? 'Active' : 'Not active'}`);
    console.log(`   Discovery: ${discoveryData.totalCount} companies available`);
    console.log(`   Data Source: ${discoveryData.source}`);
    
  } catch (error) {
    console.error('Test failed:', error.message);
    console.log('\nMake sure your dev server is running: npm run dev');
  }
}

testSetup();
