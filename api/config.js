module.exports = function handler(request, response) {
  const configuredUrl = process.env.SUPABASE_URL || 'https://wpsnskdlmneljqroejsf.supabase.co';
  const configuredKey = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indwc25za2RsbW5lbGpxcm9lanNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc0NTQ3NjgsImV4cCI6MjEwMzAzMDc2OH0.h94xQNu1EG9r_AhDnwuwQJUaPiVpo_hyf7GpxBkz-A0';
  const googleClientId = process.env.GOOGLE_CLIENT_ID || '';
  response.setHeader('Cache-Control', 'no-store');
  response.status(200).json({
    url: configuredUrl.replace(/\/$/, '').replace(/\/rest\/v1$/, ''),
    anonKey: configuredKey,
    googleClientId
  });
}
