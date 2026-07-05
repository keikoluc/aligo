const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_APP_PASSWORD,
  },
});

async function sendOtpEmail(toEmail, code) {
  await transporter.sendMail({
    from: `"Aligo" <${process.env.GMAIL_USER}>`,
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
  });
}

module.exports = { sendOtpEmail };
