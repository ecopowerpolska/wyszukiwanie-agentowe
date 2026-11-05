# Agentic search, websites and online stores: layers, measurement, checklist

Author: **Piotr Czwarnowski**  
Date: 5 November 2026  
Licence: [CC BY 4.0](LICENSE)  
Polish version (original): [wyszukiwanie-agentowe-strony-i-sklepy.md](wyszukiwanie-agentowe-strony-i-sklepy.md)  
Blog version (Polish): <https://www.ecopowerpolska.pl/blog/wyszukiwanie-agentowe-strony-i-sklepy/>  
Wikipedia entry (Polish): <https://pl.wikipedia.org/wiki/Wyszukiwanie_agentowe>

A technical document for people who build or maintain websites and online stores. Numbers in brackets, e.g. (17), refer to the source list in section 9. Raw measurement results are in [`pomiary/`](pomiary/) (Polish for "measurements"), the check script in [`skrypty/`](skrypty/) ("scripts"), sample files in [`przyklady/`](przyklady/) ("examples").

## 0. Summary

"Agent readiness" of a website is in practice three different goals: visibility in AI search, operation of the site by a browser agent, and purchases through protocols; each has different requirements and a different measure. For AI Overviews and AI Mode, Google's documentation sets no requirements beyond normal indexing and snippet eligibility, and it does not require separate files for AI (17). A browser agent relies on the same things as assistive technology, that is the accessibility tree, labels and a stable layout; Lighthouse checks this in the experimental Agentic Browsing category (15). llms.txt, ARD, WebMCP, Web Bot Auth and Content-Signal are proposals, drafts or declarations without technical enforcement, and a passed audit does not mean that any agent uses them. This document describes the layers, the methodology and the results of measuring four websites on 5 November 2026, a script for checking the signals, and a checklist for a website and a store.

## 1. Three goals, not one "agent readiness"

Three things are mixed up under the label "agentic search". Files and manifests from one column do not improve results in another, so it is worth separating them before the first code change.

1. **Visibility in AI search** (AI Overviews, AI Mode, ChatGPT Search). An AI system fetches the page, summarises it and cites it. Google writes that the page must be indexed and eligible to be shown with a snippet, and that there are no additional technical requirements (17). The GEO (Generative Engine Optimization) paper measured up to 40% higher visibility in generative engine responses, with method effectiveness depending on the domain (28). That is an experimental result on a benchmark, not a promise for a particular website.
2. **Operation of the site by a browser agent** (ChatGPT agent, Comet, Claude in Chrome). The agent opens the page, reads it and clicks: it fills in a form, picks a time slot, adds a product to the cart. What matters is whether interactive elements have names and labels, whether the layout does not jump, and whether the form works (15).
3. **Purchases through protocols** (UCP, ACP, with WebMCP and ARD in the background). The agent does not click through the interface; it talks to the merchant's system through defined calls (7, 8).

| Goal | What works today | What is a draft or proposal | What measures it |
|---|---|---|---|
| Visibility in AI search | indexing, content available as text, structured data matching visible content, up-to-date Merchant Center and Business Profile data (17) | llms.txt (20); Google does not require it (17), and Google's John Mueller says AI systems do not use it (18, 19) | Search Console: impressions in generative AI features (25); GA4: "AI Assistant" channel (26) |
| Operation by a browser agent | accessibility tree, labels, stable layout, a working form (15) | WebMCP (22), Web Bot Auth (23) | Lighthouse, `agentic-browsing` category, lab measurement (15); your own task runs in an agent |
| Purchases through protocols | ACP: purchases in ChatGPT in the US since 29 September 2025 (8); hotel bookings completed in AI Mode in the US since 27 August 2026 (6); product feed in Merchant Center (7) | UCP with payment in AI Mode announced as "soon" (7); ARD v0.91 "Proposal" (21) | Lighthouse only checks that an ARD manifest conforms to the schema (16), not that it is used |

## 2. Layers an agent reads

### 2.1 Accessibility tree

The accessibility tree is the structure the browser builds from the DOM for assistive technology: every element has a role, a name and a state. In the Agentic Browsing category Lighthouse checks names and labels of interactive elements, the correctness of the tree and element visibility (15). In the report this is the `agent-accessibility-tree` audit ("Accessibility tree is well-formed"), whose description says that a well-formed tree helps agents navigate and interact with the page. The audit is binary.

Practical consequence: an icon-only button without `aria-label`, a field without `<label>` and a custom clickable element without a role are as unreadable to an agent as they are to a screen reader.

### 2.2 Prerendered HTML

Google recommends that important content be available in textual form, and the page is subject to the normal search technical requirements (17). The simplest route is HTML generated at build time (SSG) or on the server (SSR): content, navigation and forms are in the HTTP response before any script runs. The four websites measured here are static HTML built with Astro.

