export function getPasswordResetEmail(otp: string) {
  return `
    <!DOCTYPE html>
    <html lang="es">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Código de verificación para reestablecer contraseña</title>
      </head>

      <body style="margin: 0; padding: 0; background-color: #F7F1DF; font-family: Arial, Helvetica, sans-serif;">
        <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #F7F1DF; padding: 40px 16px;">
          <tr>
            <td align="center">
              <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 520px; background-color: #ffffff; border-radius: 16px; overflow: hidden;">
                
                <tr>
                  <td align="center" style="background-color: #B23A7D; padding: 36px 24px;">
                    <h1 style="margin: 0; color: #ffffff; font-size: 32px; font-weight: 600;">
                      Invitagil
                    </h1>
                  </td>
                </tr>

                <tr>
                  <td style="padding: 56px 48px 24px 48px; text-align: center;">
                    <h2 style="margin: 0; color: #252525; font-size: 36px; line-height: 1.2; font-weight: 700;">
                      Tu código de acceso
                    </h2>

                    <p style="margin: 32px 0 0 0; color: #333333; font-size: 18px; line-height: 1.6;">
                     Recibimos una solicitud para restablecer la contraseña de tu cuenta.
                    </p>

                    <p style="margin: 40px 0 0 0; color: #B23A7D; font-size: 40px; letter-spacing: 10px; font-weight: 700;">
                      ${otp}
                    </p>

                    <p style="margin: 32px 0 0 0; color: #555555; font-size: 16px; line-height: 1.6;">
                      Este código vencerá en 10 minutos.
                    </p>
                  </td>
                </tr>

                <tr>
                  <td style="padding: 24px 48px 56px 48px; text-align: center;">
                    <p style="margin: 0; color: #666666; font-size: 15px; line-height: 1.6;">
                      Si tú no solicitaste este cambio, puedes ignorar este correo. Tu contraseña actual seguirá siendo la misma.
                    </p>
                  </td>
                </tr>

              </table>
            </td>
          </tr>
        </table>
      </body>
    </html>
    `;
}
