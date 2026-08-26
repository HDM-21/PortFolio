#!/usr/bin/env bash
# ============================================================
# reorganize-portfolio.sh
# Réorganise automatiquement le repo HDM-21/PortFolio :
#   - crée l'arborescence assets/*, api/, scripts/, verification/
#   - déplace + renomme les fichiers avec git mv (historique conservé)
#   - met à jour les chemins dans index.html, vercel.json,
#     sitemap.xml, site.webmanifest
#
# UTILISATION :
#   1. Clone ton repo si ce n'est pas déjà fait :
#        git clone https://github.com/HDM-21/PortFolio.git
#        cd PortFolio
#   2. Copie ce script à la racine du repo
#   3. Fais une sauvegarde / vérifie que ton working tree est propre :
#        git status
#   4. Lance :
#        chmod +x reorganize-portfolio.sh
#        ./reorganize-portfolio.sh
#   5. Vérifie le résultat (git status, ouvre index.html en local),
#      puis commit :
#        git add -A
#        git commit -m "Reorganisation de l'arborescence du repo"
#        git push
#
# IMPORTANT : le script s'arrête sur la première erreur (set -e).
# Si un fichier n'existe pas chez toi (nom légèrement différent),
# corrige la ligne correspondante dans le mapping ci-dessous.
# ============================================================

set -euo pipefail

if [ ! -d ".git" ]; then
  echo "Erreur : lance ce script depuis la racine du repo cloné (dossier .git introuvable)."
  exit 1
fi

echo "== 1. Création de l'arborescence =="
mkdir -p assets/icons assets/logos assets/certifications assets/profile \
         assets/hero assets/pfe assets/pfa assets/stages-initiation \
         assets/mpls assets/scanner assets/slsa assets/docs assets/divers \
         scripts verification

