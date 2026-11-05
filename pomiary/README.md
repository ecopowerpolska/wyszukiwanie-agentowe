# Pomiary z 5 listopada 2026

Surowe dane do sekcji 4 i 5 dokumentu. Pliki nie są przetwarzane: to odpowiedzi API i serwerów zapisane bez zmian.

## Pliki `psi-*.json`

Odpowiedzi API PageSpeed Insights v5 (`https://www.googleapis.com/pagespeedonline/v5/runPagespeed`), po jednej na stronę i strategię, z kategoriami `performance`, `accessibility`, `best-practices`, `seo` i `agentic-browsing`. Lighthouse 13.6.0. Klucz API nie występuje w plikach. Jedyna zmiana względem odpowiedzi API: każdy napis `data:` dłuższy niż 100 znaków (zrzuty ekranu i miniatury w base64, 10 na plik) zastąpiono opisem `[usunieto dane base64: <typ>, <liczba> znakow]`; reszta pól jest bez zmian.

| Plik | `lighthouseResult.fetchTime` | Adres końcowy | Strategia |
|---|---|---|---|
| `psi-www.ecopowerpolska.pl-mobile.json` | 2026-11-05T11:37:59.434Z | https://www.ecopowerpolska.pl/ | mobile |
| `psi-www.ecopowerpolska.pl-desktop.json` | 2026-11-05T11:38:00.055Z | https://www.ecopowerpolska.pl/ | desktop |
| `psi-studioagat.pl-mobile.json` | 2026-11-05T11:37:59.957Z | https://studioagat.pl/ | mobile |
| `psi-studioagat.pl-desktop.json` | 2026-11-05T11:38:00.151Z | https://studioagat.pl/ | desktop |
| `psi-pan-stolarz.pl-mobile.json` | 2026-11-05T11:38:00.811Z | https://pan-stolarz.pl/ | mobile |
| `psi-pan-stolarz.pl-desktop.json` | 2026-11-05T11:37:59.686Z | https://pan-stolarz.pl/ | desktop |
| `psi-nadihome.pl-mobile.json` | 2026-11-05T11:38:00.273Z | https://nadihome.pl/ | mobile |
| `psi-nadihome.pl-desktop.json` | 2026-11-05T11:38:00.160Z | https://nadihome.pl/ | desktop |

Odczyt wyników kategorii:

```bash
jq '.lighthouseResult.categories[] | {id, score}' psi-studioagat.pl-mobile.json
```

Wynik `score` jest w skali 0-1 (0.98 = 98). Dla `agentic-browsing` `score` = 1 oznacza 4/4, bo kategoria ma `scoreDisplayMode` = `fraction`.

Inne przydatne zapytania:

```bash
# wersja Lighthouse, czas, adres końcowy
jq -r '.lighthouseResult | [.lighthouseVersion, .fetchTime, .finalDisplayedUrl] | @tsv' psi-studioagat.pl-mobile.json
# audyty kategorii agentowej z wagami
jq '.lighthouseResult.categories["agentic-browsing"].auditRefs' psi-studioagat.pl-mobile.json
# wynik każdego audytu agentowego
jq '.lighthouseResult.audits | to_entries[] | select(.key | test("agent|llms|ard|webmcp|cumulative")) | {id: .key, score: .value.score, mode: .value.scoreDisplayMode}' psi-studioagat.pl-mobile.json
# metryki laboratoryjne
jq '.lighthouseResult.audits | {fcp: ."first-contentful-paint".displayValue, lcp: ."largest-contentful-paint".displayValue, tbt: ."total-blocking-time".displayValue, cls: ."cumulative-layout-shift".displayValue}' psi-studioagat.pl-mobile.json
```

Plik można też otworzyć w [Lighthouse Viewer](https://googlechrome.github.io/lighthouse/viewer/) (przeciągnij plik JSON na stronę).

Obiekt `loadingExperience` zawiera tylko `initial_url`: API nie zwróciło dla tych adresów danych terenowych CrUX.

## Katalog `sygnaly/`

Odpowiedzi serwerów odczytane poleceniem `curl` 5 listopada 2026 między 11:43:15 a 11:43:18 UTC (nagłówek `date` w plikach `.hdr`). Jeden podkatalog na stronę.

| Plik | Zawartość |
|---|---|
| `robots.txt`, `robots.hdr` | treść i nagłówki `/robots.txt` |
| `llms.txt`, `llms.txt.body`, `llms.txt.hdr` | treść (dwa identyczne pliki) i nagłówki `/llms.txt` |
| `llms-full.txt`, `llms-full.txt.body`, `llms-full.txt.hdr` | odpowiedź na `/llms-full.txt`; na www.ecopowerpolska.pl, studioagat.pl i pan-stolarz.pl to strona błędu 404 w HTML, nie plik tekstowy (status w pierwszym wierszu `.hdr`) |
| `home.html`, `home.hdr` | strona główna i jej nagłówki |
| `md.body`, `md.hdr` | odpowiedź strony głównej na `Accept: text/markdown`; `content-type` w `.hdr` to `text/html`, treść jest taka sama jak `home.html` |

`sygnaly-podsumowanie.txt` to zestawienie tych odczytów: status, typ i rozmiar każdego pliku, początek llms.txt, typy JSON-LD strony głównej, nagłówki i pełne robots.txt czterech stron.

Pliki robots.txt zawierają komentarze autorów stron (uzasadnienie decyzji o botach); są cytowane bez zmian.
