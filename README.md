# Portfolio de Houssameddine MARCHOUAL

Site portfolio personnel, déployé à l'adresse houssameddine-marchoual.vercel.app.

## Stack

- Frontend statique : HTML, CSS, JavaScript
- Backend : fonction serverless Vercel (`api/contact.js`) pour le formulaire de contact
- Envoi d'e-mails : Resend
- Anti-bot : Cloudflare Turnstile
- Hébergement : Vercel
- En-têtes de sécurité (CSP, etc.) définis dans `vercel.json`

## Structure du dépôt

```
.
├── index.html
├── api/
│   └── contact.js
├── vercel.json
├── sitemap.xml
├── site.webmanifest
├── assets/
│   ├── icons/            favicons, icônes PWA, image OpenGraph
│   ├── logos/             logos des écoles et entreprises partenaires
│   ├── certifications/    visuels des certifications (ISC², Huawei HCIA, Cisco...)
│   ├── profile/            photo de profil
│   ├── hero/                média de la section d'accueil
│   ├── pfe/                  visuels du projet de fin d'études
│   ├── pfa/                  visuels du projet de fin d'année
│   ├── stages-initiation/    visuels des stages d'initiation
│   ├── mpls/                 visuels de l'étude de cas migration MPLS
│   ├── scanner/               visuels du projet scanner de vulnérabilités
│   ├── slsa/                   visuels du projet de sécurisation d'image Docker
│   ├── divers/                  autres visuels
│   └── docs/                     rapports et CV au format PDF
├── scripts/
│   └── compress-portfolio-assets.sh
└── verification/
    └── googlef665120a480d350e.html
```

## Développement local

Le site est statique, aucune étape de build n'est nécessaire pour le prévisualiser :

```bash
git clone https://github.com/HDM-21/PortFolio.git
cd PortFolio
```

Ouvrir `index.html` directement dans un navigateur, ou servir le dossier avec un serveur local (ex. `npx serve .`) pour tester la fonction de contact via `vercel dev`.

## Déploiement

Le déploiement est géré par Vercel, connecté à ce dépôt. Tout push sur `main` déclenche un nouveau déploiement en production.