# ============================================================
# MAPPING : "ancien_chemin|nouveau_chemin"
# Modifie/complète cette liste si des noms diffèrent chez toi.
# ============================================================
MAPPING=(
  # --- icons / favicons ---
  "favicon.ico|assets/icons/favicon.ico"
  "favicon-16.png|assets/icons/favicon-16.png"
  "favicon-32.png|assets/icons/favicon-32.png"
  "apple-touch-icon.png|assets/icons/apple-touch-icon.png"
  "icon-192.png|assets/icons/icon-192.png"
  "icon-512.png|assets/icons/icon-512.png"
  "og-image.png|assets/icons/og-image.png"

  # --- logos ---
  "logo-ensa-fes.png|assets/logos/logo-ensa-fes.png"
  "logo-huawei.png|assets/logos/logo-huawei.png"
  "logo-synapsis.png|assets/logos/logo-synapsis.png"
  "logo-marsa-maroc.png|assets/logos/logo-marsa-maroc.png"
  "Huawei-Logo.png|assets/logos/huawei-logo-full.png"
  "Synapsis-KS-Morocco-Logo.jpeg|assets/logos/synapsis-ks-morocco-logo.jpeg"
  "Marsa Maroc-logo.png|assets/logos/marsa-maroc-logo-full.png"

  # --- certifications ---
  "ISC2.jpg|assets/certifications/isc2.jpg"
  "Cisco.png|assets/certifications/cisco.png"
  "HCIA-5G.jpg|assets/certifications/hcia-5g.jpg"
  "CERTIFICATION_HCIA_DATACOM_Houssameddine_MARCHOUAL.png|assets/certifications/hcia-datacom.png"
  "photo_HCIA_ACCESS_V2.5_Certificate.png|assets/certifications/hcia-access-v2-5.png"
  "Encryption.png|assets/certifications/encryption.png"

  # --- profile ---
  "Image.jpg|assets/profile/image.jpg"
  "Photoo.jpg|assets/profile/photoo.jpg"
  "photo.jpg|assets/profile/photo.jpg"

  # --- hero ---
  "hero-anime.mp4|assets/hero/hero-anime.mp4"
  "hero-anime-poster.jpg|assets/hero/hero-anime-poster.jpg"

  # --- PFE ---
  "Stage-PFE-1.jpg|assets/pfe/stage-pfe-1.jpg"
  "Stage-PFE-2.jpg|assets/pfe/stage-pfe-2.jpg"
  "Stage-PFE-3.jpg|assets/pfe/stage-pfe-3.jpg"
  "Stage-PFE-4.jpg|assets/pfe/stage-pfe-4.jpg"
  "img_pfe1.jpg|assets/pfe/img-pfe-1.jpg"
  "img_pfe2.jpg|assets/pfe/img-pfe-2.jpg"
  "img_pfe3.jpg|assets/pfe/img-pfe-3.jpg"
  "pfe 1.png|assets/pfe/pfe-1.png"
  "pfe 2.png|assets/pfe/pfe-2.png"
  "pfe 3.png|assets/pfe/pfe-3.png"
  "Architecture Réseau Proposee - Synapsis KS Morocco.png|assets/pfe/architecture-reseau-proposee.png"
  "rack proposee.png|assets/pfe/rack-proposee.png"

  # --- PFA ---
  "PFA 1.jpg|assets/pfa/pfa-1.jpg"
  "PFA 2.jpg|assets/pfa/pfa-2.jpg"
  "PFA 3.jpg|assets/pfa/pfa-3.jpg"
  "PFA 4.jpg|assets/pfa/pfa-4.jpg"
  "PFA 5.jpg|assets/pfa/pfa-5.jpg"
  "PFA 6.jpg|assets/pfa/pfa-6.jpg"
  "PFA 7.jpg|assets/pfa/pfa-7.jpg"
  "PFA 8.jpg|assets/pfa/pfa-8.jpg"
  "PFA 9.jpg|assets/pfa/pfa-9.jpg"
  "PFA 10.jpg|assets/pfa/pfa-10.jpg"
  "PFA-academique.jpg|assets/pfa/pfa-academique.jpg"
  "Stage-PFA-1.jpg|assets/pfa/stage-pfa-1.jpg"
  "Stage-PFA-2.jpg|assets/pfa/stage-pfa-2.jpg"
  "Stage-PFA-3.jpg|assets/pfa/stage-pfa-3.jpg"
  "Stage-PFA-4.jpg|assets/pfa/stage-pfa-4.jpg"
  "probleme1.jpg|assets/pfa/probleme-1.jpg"
  "probleme1.png|assets/pfa/probleme-1.png"
  "probleme2.jpg|assets/pfa/probleme-2.jpg"
  "probleme3.jpg|assets/pfa/probleme-3.jpg"
  "probleme4.jpg|assets/pfa/probleme-4.jpg"

  # --- stages initiation ---
  "Stage-initiation-1.jpg|assets/stages-initiation/stage-initiation-1.jpg"
  "Stage-initiation-2.jpg|assets/stages-initiation/stage-initiation-2.jpg"
  "Stage-initiation-3.jpg|assets/stages-initiation/stage-initiation-3.jpg"
  "Stage-initiation-4.jpg|assets/stages-initiation/stage-initiation-4.jpg"

  # --- MPLS ---
  "mpls 1.png|assets/mpls/mpls-1.png"
  "mpls 2.png|assets/mpls/mpls-2.png"
  "mpls 3.png|assets/mpls/mpls-3.png"
  "mpls 4.png|assets/mpls/mpls-4.png"
  "mpls 5.png|assets/mpls/mpls-5.png"
  "mpls 6.png|assets/mpls/mpls-6.png"
  "Topologie_MPLS.png|assets/mpls/topologie-mpls.png"
  "chemin.png|assets/mpls/chemin.png"

  # --- scanner ---
  "scanner 1.jpg|assets/scanner/scanner-1.jpg"
  "scanner 2.jpg|assets/scanner/scanner-2.jpg"
  "scanner 3.jpg|assets/scanner/scanner-3.jpg"
  "Scanner1.jpg|assets/scanner/scanner-old-1.jpg"
  "Scanner2.jpg|assets/scanner/scanner-old-2.jpg"
  "scanner principal.png|assets/scanner/scanner-principal.png"

  # --- SLSA / docker ---
  "slsa 1.png|assets/slsa/slsa-1.png"
  "slsa 2.jpg|assets/slsa/slsa-2.jpg"
  "slsa 3.jpg|assets/slsa/slsa-3.jpg"
  "slsa principal.png|assets/slsa/slsa-principal.png"
  "Projet1-Docker.png|assets/slsa/projet1-docker.png"

  # --- divers ---
  "PBR.png|assets/divers/pbr.png"
  "Metabolisme-station-base-1.png|assets/divers/metabolisme-station-base-1.png"
  "Metabolisme-station-base-2.png|assets/divers/metabolisme-station-base-2.png"
  "Metabolisme-station-base-3.png|assets/divers/metabolisme-station-base-3.png"
  "Metabolisme-station-base-4.png|assets/divers/metabolisme-station-base-4.png"
  "Qualité de Service (QoS) pour VoIP.png|assets/divers/qos-voip.png"
  "bac.png|assets/divers/bac.png"
  "classes preparatoires.png|assets/divers/classes-preparatoires.png"
  "Ensa-Fes-Image.jpg|assets/divers/ensa-fes-image.jpg"
  "Dessin-ingenieur-reseau.png|assets/divers/dessin-ingenieur-reseau.png"
  "Fortigate - Architecture.jpg|assets/divers/fortigate-architecture.jpg"

  # --- docs (PDF) ---
  "CV HOUSSAMEDDINE MARCHOUAL.pdf|assets/docs/cv-houssameddine-marchoual.pdf"
  "MARCHOUAL_Houssameddine_ELABBADY_Wassima_Livrable_Version_Finale_GTR3_ENSA_Fès.pdf|assets/docs/livrable-final-gtr3-ensa-fes.pdf"
  "MARCHOUAL_Houssameddine_Etudes_Cas_Migration_Réseau_vers_MPLS_Maghreb_Connect_10_11_2025.pdf|assets/docs/etude-cas-migration-mpls-maghreb-connect.pdf"
  "PROJET_SCANNER_VULNERABILITES_JAVA_GTR_2_MARCHOUAL_CHEIKHI.pdf|assets/docs/projet-scanner-vulnerabilites-java.pdf"
  "Projet_Sécurisation_Image_Docker_2025_GTR3_S5_Version_Finale.pdf|assets/docs/projet-securisation-image-docker.pdf"
  "Rapport_PFA_2025 (1).pdf|assets/docs/rapport-pfa-2025.pdf"

  # --- scripts ---
  "compress-portfolio-assets.sh|scripts/compress-portfolio-assets.sh"

  # --- verification ---
  "googlef665120a480d350e.html|verification/googlef665120a480d350e.html"
)