A browser agent runs in a browser, so it does execute JavaScript. Prerendering is therefore not a condition for agent operation; it simplifies indexing and shortens the time to first content.

### 2.3 JSON-LD: three levels of certainty

1. **Search engines and rich results: confirmed.** Google requires structured data to match the visible text of the page and writes that no special schema.org type is needed for AI features (17).
2. **Some AI systems: possible.** Microsoft's NLWeb builds conversational interfaces on Schema.org data, and each instance acts as an MCP server (27). The ARD v0.91 specification describes entries as JSON-LD nodes and lists in-page JSON-LD markup as one way to publish entries (21). Google is adding dozens of new product attributes to Merchant Center for agentic commerce (7).
3. **Browser agent: no guarantee.** None of the sources of this document states that a browser agent reads JSON-LD. Design as if the agent sees only the page and its accessibility tree.

Conclusion: JSON-LD describes what is on the page, with types that actually fit. Artificial types or offers without coverage in the content break the condition from level 1 and buy nothing at level 3.

### 2.4 llms.txt

llms.txt is a proposal by Jeremy Howard of 3 September 2024: a Markdown file in the root directory with a mandatory H1 heading, a summary in a blockquote and H2 sections with lists of links (20). The Lighthouse `llms-txt` audit checks whether the file is Markdown with at least one H1; it does not assess the content.

Google's position runs on two tracks. The Search Central documentation says: "You don't need to create new machine readable files, AI text files, or markup to appear in these features" (17); it does not use the word llms.txt. In June 2025 John Mueller wrote that no AI system currently uses llms.txt and that this is visible in server logs (18), and in June 2026 he called the file "purely speculative for now" (19). At the same time Lighthouse, a tool from the same company, has an audit for it (15), and the Cloudflare scanner skips it by default (12).

A fair wording: llms.txt may be a useful additional content index for systems that support it; it has no confirmed effect on visibility in Google or in ChatGPT. Sample file: [`przyklady/ecopowerpolska.pl-llms.txt`](przyklady/ecopowerpolska.pl-llms.txt).

### 2.5 robots.txt and Content-Signal

The Content Signals Policy (Cloudflare, 24 September 2025, policy licensed CC0) adds a line with three signals to robots.txt (13):

- `search`: building a search index and showing results with links and snippets, without AI summaries,
- `ai-input`: using content as model input (RAG, grounding, AI answers),
- `ai-train`: training and fine-tuning models.

Status: it is a declaration of preferences, not a protection. Cloudflare writes that the signals "express preferences; they are not technical countermeasures against scraping", that some companies may ignore them, and that they are best combined with WAF rules and bot management (13). The same policy text frames restrictions as an express reservation of rights under Article 4 of the EU copyright directive and as a condition of access to the website (13). So the line is not meaningless, but it does not block a bot technically. Cloudflare's managed robots.txt with these signals covers more than 3.8 million domains (13).

A group from the robots.txt of the measured site www.ecopowerpolska.pl (full file: [`przyklady/ecopowerpolska.pl-robots.txt`](przyklady/ecopowerpolska.pl-robots.txt)):

```text
User-agent: GPTBot
Allow: /
Disallow: /admin/
Content-Signal: search=yes, ai-input=yes, ai-train=yes
```

In this file the `Content-Signal` line sits under each of the ten `User-agent` groups, not only under `*`, so that a crawler with its own group also receives it. The `yes` values are the site owner's decision, not a recommendation.

### 2.6 Web Bot Auth

Web Bot Auth is an individual IETF draft by Thibault Meunier (Cloudflare) and Sandor Major (Google): an automated client signs its requests with HTTP Message Signatures, and the server verifies the signature and the bot's identity (23). Version 05 of 2 March 2026 has expired and was replaced by `draft-meunier-webbotauth-httpsig-protocol`. The `cloudflare/web-bot-auth` repository (Apache-2.0) implements the draft as well as RFC 9421 and RFC 7638; the code is described as unaudited (23). Cloudflare places Web Bot Auth in the "Bot Access Control" dimension of its readiness assessment (12).

### 2.7 Markdown negotiation

On an `Accept: text/markdown` request header the server returns a Markdown version instead of HTML. According to Cloudflare this can cut token usage "up to 80% in some cases", and on Cloudflare's documentation an agent used on average 31% fewer tokens and worked 66% faster (12). In a sample of the 200,000 most visited domains, 3.9% of sites pass the negotiation check (12). None of the four websites measured here supports it (section 5.3).

### 2.8 ARD (Agentic Resource Discovery)

**Specification.** "Agentic Resource Discovery Specification", version v0.91, status "Proposal", dated 26 August 2026; authors: Junjie Bu (Google), R.V. Guha, Shaun Smith (Hugging Face) (21). The text warns that the format may change. It is developed by a working group with participants from Microsoft, Google, Hugging Face, GoDaddy and others; licence Apache 2.0; the `ards-project/ard-spec` repository has no releases (21). ARD describes how to publish and discover agentic resources (MCP servers, A2A agents, skills), and version 0.91 describes entries as JSON-LD nodes.

