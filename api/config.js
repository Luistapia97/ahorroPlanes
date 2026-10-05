module.exports = function handler(request, response) {
  const configuredUrl = process.env.SUPABASE_URL;
  const configuredKey = process.env.SUPABASE_ANON_KEY;
  const googleClientId = process.env.GOOGLE_CLIENT_ID || '';
  response.setHeader('Cache-Control', 'no-store');
  if (!configuredUrl || !configuredKey) {
    response.status(500).json({ error: 'Faltan SUPABASE_URL o SUPABASE_ANON_KEY en las variables de entorno.' });
    return;
  }
  response.status(200).json({
    url: configuredUrl.replace(/\/$/, '').replace(/\/rest\/v1$/, ''),
    anonKey: configuredKey,
    googleClientId
  });
};
