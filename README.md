# Wyszukiwanie agentowe a strony i sklepy internetowe

Dokument techniczny o tym, co z „gotowości na agentów AI” działa dziś, co jest szkicem i jak to zmierzyć. Rozdziela trzy cele (widoczność w wyszukiwaniu z AI, obsługa strony przez agenta przeglądarkowego, zakupy przez protokoły), opisuje warstwy czytane przez agenta (drzewo dostępności, HTML, JSON-LD, llms.txt, robots.txt z Content-Signal, Web Bot Auth, negocjacja Markdown, ARD, WebMCP), metodologię i wyniki pomiaru czterech stron z 5 listopada 2026 oraz listę kontrolną dla strony i sklepu. 29 źródeł.

**Autor:** Piotr Czwarnowski · **Data:** 5 listopada 2026

## Pliki

| Ścieżka | Zawartość |
|---|---|
| [`wyszukiwanie-agentowe-strony-i-sklepy.md`](wyszukiwanie-agentowe-strony-i-sklepy.md) | dokument po polsku (oryginał) |
| [`agentic-search-websites-and-online-stores.md`](agentic-search-websites-and-online-stores.md) | pełne tłumaczenie na angielski |
| [`pomiary/`](pomiary/) | surowe odpowiedzi API PageSpeed Insights (8 plików JSON) i odczyty `curl` czterech stron; opis i czasy w [`pomiary/README.md`](pomiary/README.md) |
| [`skrypty/sprawdz-sygnaly.sh`](skrypty/sprawdz-sygnaly.sh) | kontrola sygnałów dla agentów na dowolnej domenie |
| [`przyklady/`](przyklady/) | prawdziwe llms.txt, manifest ARD, robots.txt i blok JSON-LD z mierzonej strony |
| [`obrazy/`](obrazy/) | zrzuty raportów użyte w dokumencie, zdjęcie autora |
| [`ZRODLA.md`](ZRODLA.md) | źródła z autorami, datami, adresami i licencjami |
| [`LICENSE`](LICENSE) | pełny tekst licencji CC BY 4.0 |

## Skrypt `sprawdz-sygnaly.sh`

Wymaga bash, curl i coreutils; `jq` opcjonalnie (sprawdza, czy każdy blok JSON-LD to poprawny JSON). Skrypt tylko czyta publiczne adresy: `/robots.txt`, `/llms.txt`, `/llms-full.txt`, `/.well-known/ard.json` i stronę główną (zwykłe żądanie i żądanie z `Accept: text/markdown`).

```bash
bash skrypty/sprawdz-sygnaly.sh example.com
```

Wynik dla `studioagat.pl` (5 listopada 2026):

```text
Sygnaly dla agentow: https://studioagat.pl/  (2026-11-05T15:55:02Z)
------------------------------------------------------------------------
robots.txt                         200 text/plain; charset=UTF-8
Content-Signal w robots.txt        tak, 22 wierszy
    22 Content-Signal: search=yes, ai-input=yes, ai-train=yes
ARD 1: Agentmap w robots.txt       brak
ARD 2: <link rel=ard> w HTML       brak
ARD 3: naglowek Link rel=ard       brak
ARD 4: /.well-known/ard.json       200 application/json
/llms.txt                          200 text/plain; charset=UTF-8 (H1: tak)
/llms-full.txt                     404 text/html; charset=UTF-8
strona glowna                      200 text/html; charset=UTF-8
Accept: text/markdown na /         200 text/html; charset=UTF-8
bloki application/ld+json          1 (1 z 1 poprawnych)
@type w blokach                    5x Service, 5x Offer, 3x PropertyValue, 1x WebSite, 1x PostalAddress, 1x OfferCatalog, 1x LocalBusiness+HomeAndConstructionBusiness, 1x ImageObject, 1x GeoCoordinates, 1x Brand
```

Wiersze „ARD 1-4” to drogi odkrywania manifestu w kolejności, w jakiej sprawdza je Lighthouse. Ograniczenie: skrypt wycina bloki JSON-LD wyrażeniem regularnym i zakłada, że treść bloku nie zawiera znaku `<`.

## Licencja

Treść: © Piotr Czwarnowski 2026, CC BY 4.0.

## Jak cytować

> Czwarnowski P., Wyszukiwanie agentowe a strony i sklepy internetowe: warstwy, pomiar, lista kontrolna, 2026-11-05, GitHub: https://github.com/ecopowerpolska/wyszukiwanie-agentowe

---

# Agentic search, websites and online stores

A technical document on which parts of "AI agent readiness" work today, which are drafts, and how to measure them. It separates three goals (visibility in AI search, operation of a site by a browser agent, purchases through protocols), describes the layers an agent reads (accessibility tree, HTML, JSON-LD, llms.txt, robots.txt with Content-Signal, Web Bot Auth, Markdown negotiation, ARD, WebMCP), the methodology and results of measuring four websites on 5 November 2026, and a checklist for a website and a store. 29 sources.

**Author:** Piotr Czwarnowski · **Date:** 5 November 2026

## Files

| Path | Contents |
|---|---|
| [`wyszukiwanie-agentowe-strony-i-sklepy.md`](wyszukiwanie-agentowe-strony-i-sklepy.md) | the document in Polish (original) |
| [`agentic-search-websites-and-online-stores.md`](agentic-search-websites-and-online-stores.md) | full English translation |
| [`pomiary/`](pomiary/) | raw PageSpeed Insights API responses (8 JSON files) and `curl` reads of four websites; description and timestamps in [`pomiary/README.md`](pomiary/README.md) (in Polish) |
| [`skrypty/sprawdz-sygnaly.sh`](skrypty/sprawdz-sygnaly.sh) | agent signal check for any domain |
| [`przyklady/`](przyklady/) | real llms.txt, ARD manifest, robots.txt and JSON-LD block from a measured website |
| [`obrazy/`](obrazy/) | report screenshots used in the document, author photo |
| [`ZRODLA.md`](ZRODLA.md) | sources with authors, dates, URLs and licences |
| [`LICENSE`](LICENSE) | full text of the CC BY 4.0 licence |

## The `sprawdz-sygnaly.sh` script

Requires bash, curl and coreutils; `jq` is optional (it checks that each JSON-LD block is valid JSON). The script only reads public URLs: `/robots.txt`, `/llms.txt`, `/llms-full.txt`, `/.well-known/ard.json` and the home page (a plain request and one with `Accept: text/markdown`). Output labels are in Polish; sample output for `studioagat.pl` is shown in the Polish section above.

```bash
bash skrypty/sprawdz-sygnaly.sh example.com
```

Rows "ARD 1-4" are the manifest discovery paths in the order Lighthouse checks them. Limitation: the script extracts JSON-LD blocks with a regular expression and assumes the block content contains no `<` character.

## Licence

Contents: © Piotr Czwarnowski 2026, CC BY 4.0.

## How to cite

> Czwarnowski P., Wyszukiwanie agentowe a strony i sklepy internetowe [Agentic search, websites and online stores: layers, measurement, checklist], 2026-11-05, GitHub: https://github.com/ecopowerpolska/wyszukiwanie-agentowe