**Discovery.** The specification lists several ways to publish entries: a file at `/.well-known/ard.json`, JSON-LD markup in a page, an `Agentmap:` directive in robots.txt, `<link rel="ard">` in `<head>`, and DNS records (21). A consumer resolving a domain "MUST fetch /.well-known/ard.json" and "MUST honour a rel="ard" link"; it may additionally consult the older `ai-catalog` names (21). Lighthouse looks for the manifest in this order (16):

1. the `Agentmap:` directive in robots.txt,
2. `<link rel="ard" href="...">` in the HTML,
3. the HTTP header `Link: <...>; rel="ard"`,
4. `/.well-known/ard.json`.

If none of these works, the audit checks the legacy paths (`rel="ai-catalog"`, `/.well-known/ai-catalog.json`) and raises a warning (16).

**What the `ard-schema` audit checks.** Validation is done by a JavaScript port of the ARD v0.91 conformance suite (16); in the PageSpeed JSON this shows up in `lighthouseResult.environment.credits.ard` = `0.91 (f073b1e)`. Result: 1 with no errors or warnings, 0.9 with warnings, 0 on a conformance error or when an advertised manifest location fails to load. No manifest gives "Not applicable" and, according to the documentation, does not affect the score (16). The `specVersion` field and other extra top-level fields do not affect the score; good practice is 2-5 `representativeQueries` per entry, because registries build their search index from them (16).

**What the audit does not say.** It checks that the file conforms to the schema, not whether anyone reads it. None of the sources of this document contains a statement that ChatGPT, Gemini, Google Search, Claude or Perplexity use ARD manifests. Treat ARD as an experiment and deploy it when you have a concrete use case.

Excerpt from the measured site's manifest (full file, 11 entries: [`przyklady/ecopowerpolska.pl-ard.json`](przyklady/ecopowerpolska.pl-ard.json)):

```json
{
  "identifier": "urn:air:ecopowerpolska.pl:usluga:strony-internetowe",
  "displayName": "Tworzenie stron internetowych dla firm w Warszawie",
  "type": "application/ld+json",
  "data": {
    "@context": "https://schema.org",
    "@type": "Service",
    "url": "https://www.ecopowerpolska.pl/strony-internetowe-warszawa/",
    "provider": { "@id": "https://www.ecopowerpolska.pl/#organizacja" }
  },
  "representativeQueries": [
    "tworzenie stron internetowych Warszawa",
    "strona internetowa dla firmy",
    "ile trwa zrobienie strony internetowej"
  ]
}
```

The manifest declares `"specVersion": "1.0"`, and the audit (validator 0.91) passes it; according to (16) this field is not scored. On all four measured sites the manifest is discovered only through `/.well-known/ard.json`: there is no `Agentmap:`, no `<link rel="ard">` and no `Link` header (section 6).

### 2.9 WebMCP

WebMCP is a "Draft Community Group Report" of the W3C Web Machine Learning group, in the version of 2 November 2026; the text states that it is not a W3C Standard nor on the W3C Standards Track (22). Editors: Brandon Walderman and Samuel Dallstream (Microsoft), Khushal Sagar and Dominic Farolino (Google). The API lets a web page expose JavaScript-based tools to agents (22).

In the IDL of the current draft the `ModelContext` interface is available as `document.modelContext` (secure context only) and has the methods `registerTool()`, `getTools()` and `executeTool()`. A tool (`ModelContextTool`) has the required fields `name`, `description` and `execute`, and the optional `inputSchema`, `outputSchema` and `annotations`; the annotations dictionary includes `readOnlyHint`, `consequentialHint` and `untrustedContentHint` (22). Earlier texts about WebMCP used a different object name, so check the current draft before implementing.

Lighthouse has three WebMCP audits (`webmcp-form-coverage`, `webmcp-registered-tools`, `webmcp-schema-validity`) with weight 0; their results require registering for the WebMCP origin trial (15). Mueller wrote that he likes the WebMCP approach (19). One example library is Will Huang's AgentReady.js (MIT): a single `<script>` tag exposes semantic HTML as WebMCP tools and leaves purchases and form submissions to human approval (29).

## 3. State of agents in 2026

### Google

