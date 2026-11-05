# Przykłady

Prawdziwe pliki z mierzonej strony www.ecopowerpolska.pl, pobrane poleceniem `curl` 5 listopada 2026 o 15:53 UTC. Treść jest taka, jaką oddał serwer; pliki mogą się od tego czasu zmienić.

| Plik | Źródło | Status, typ | Rozmiar |
|---|---|---|---|
| `ecopowerpolska.pl-llms.txt` | https://www.ecopowerpolska.pl/llms.txt | 200, `text/plain; charset=utf-8` | 13 441 B |
| `ecopowerpolska.pl-ard.json` | https://www.ecopowerpolska.pl/.well-known/ard.json | 200, `application/json; charset=utf-8` | 10 231 B |
| `ecopowerpolska.pl-robots.txt` | https://www.ecopowerpolska.pl/robots.txt | 200, `text/plain; charset=utf-8` | 3 914 B |
| `ecopowerpolska.pl-jsonld-organization.json` | pierwszy blok `<script type="application/ld+json">` strony https://www.ecopowerpolska.pl/, sformatowany `jq .` | 200, `text/html` | 1 777 B |

Polecenia:

```bash
curl -sS -o ecopowerpolska.pl-llms.txt https://www.ecopowerpolska.pl/llms.txt
curl -sS -o ecopowerpolska.pl-ard.json https://www.ecopowerpolska.pl/.well-known/ard.json
curl -sS -o ecopowerpolska.pl-robots.txt https://www.ecopowerpolska.pl/robots.txt
curl -sS https://www.ecopowerpolska.pl/ \
  | perl -0ne 'print $1 if /<script type="application\/ld\+json"[^>]*>(.*?)<\/script>/s' \
  | jq . > ecopowerpolska.pl-jsonld-organization.json
```

Uwagi:

- `robots.txt` jest identyczny z odczytem z 11:43 UTC w `pomiary/sygnaly/`. `llms.txt` różni się od tamtego odczytu jednym wierszem: między odczytami na stronie przybył wpis na blogu.
- Blok JSON-LD ma typ `["Organization","LocalBusiness"]`; drugi blok strony głównej (`@graph` z WebSite, OfferCatalog i usługami) jest w `pomiary/sygnaly/www.ecopowerpolska.pl/home.html`.
- Manifest ARD ma 11 wpisów; każdy niesie węzeł schema.org w polu `data` i 2-3 `representativeQueries`. Pole `specVersion` ma wartość `1.0`; audyt Lighthouse `ard-schema` tego pola nie ocenia.
- Pliki zawierają wyłącznie dane firmy (nazwa, adres siedziby, telefon i e-mail firmowy, KRS, NIP, REGON).
