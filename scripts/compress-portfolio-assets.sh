#!/bin/bash
# À lancer dans le dossier contenant toutes les images/PDF du repo PortFolio.
# Compresse en place (fait une sauvegarde dans ./originaux-backup/ avant).
# Nécessite: imagemagick (convert), ghostscript (gs)

set -e
mkdir -p originaux-backup

echo "== Compression des images (PNG/JPG) =="
find . -maxdepth 1 -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" | while read -r f; do
  # Ignore le dossier de backup lui-même
  [[ "$f" == ./originaux-backup/* ]] && continue

  cp -n "$f" "originaux-backup/" 2>/dev/null || true

  # Redimensionne si plus large que 1600px (largement suffisant pour un site web)
  # et recompresse avec une qualité 78 (bon compromis visuel/poids)
  convert "$f" -resize "1600x1600>" -strip -quality 78 "$f"

  echo "OK: $f"
done

echo ""
echo "== Compression des PDF =="
find . -maxdepth 1 -iname "*.pdf" | while read -r f; do
  [[ "$f" == ./originaux-backup/* ]] && continue

  cp -n "$f" "originaux-backup/" 2>/dev/null || true

  tmp="${f%.pdf}.compressed.pdf"
  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
     -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$tmp" "$f"

  # Ne remplace que si le résultat est plus léger
  orig_size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")
  new_size=$(stat -c%s "$tmp" 2>/dev/null || stat -f%z "$tmp")
  if [ "$new_size" -lt "$orig_size" ]; then
    mv "$tmp" "$f"
    echo "OK: $f ($orig_size -> $new_size octets)"
  else
    rm "$tmp"
    echo "SKIP (pas de gain): $f"
  fi
done

echo ""
echo "Terminé. Originaux sauvegardés dans ./originaux-backup/"
echo "Vérifie visuellement quelques fichiers avant de commit/push sur GitHub."