- **Restaurant tables.** The feature launched on 21 August 2025 for AI Ultra subscribers in the US, as a Labs experiment: AI Mode searches several platforms (OpenTable, Resy, Tock and others), shows available slots and sends the user to the booking page, where the user completes the booking (1). Under the hood it uses Project Mariner browsing, the Knowledge Graph and Google Maps (2). In April 2026 the feature reached eight new markets (Australia, Canada, Hong Kong, India, New Zealand, Singapore, South Africa, the UK) and works in AI Mode without a Labs opt-in (3). Poland is not on that list.
- **Event tickets and beauty/wellness appointments.** As of November 2025: Labs, Google AI Pro and Ultra subscribers, US, English; the user completes the transaction on the provider's site (4).
- **Hotels.** Since 27 August 2026, in the US and in English, AI Mode lets the user complete a hotel booking in Google ("Continue on Google", payment with Google Pay); the hotel or booking platform remains the merchant of record and handles customer service. Partners include Booking.com, Expedia, Hilton, IHG and Marriott (6). Here Google's agent does complete the transaction, so the statement "the agent always hands over to the partner's site" is out of date.
- **Announcements at Google I/O 2026** (19 May 2026): agentic booking is to cover local services and experiences, including home repair, beauty and pet care, with links to finish the booking with the provider of the user's choice; Google is also to call businesses on the user's behalf. Rollout was announced for everyone in the US "this summer" (5).

### OpenAI: ChatGPT agent

Since 17 July 2025 ChatGPT agent combines clicking through websites (previously Operator) with synthesising information from many sites (previously Deep Research). OpenAI disabled the agent's memory over concerns about data exfiltration through prompt injection, and TechCrunch describes agents' real-world performance as fragile (9).

### Perplexity Comet

Comet is a browser with an assistant in a side panel that sees the open page and can act on it. In TechCrunch's test it handled simple tasks, but when booking parking it entered wrong dates; it also requires broad access to the user's account (10).

### Claude in Chrome

Anthropic tested the extension on 123 test cases across 29 attack scenarios. The prompt injection success rate without mitigations was 23.6%, and 11.2% with mitigations in autonomous mode; on four browser-specific attacks it dropped from 35.7% to 0%. The launch in August 2025 was a pilot for 1,000 Max plan users (11).

### Bot traffic

Cloudflare Radar for 1 January to 2 December 2025: AI bots accounted on average for 4.2% of HTML page requests, Googlebot for 4.5%, human traffic for 47%. The crawl-to-refer ratio reached 500,000:1 for Anthropic, at most 3,700:1 for OpenAI, and Perplexity was below 200:1 from September. The ChatGPT-User bot, which acts on a user's request, peaked at 16 times its level at the start of the year (14).

### Prompt injection is a different problem from page semantics

Page readability and agent robustness are two separate axes. Semantic HTML, labels and structured data help an agent understand the page, but they do not protect it from instructions injected into the content: the figures in (11) concern defences on the agent side (model, permissions, operating mode), not the construction of the pages visited. On the website side, sensible mechanisms are those that limit the consequences: human confirmation for purchases and form submissions (29), WebMCP tool annotations (22) and control over who can put content on the page (comments, reviews, publicly displayed form fields).

## 4. Measurement methodology

**Tool.** PageSpeed Insights API v5, Lighthouse 13.6.0 (field `lighthouseResult.lighthouseVersion`). One request per URL and strategy:

```bash
curl "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://studioagat.pl/&category=agentic-browsing&category=performance&category=accessibility&category=best-practices&category=seo&strategy=mobile&key=$KEY"
```

The `agentic-browsing` category must be requested explicitly with the `category` parameter; in the response it has `scoreDisplayMode` = `fraction`, i.e. a "passed/scored" result rather than 0-100.

**Objects.** The home pages of www.ecopowerpolska.pl, studioagat.pl, pan-stolarz.pl and nadihome.pl, each with the `mobile` and `desktop` strategy: 8 measurements, all HTTP 200.

**Time.** Field `lighthouseResult.fetchTime`: from 2026-11-05T11:37:59.434Z to 2026-11-05T11:38:00.811Z (per-file table in [`pomiary/README.md`](pomiary/README.md)).

**Conditions.** Google's lab, headless Chrome 153 (`environment.hostUserAgent`); mobile emulates a moto g power (2022) with Android 11, desktop a browser on macOS (`environment.networkUserAgent`); `configSettings.locale` = `en-US`. One run per combination. The Chrome documentation requires Chrome 150 or later for this category (15).

**Field data.** The `loadingExperience` object contains only `initial_url`, without metrics: for these URLs the API returned no data from the CrUX report. All CLS, LCP and other values in this document are therefore lab values from a single run.

**Variability.** The performance score varies between runs. The same site studioagat.pl, mobile strategy: the API at 11:37:59.957Z returned 98, while the report in the pagespeed.web.dev interface at 12:38:01 Polish time (11:38:01 UTC) returned 100. A 2-point difference about a second apart is measurement noise, not a change on the site.

**Historical screenshots.** Two reports from the pagespeed.web.dev interface for https://studioagat.pl/, "Mobile" view: 14 October 2026, 18:54:42 (the site was still on WordPress) and 5 November 2026, 12:38:01 (after the move to Astro on 16 October 2026). These are two versions of one website: the technology changed, but so did the template, assets, images and optimisation. It is fair to say that this migration improved this site's results; it is not fair to conclude that Astro as a technology gives better agent readiness. The 14 October screenshot does not show the Lighthouse version or the list of audits.

