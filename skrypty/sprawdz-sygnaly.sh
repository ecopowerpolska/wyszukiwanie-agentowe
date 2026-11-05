#!/usr/bin/env bash
# sprawdz-sygnaly.sh - odczyt sygnalow dla agentow AI na jednej domenie.
# Uzycie: bash sprawdz-sygnaly.sh example.com
# Wymaga: bash, curl i coreutils (grep, sed, sort, uniq, paste, tr). jq opcjonalnie (walidacja blokow JSON-LD).
# Skrypt tylko czyta publiczne adresy: robots.txt, llms.txt, llms-full.txt,
# /.well-known/ard.json i strone glowna (raz zwyklym GET, raz z Accept: text/markdown).
set -euo pipefail

if [[ $# -ne 1 || -z "$1" ]]; then
  echo "Uzycie: $0 <domena>   np. $0 example.com" >&2
  exit 2
fi

host="$1"
host="${host#http://}"
host="${host#https://}"
host="${host%%/*}"
base="https://${host}"

ua="sprawdz-sygnaly/1.0 (+https://github.com/ecopowerpolska/wyszukiwanie-agentowe)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# pobierz <sciezka> <plik> [naglowek] -> drukuje "kod content-type"
pobierz() {
  local sciezka="$1" plik="$2" naglowek="${3:-}"
  local args=(-sS -L --max-time 20 -A "$ua" -D "${plik}.hdr" -o "$plik" -w '%{http_code} %{content_type}')
  [[ -n "$naglowek" ]] && args+=(-H "$naglowek")
  curl "${args[@]}" "${base}${sciezka}" 2>/dev/null || echo "000 -"
}

wiersz() { printf '%-34s %s\n' "$1" "$2"; }

# robots.txt
robots_wynik="$(pobierz /robots.txt "$tmp/robots.txt")"
cs_wiersze="$(grep -i '^[[:space:]]*content-signal[[:space:]]*:' "$tmp/robots.txt" 2>/dev/null | tr -d '\r' || true)"
if [[ -n "$cs_wiersze" ]]; then
  cs_liczba="$(printf '%s\n' "$cs_wiersze" | wc -l | tr -d ' ')"
  cs_opis="tak, ${cs_liczba} wierszy"
else
  cs_opis="nie"
fi
agentmap="$(grep -i '^[[:space:]]*agentmap[[:space:]]*:' "$tmp/robots.txt" 2>/dev/null | tr -d '\r' | head -n 1 || true)"

# llms.txt, llms-full.txt, ard.json
llms="$(pobierz /llms.txt "$tmp/llms.txt")"
llms_full="$(pobierz /llms-full.txt "$tmp/llms-full.txt")"
llms_h1="nie"
if grep -q '^# ' "$tmp/llms.txt" 2>/dev/null; then llms_h1="tak"; fi
ard="$(pobierz /.well-known/ard.json "$tmp/ard.json")"

# strona glowna: HTML i naglowki
home="$(pobierz / "$tmp/home.html")"
md="$(pobierz / "$tmp/md.html" 'Accept: text/markdown')"
link_ard="$(grep -i '^link:' "$tmp/home.html.hdr" 2>/dev/null | grep -i 'rel="\{0,1\}ard' | tr -d '\r' | head -n 1 || true)"

plaski="$tmp/home.flat"
tr '\r\n' '  ' < "$tmp/home.html" > "$plaski" || true
rel_ard="$(grep -o -i '<link[^>]*rel=["'\'']\{0,1\}ard["'\'' ][^>]*>' "$plaski" | head -n 1 || true)"

# bloki JSON-LD (ograniczenie: zaklada, ze tresc bloku nie zawiera znaku "<")
grep -o -i '<script[^>]*application/ld+json[^>]*>[^<]*</script>' "$plaski" > "$tmp/ld.txt" || true
ld_liczba="$(grep -c . "$tmp/ld.txt" || true)"
typy="$(grep -o '"@type"[[:space:]]*:[[:space:]]*\(\[[^]]*\]\|"[^"]*"\)' "$tmp/ld.txt" \
  | sed -e 's/^"@type"[[:space:]]*:[[:space:]]*//' -e 's/[][" ]//g' -e 's/,/+/g' \
  | sort | uniq -c | sort -rn | sed 's/^ *\([0-9]*\) \(.*\)$/\1x \2/' | paste -sd, - | sed 's/,/, /g' || true)"

ld_json="nie sprawdzono (brak jq)"
if command -v jq >/dev/null 2>&1 && [[ "$ld_liczba" -gt 0 ]]; then
  dobre=0
  while IFS= read -r blok; do
    tresc="$(printf '%s' "$blok" | sed -e 's/^<script[^>]*>//' -e 's/<\/script>$//')"
    if printf '%s' "$tresc" | jq -e . >/dev/null 2>&1; then dobre=$((dobre + 1)); fi
  done < "$tmp/ld.txt"
  ld_json="${dobre} z ${ld_liczba} poprawnych"
fi

echo "Sygnaly dla agentow: ${base}/  ($(date -u +%Y-%m-%dT%H:%M:%SZ))"
printf -- '-%.0s' {1..72}; echo
wiersz "robots.txt" "$robots_wynik"
wiersz "Content-Signal w robots.txt" "$cs_opis"
if [[ -n "$cs_wiersze" ]]; then
  printf '%s\n' "$cs_wiersze" | sed 's/^[[:space:]]*//' | sort | uniq -c | sed 's/^ */    /'
fi
wiersz "ARD 1: Agentmap w robots.txt" "${agentmap:-brak}"
wiersz "ARD 2: <link rel=ard> w HTML" "${rel_ard:-brak}"
wiersz "ARD 3: naglowek Link rel=ard" "${link_ard:-brak}"
wiersz "ARD 4: /.well-known/ard.json" "$ard"
wiersz "/llms.txt" "$llms (H1: $llms_h1)"
wiersz "/llms-full.txt" "$llms_full"
wiersz "strona glowna" "$home"
wiersz "Accept: text/markdown na /" "$md"
wiersz "bloki application/ld+json" "${ld_liczba} (${ld_json})"
wiersz "@type w blokach" "${typy:-brak}"