echo "== 2. Déplacement des fichiers (git mv) =="
for entry in "${MAPPING[@]}"; do
  old="${entry%%|*}"
  new="${entry##*|}"
  if [ -f "$old" ]; then
    git mv -f -- "$old" "$new"
    echo "  OK: $old -> $new"
  else
    echo "  IGNORE (introuvable): $old"
  fi
done

echo "== 3. Mise à jour des chemins dans les fichiers de config/HTML =="
FILES_TO_PATCH=("index.html" "vercel.json" "sitemap.xml" "site.webmanifest")

for f in "${FILES_TO_PATCH[@]}"; do
  if [ -f "$f" ]; then
    for entry in "${MAPPING[@]}"; do
      old="${entry%%|*}"
      new="${entry##*|}"
      # échappe les caractères spéciaux sed dans l'ancien chemin
      old_esc=$(printf '%s' "$old" | sed -e 's/[.[\*^$/]/\\&/g')
      new_esc=$(printf '%s' "$new" | sed -e 's/[&/\]/\\&/g')
      sed -i "s|$old_esc|$new_esc|g" "$f"
    done
    echo "  Patché : $f"
  fi
done

echo "== Terminé =="
echo "Vérifie avec : git status"
echo "Puis : git add -A && git commit -m 'Reorganisation de l'\''arborescence du repo' && git push"