**Two scales.** In October the Agentic Browsing category showed 2/3 for this site, in November 4/4. These are different sets of audits: the category is "still under development and subject to change" (category description in the JSON), and the denominator also depends on the site, because a missing ARD manifest gives "Not applicable" and is not counted (16). 2/3 and 4/4 are not comparable.

**Category audits** (from `lighthouseResult.categories["agentic-browsing"].auditRefs`, identical in all 8 files):

| Audit id | Group | Weight | Mode | What it checks |
|---|---|---|---|---|
| `agent-accessibility-tree` | `agent-accessibility` | 1 | binary | the accessibility tree is well-formed |
| `cumulative-layout-shift` | none (acronym CLS) | 1 | numeric | layout shifts within the viewport |
| `llms-txt` | `agent-discoverability` | 1 | binary | llms.txt is Markdown with at least one H1 |
| `ard-schema` | `agent-discoverability` | 1 | binary | the ARD manifest conforms to the v0.91 schema |
| `webmcp-form-coverage` | `webmcp` | 0 | notApplicable | WebMCP annotations on forms |
| `webmcp-registered-tools` | `webmcp` | 0 | notApplicable | list of registered WebMCP tools |
| `webmcp-schema-validity` | `webmcp` | 0 | notApplicable | validity of WebMCP tool schemas |

**What 4/4 is not.** The Chrome documentation describes the category's aim as gathering data and providing actionable signals "rather than a definitive ranking" (15). Lighthouse runs deterministic technical audits; it does not run ChatGPT, Gemini, Comet or Claude and does not measure whether they complete a task. 4/4 is an audit of accessibility, stability and discoverability, not a certificate or a ranking position.

## 5. Results

### 5.1 PageSpeed Insights, 5 November 2026

| Website | Strategy | Performance | Accessibility | Best practices | SEO | Agentic Browsing |
|---|---|---|---|---|---|---|
| www.ecopowerpolska.pl | mobile | 99 | 100 | 100 | 100 | 4/4 |
| www.ecopowerpolska.pl | desktop | 100 | 100 | 100 | 100 | 4/4 |
| studioagat.pl | mobile | 98 | 100 | 100 | 100 | 4/4 |
| studioagat.pl | desktop | 100 | 100 | 100 | 100 | 4/4 |
| pan-stolarz.pl | mobile | 99 | 100 | 100 | 100 | 4/4 |
| pan-stolarz.pl | desktop | 100 | 100 | 100 | 100 | 4/4 |
| nadihome.pl | mobile | 99 | 100 | 100 | 100 | 4/4 |
| nadihome.pl | desktop | 100 | 100 | 100 | 100 | 4/4 |

Lab metrics (`audits[*].displayValue`):

| Website | Strategy | FCP | LCP | TBT | CLS | Speed Index |
|---|---|---|---|---|---|---|
| www.ecopowerpolska.pl | mobile | 1.0 s | 1.0 s | 0 ms | 0 | 3.6 s |
| www.ecopowerpolska.pl | desktop | 0.3 s | 0.3 s | 0 ms | 0 | 1.0 s |
| studioagat.pl | mobile | 1.0 s | 1.4 s | 0 ms | 0 | 4.0 s |
| studioagat.pl | desktop | 0.3 s | 0.4 s | 0 ms | 0 | 0.3 s |
| pan-stolarz.pl | mobile | 1.0 s | 1.0 s | 10 ms | 0 | 3.7 s |
| pan-stolarz.pl | desktop | 0.3 s | 0.3 s | 0 ms | 0 | 0.4 s |
| nadihome.pl | mobile | 1.0 s | 1.0 s | 0 ms | 0 | 3.6 s |
| nadihome.pl | desktop | 0.3 s | 0.5 s | 0 ms | 0.001 | 0.5 s |

In all eight measurements the four scored audits pass, and the three WebMCP audits are "Not applicable" because the sites do not implement WebMCP.

![Lighthouse report for www.ecopowerpolska.pl, desktop: Agentic Browsing category 4/4, four passed audits and three WebMCP audits not applicable](obrazy/wyszukiwanie-agentowe-lighthouse-ecopowerpolska-agentic.png)  
*Lighthouse report from the file `pomiary/psi-www.ecopowerpolska.pl-desktop.json`, displayed in Lighthouse Viewer.*

### 5.2 studioagat.pl: two versions of one website

| pagespeed.web.dev report, Mobile | 14.10.2026, WordPress | 5.11.2026, Astro |
|---|---|---|
| Performance | 52 | 100 |
| Accessibility | 96 | 100 |
| Best practices | 100 | 100 |
| SEO | 100 | 100 |
| Agentic browsing | 2/3 | 4/4 |
| FCP | 4.2 s | 0.9 s |
| LCP | 8.9 s | 1.4 s |
| TBT | 200 ms | 0 ms |
| CLS | 0.196 | 0 |

