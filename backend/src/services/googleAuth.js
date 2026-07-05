const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

async function verifyGoogleIdToken(idToken) {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: process.env.GOOGLE_CLIENT_ID,
  });

  const payload = ticket.getPayload();
  if (!payload || !payload.email) {
    throw new Error('Google token payload missing email');
  }

  return {
    email: payload.email,
    emailVerified: !!payload.email_verified,
    fullName: payload.name,
    avatarUrl: payload.picture,
  };
}

module.exports = { verifyGoogleIdToken };
