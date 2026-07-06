// Uses Resend's HTTP API rather than SMTP: Render's free tier blocks
// outbound SMTP (465/587) entirely, so nodemailer/Gmail can never
// connect there — HTTPS is unaffected. Sends from Resend's shared
// onboarding@resend.dev sender until aligoo.uz is verified on Resend
// for a branded "from" address.
const RESEND_API_URL = 'https://api.resend.com/emails';

async function sendOtpEmail(toEmail, code) {
  const response = await fetch(RESEND_API_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'Aligo <onboarding@resend.dev>',
      to: toEmail,
      subject: `${code} is your Aligo verification code`,
      text: `Your Aligo verification code is ${code}. It expires in ${process.env.OTP_TTL_MINUTES} minutes.`,
      html: `
        <div style="font-family: sans-serif; padding: 24px; color: #0F172A;">
          <h2 style="color: #0F172A;">Aligo verification code</h2>
          <p>Use the code below to verify your email and finish setting up your Aligo account.</p>
          <p style="font-size: 32px; font-weight: 700; letter-spacing: 8px; color: #F59E0B;">${code}</p>
          <p>This code expires in ${process.env.OTP_TTL_MINUTES} minutes. If you didn't request this, you can ignore this email.</p>
        </div>
      `,
    }),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    throw new Error(`Resend API error: ${response.status} ${body}`);
  }
}

module.exports = { sendOtpEmail };