![PageSpeed Insights report for studioagat.pl of 14 October 2026, mobile: performance 52, agentic browsing 2/3](obrazy/wyszukiwanie-agentowe-psi-studioagat-przed-2026-10-14.png)  
*14 October 2026, 18:54:42: the WordPress version (report interface in Polish).*

![PageSpeed Insights report for studioagat.pl of 5 November 2026, mobile: four scores of 100, agentic browsing 4/4](obrazy/wyszukiwanie-agentowe-psi-studioagat-po-2026-11-05.png)  
*5 November 2026, 12:38:01: the Astro version (report interface in Polish).*

The limits of this comparison are described in section 4: two single lab runs, different sets of agentic audits, many factors changed at once.

### 5.3 Signals read with curl, 5 November 2026 (around 11:43 UTC)

| Signal | www.ecopowerpolska.pl | studioagat.pl | pan-stolarz.pl | nadihome.pl |
|---|---|---|---|---|
| Server (`server`) | GitHub.com | cloudflare | Apache | cloudflare |
| `Content-Signal` lines in robots.txt | 10 | 22 | 2 | 22 |
| Value | `search=yes, ai-input=yes, ai-train=yes` | same | same | same |
| `/llms.txt` | 200 | 200 | 200 | 200 |
| `/llms-full.txt` | 404 | 404 | 404 | 200 |
| `/.well-known/ard.json` | 200 | 200 | 200 | 200 |
| `Accept: text/markdown` on `/` | text/html | text/html | text/html | text/html |
| `link`, `x-robots-tag`, `content-signal` headers on `/` | none | none | none | none |
| JSON-LD types on the home page | Organization+LocalBusiness, WebSite, OfferCatalog, 11 × Service with Offer, ItemList | LocalBusiness+HomeAndConstructionBusiness, Brand, OfferCatalog, 5 × Service with Offer, WebSite | LocalBusiness+HomeAndConstructionBusiness, OfferCatalog, 4 × Service with Offer, WebSite | LocalBusiness+HomeAndConstructionBusiness, WebSite, no Service |

On pan-stolarz.pl the two `Content-Signal` lines sit in groups that combine several `User-agent` lines. Two weak points, stated plainly: only nadihome.pl has full content in `llms-full.txt`, and none of the four sites supports Markdown negotiation. Raw responses (headers and bodies) are in [`pomiary/sygnaly/`](pomiary/sygnaly/), the summary in [`pomiary/sygnaly-podsumowanie.txt`](pomiary/sygnaly-podsumowanie.txt).

## 6. Checking the signals

Basic commands (replace the domain):

```bash
curl -s https://example.com/robots.txt | grep -i '^content-signal'
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' https://example.com/llms.txt
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' https://example.com/llms-full.txt
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' https://example.com/.well-known/ard.json
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -H 'Accept: text/markdown' https://example.com/
curl -s https://example.com/ | grep -o '"@type":"[^"]*"' | sort | uniq -c
```

The last command misses types written as an array (`"@type":["Organization","LocalBusiness"]`). The script [`skrypty/sprawdz-sygnaly.sh`](skrypty/sprawdz-sygnaly.sh) does all of this at once: it checks the four ARD discovery paths in Lighthouse order, counts `application/ld+json` blocks, lists types (including arrays) and, when `jq` is available, checks that every block is valid JSON. It needs only bash, curl and coreutils. Its output labels are in Polish; sample output is in [`README.md`](README.md).

## 7. Checklist

### Website

1. **Content in HTML.** Important content is in the HTTP response as text, and the page is indexable (17). Check: `curl` the URL and look for key sentences in the response.
2. **Accessibility tree.** Every interactive element has a role and an accessible name, every field has a label. Check: the `agent-accessibility-tree` audit and the accessibility category in Lighthouse (15).
3. **An accessible, working form.** A browser agent executes JavaScript, so a form that works without JS is not a requirement. Our design choice is a plain `<form action>` that the script only enhances; it is not a condition of agent readiness. Check: submit the form with a mouse, with the keyboard and through an agent.
4. **Stable layout.** The "good" threshold is CLS ≤ 0.1 at the 75th percentile of page loads, separately for mobile and desktop (24). That is a field-data measure; a single Lighthouse run is only an indication. CLS of 0 is not a requirement.
5. **JSON-LD consistent with the content.** Types that describe what is visible on the page; no artificial types and no offers without coverage (17). Check: `jq` on each block and comparison with the visible text.
6. **A bot decision in robots.txt.** Explicit groups for the bots you want to allow or block; `Content-Signal` under each group as a declaration of preferences. If the preference is to be enforced, you need WAF rules and bot management (13).
7. **llms.txt optional.** H1, summary, sections with links (20). No expectations regarding visibility in Google and ChatGPT (17, 18, 19).
8. **ARD as an experiment.** Only with a concrete use case (for example you publish an MCP server or an A2A agent). File at `/.well-known/ard.json` or referenced via `rel="ard"`, 2-5 `representativeQueries` per entry, no `ai-catalog` names (16, 21).
9. **Watch WebMCP.** A community group draft; the audits require an origin trial (15, 22). Production deployment makes sense only once the agent you care about supports it.
10. **Markdown negotiation optional.** Token savings on the agent side (12); adoption at 3.9% of domains.

