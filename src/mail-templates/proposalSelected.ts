export function getProposalSelectedEmail(proposalId: string) {
  const url = `https://agil-travel.com/proposal-view/${encodeURIComponent(proposalId)}`;
  const text = `¡Excelente elección! ✨

Gracias por elegirnos. Hemos recibido tu confirmación y estamos un paso más cerca de tu próximo viaje.

Nos pondremos en contacto contigo para coordinar el pago y proceder con tu reservación.

Recuerda que tu viaje quedará confirmado una vez que se haya completado el proceso de reservación.

Sigue rastreando tu viaje desde ${url}`;

  const html = `<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /></head>
<body style="margin:0;padding:24px;background:#F7F1DF;font-family:Arial,Helvetica,sans-serif;color:#333333;">
  <table role="presentation" cellpadding="0" cellspacing="0" style="width:100%;max-width:560px;margin:auto;background:#ffffff;border-radius:16px;">
    <tr><td style="padding:32px;line-height:1.6;">
      <h1 style="color:#B23A7D;font-size:28px;">¡Excelente elección! ✨</h1>
      <p>Gracias por elegirnos. Hemos recibido tu confirmación y estamos un paso más cerca de tu próximo viaje.</p>
      <p><strong>Nos pondremos en contacto contigo</strong> para coordinar el pago y proceder con tu reservación.</p>
      <p><strong>Recuerda que tu viaje quedará confirmado una vez que se haya completado el proceso de reservación.</strong></p>
      <p>Sigue rastreando tu viaje desde <a href="${url}" style="color:#B23A7D;">${url}</a></p>
    </td></tr>
  </table>
</body>
</html>`;
  return { html, text };
}
