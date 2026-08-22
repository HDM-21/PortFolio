// /api/contact.js
// Fonction serverless Vercel (Node.js runtime) — remplace EmailJS.
// La clé Resend (RESEND_API_KEY) et la clé secrète Turnstile (TURNSTILE_SECRET_KEY)
// restent des variables d'environnement côté serveur : elles ne sont JAMAIS
// envoyées au navigateur, contrairement à la clé publique EmailJS.

const RATE_LIMIT_WINDOW_MS = 60_000; // 1 minute
const RATE_LIMIT_MAX = 3;            // 3 envois max / IP / minute
// Stockage en mémoire (suffisant pour un formulaire de contact perso ;
// se réinitialise à chaque redéploiement / cold start, ce qui est acceptable ici).
const hits = new Map();

function isRateLimited(ip) {
  const now = Date.now();
  const arr = (hits.get(ip) || []).filter((t) => now - t < RATE_LIMIT_WINDOW_MS);
  arr.push(now);
  hits.set(ip, arr);
  return arr.length > RATE_LIMIT_MAX;
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

async function verifyTurnstile(token, ip) {
  const secret = process.env.TURNSTILE_SECRET_KEY;
  if (!secret) return false;
  const body = new URLSearchParams();
  body.append("secret", secret);
  body.append("response", token);
  if (ip) body.append("remoteip", ip);

  const r = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body,
  });
  const data = await r.json();
  return data.success === true;
}

module.exports = async (req, res) => {
  // CORS: same-origin only, pas besoin d'en-têtes CORS supplémentaires
  // puisque le front et l'API sont servis depuis le même domaine Vercel.

  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ ok: false, error: "method_not_allowed" });
  }

  const ip =
    (req.headers["x-forwarded-for"] || "").split(",")[0].trim() ||
    req.socket?.remoteAddress ||
    "unknown";

  if (isRateLimited(ip)) {
    return res.status(429).json({ ok: false, error: "rate_limited" });
  }

  let body = req.body;
  if (typeof body === "string") {
    try {
      body = JSON.parse(body);
    } catch {
      return res.status(400).json({ ok: false, error: "invalid_json" });
    }
  }

  const { name, email, subject, message, turnstileToken } = body || {};

  // Validation côté serveur (impossible à contourner, contrairement au HTML "required")
  if (!name || String(name).trim().length < 2) {
    return res.status(400).json({ ok: false, error: "invalid_name" });
  }
  if (!email || !isValidEmail(String(email).trim())) {
    return res.status(400).json({ ok: false, error: "invalid_email" });
  }
  if (!message || String(message).trim().length < 10) {
    return res.status(400).json({ ok: false, error: "invalid_message" });
  }
  if (!turnstileToken) {
    return res.status(400).json({ ok: false, error: "missing_captcha" });
  }

  const humanOk = await verifyTurnstile(turnstileToken, ip);
  if (!humanOk) {
    return res.status(400).json({ ok: false, error: "captcha_failed" });
  }

  const cleanName = escapeHtml(String(name).trim()).slice(0, 200);
  const cleanEmail = String(email).trim().slice(0, 200);
  const cleanSubject = escapeHtml(String(subject || "Contact depuis Portfolio HM").trim()).slice(0, 200);
  const cleanMessage = escapeHtml(String(message).trim()).slice(0, 5000);

  try {
    const resendRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        // "from" doit être une adresse sur un domaine que vous avez vérifié dans Resend
        from: "Portfolio <onboarding@resend.dev>",
        to: ["houssameddinemarchoual@gmail.com"],
        reply_to: cleanEmail,
        subject: `[Portfolio] ${cleanSubject}`,
        html: `
          <h2>Nouveau message depuis le portfolio</h2>
          <p><strong>Nom :</strong> ${cleanName}</p>
          <p><strong>Email :</strong> ${cleanEmail}</p>
          <p><strong>Sujet :</strong> ${cleanSubject}</p>
          <p><strong>Message :</strong></p>
          <p>${cleanMessage.replace(/\n/g, "<br>")}</p>
        `,
      }),
    });

    if (!resendRes.ok) {
      const errText = await resendRes.text();
      console.error("Resend API error:", errText);
      return res.status(502).json({ ok: false, error: "send_failed" });
    }

    return res.status(200).json({ ok: true });
  } catch (err) {
    console.error("Contact function error:", err);
    return res.status(500).json({ ok: false, error: "server_error" });
  }
};