### Store

1. **Today: feed and data.** A complete Merchant Center feed with prices and availability matching the store; up-to-date data in Merchant Center and Business Profile (17). Google is extending Merchant Center with dozens of attributes for agentic commerce (7).
2. **Today: Product and Offer in JSON-LD** consistent with the visible price and availability (17).
3. **Today: a cart and checkout a browser agent can operate.** The same condition as in items 2-4 for the website.
4. **Later: protocols.** UCP is an open standard for the whole purchase journey and works with A2A, AP2 and MCP; the store remains the seller; payment in AI Mode via Google Pay is announced for the US "soon" (7). ACP (Stripe and OpenAI): the merchant integrates once, and a store without Stripe can use its own payment provider; a Shared Payment Token is valid only for one merchant and the amount of one cart, without exposing card details (8). Both protocols launched in the US; integration makes sense once your store platform or payment provider offers it in your market.
5. **Human confirmation.** For purchases by a browser agent, leave the final step to the user's approval (29).

## 8. What to measure after deployment

- **Search Console.** Since 3 June 2026 a report shows impressions of the site's URLs in generative AI features in Search and Discover (e.g. AI Overviews, AI Mode); since 31 August 2026 for all websites worldwide (25). The post announcing the report talks about impressions, not clicks. AI Overviews and AI Mode data are also counted in the regular Performance report, "Web" search type (17).
- **GA4.** The default "AI Assistant" channel covers visits from sources such as ChatGPT, Gemini, Deepseek, Copilot and Grok; it does not cover AI Overviews and AI Mode (26). Traffic without a `Referer` header (apps, copied links) lands in the Direct channel (26).
- **Citations.** None of these tools shows whether, or how often, ChatGPT or Perplexity cites your site.
- **Server logs.** Requests from AI bots (e.g. GPTBot, ChatGPT-User, ClaudeBot, PerplexityBot) and fetches of `/llms.txt` are visible in the logs; Mueller also points to logs as evidence (18).
- **Agent tasks.** A short list of tasks (sending an enquiry, picking a slot, adding a product to the cart), run periodically in a browser agent, with a record of task, date, agent, result and where it went wrong.
- **Lighthouse after every change.** Keep the raw JSON as in `pomiary/`, because the agentic category changes, and a score without the Lighthouse version and date cannot be compared.

## 9. Sources

Pages without a publication date carry the last-updated date from their footer or the access date: 5 November 2026.

