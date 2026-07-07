import nodemailer from "nodemailer";
// Create a transporter using SMTP
export const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 465,
  secure: true, // use STARTTLS (upgrade connection to TLS after connecting)
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

async function testMailer() {
  try {
    await transporter.verify()
    console.log('Mailer configurado correctamente')
  } catch (error) {
    console.error('Error en la configuración de mailer:')
    console.error(error)
  }
}

testMailer()