1. Robby Stein (Google), [AI Mode: agentic and personalized](https://blog.google/products-and-platforms/products/search/ai-mode-agentic-personalized/), 21 August 2025.
2. 9to5Google, [Google AI Mode in new countries, agentic features](https://9to5google.com/2025/08/21/google-ai-mode-countries-agentic/), 21 August 2025.
3. Abner Li (9to5Google), [Google AI Mode redesign](https://9to5google.com/2026/04/10/google-ai-mode-redesign/), 10 April 2026.
4. Matt G. Southern (Search Engine Journal), [Google AI Mode starts rolling out agentic booking in Labs](https://www.searchenginejournal.com/google-ai-mode-starts-rolling-out-agentic-booking-in-labs/559973/), 4 November 2025.
5. Elizabeth Reid (Google), [Search at I/O 2026](https://blog.google/products-and-platforms/products/search/search-io-2026/), 19 May 2026.
6. James Byers (Google), [Book travel in AI Mode](https://blog.google/products-and-platforms/products/search/book-travel-ai-mode/), 27 August 2026; Luís Rijo (PPC Land), [Google AI Mode completes hotel bookings with 10 partners](https://ppc.land/google-ai-mode-completes-hotel-bookings-with-10-partners-in-us-rollout/), 28 August 2026.
7. Vidhya Srinivasan (Google), [Agentic commerce, AI tools and the Universal Commerce Protocol](https://blog.google/products/ads-commerce/agentic-commerce-ai-tools-protocol-retailers-platforms/), 11 January 2026.
8. Stripe, [Stripe and OpenAI: Instant Checkout and the Agentic Commerce Protocol](https://stripe.com/newsroom/news/stripe-openai-instant-checkout), 29 September 2025.
9. Maxwell Zeff (TechCrunch), [OpenAI launches a general purpose agent in ChatGPT](https://techcrunch.com/2025/07/17/openai-launches-a-general-purpose-agent-in-chatgpt/), 17 July 2025.
10. Maxwell Zeff (TechCrunch), [Perplexity launches Comet, an AI-powered web browser](https://techcrunch.com/2025/07/09/perplexity-launches-comet-an-ai-powered-web-browser/), 9 July 2025.
11. Anthropic, [Claude for Chrome](https://claude.com/blog/claude-for-chrome), 25 August 2025, updated 24 November and 18 December 2025.
12. Cloudflare, [Agent Readiness](https://blog.cloudflare.com/agent-readiness/), 17 April 2026, modified 15 July 2026.
13. Will Allen (Cloudflare), [Content Signals Policy](https://blog.cloudflare.com/content-signals-policy/), 24 September 2025.
14. Cloudflare, [Radar 2025 Year in Review](https://blog.cloudflare.com/radar-2025-year-in-review), data from 1 January to 2 December 2025, accessed 5 November 2026.
15. Chrome for Developers, [Lighthouse: Agentic Browsing scoring](https://developer.chrome.com/docs/lighthouse/agentic-browsing/scoring), last updated 5 May 2026.
16. Chrome for Developers, [Lighthouse: ARD manifest audit](https://developer.chrome.com/docs/lighthouse/agentic-browsing/ard), last updated 20 October 2026.
17. Google Search Central, [AI features and your website](https://developers.google.com/search/docs/appearance/ai-features), last updated 10 December 2025.
18. Barry Schwartz (Search Engine Roundtable), [Google: no AI system currently uses llms.txt](https://seroundtable.com/google-ai-llms-txt-39607.html), 18 June 2025 (John Mueller's post on Bluesky of 17 June 2025).
19. Roger Montti (Search Engine Journal), [Google says llms.txt is purely speculative for now](https://www.searchenginejournal.com/google-says-llms-txt-is-purely-speculative-for-now/577576/), 2 June 2026.
20. Jeremy Howard (Answer.AI), [llms.txt](https://llmstxt.org/), 3 September 2024; repository [AnswerDotAI/llms-txt](https://github.com/AnswerDotAI/llms-txt).
21. Junjie Bu, R.V. Guha, Shaun Smith, [Agentic Resource Discovery Specification v0.91](https://agenticresourcediscovery.org/spec/), 26 August 2026; [agenticresourcediscovery.org](https://agenticresourcediscovery.org/); repository [ards-project/ard-spec](https://github.com/ards-project/ard-spec).
22. Web Machine Learning Community Group (W3C), [WebMCP](https://webmachinelearning.github.io/webmcp/), Draft Community Group Report, 2 November 2026; repository [webmachinelearning/webmcp](https://github.com/webmachinelearning/webmcp).
23. Thibault Meunier, Sandor Major, [Web Bot Auth architecture](https://datatracker.ietf.org/doc/draft-meunier-web-bot-auth-architecture/), Internet-Draft, version 05, 2 March 2026; repository [cloudflare/web-bot-auth](https://github.com/cloudflare/web-bot-auth).
24. Milica Mihajlija, Philip Walton (web.dev), [Cumulative Layout Shift (CLS)](https://web.dev/articles/cls), accessed 5 November 2026.
25. Hillel Maoz, Moshe Samet (Google Search Central Blog), [Generative AI performance reports](https://developers.google.com/search/blog/2026/06/gen-ai-performance-reports), 3 June 2026.
26. Google, [Default channel group](https://support.google.com/analytics/answer/9756891), accessed 5 November 2026; Matt G. Southern (Search Engine Journal), [Google Analytics adds AI Assistant as default channel group](https://www.searchenginejournal.com/google-analytics-adds-ai-assistant-as-default-channel-group/574974/), 14 May 2026.
27. nlweb-ai (Microsoft), [NLWeb](https://github.com/nlweb-ai/NLWeb), announced 19 May 2025.
28. Pranjal Aggarwal, Vishvak Murahari, Tanmay Rajpurohit, Ashwin Kalyan, Karthik Narasimhan, Ameet Deshpande, [GEO: Generative Engine Optimization](https://arxiv.org/abs/2311.09735), KDD 2024; repository [GEO-optim/GEO](https://github.com/GEO-optim/GEO).
29. Will Huang, [AgentReady.js](https://github.com/doggy8088/agentready).

Licences of repositories and pages: [`ZRODLA.md`](ZRODLA.md).

## 10. About the author

<img src="obrazy/autor.jpg" alt="Piotr Czwarnowski, the author, wearing a head-mounted magnifier" width="120" height="120" align="left">

**Piotr Czwarnowski**, EcoPower Polska Sp. z o.o. The company builds and runs websites and online stores; the four measured websites are its projects.

<br clear="left">
