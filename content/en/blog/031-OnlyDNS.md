---
title: OnlyDNS
slug: only-dns
date: 2026-04-08
description: How disabling Cloudflare's proxy and switching to DNS-only mode solved in 5 minutes the La Liga block that had been taking down my site for months.
tags: Web, Cloudflare, DNS
cover: OnlyDNS
coverDescription: Comic-style illustration: Jorge wearing a dunce cap standing in front of a TV showing a football match with a 2-1 scoreline, while to his right a Mac mini with a monitor displays the text 'ONLY DNS' in large letters.
publish: true
---
---
## My Problem 🤔

In a [previous article](/blog/la-liga-thanks/) I talked about how <span class="high">La Liga</span> was blocking my website during matches. People trying to visit my portfolio and blog would find that the page simply would not load, just because my domain went through <span class="high">Cloudflare</span>'s infrastructure, and <span class="high">La Liga</span> was blocking entire IP ranges from <span class="high">Cloudflare</span> to crack down on illegal streams.

I knew it. I documented it. And I left it there.

For months I did nothing to fix it. Not out of laziness or because I thought it was complicated — but out of anger. My website worked perfectly fine; it was <span class="high">La Liga</span> that was applying indiscriminate blocks and making it unreachable. It was not my fault. So I stood my ground: I should not have to be the one to make a move.

So I did nothing. For months.

The thing is, I had <span class="high">Cloudflare</span>'s proxy enabled — the famous orange cloud. My site is hosted on <span class="high">Cloudflare Pages</span>, so everything lives within the <span class="high">Cloudflare</span> ecosystem. But with the proxy turned on, traffic goes through <span class="high">Cloudflare</span>'s CDN/proxy layer, which uses shared IP ranges. And those ranges are precisely the ones <span class="high">La Liga</span> was blocking.

---

## My Solution 🧩

The solution is to disable <span class="high">Cloudflare</span>'s proxy and switch to <span class="high">DNS-only</span> mode — the grey cloud.

With the orange cloud active, <span class="high">Cloudflare</span> acts as a "shopping mall": every visitor enters through the proxy/CDN door, which uses shared IP ranges alongside thousands of other sites. Those are the IPs that <span class="high">La Liga</span> blocks in bulk to stop illegal streams — and my website ends up as collateral damage.

With the grey cloud, <span class="high">Cloudflare</span> becomes just a "traffic director": it resolves the DNS and points directly to <span class="high">Cloudflare Pages</span>. My site is still hosted on <span class="high">Cloudflare</span>, but traffic arrives through the <span class="high">Pages</span> IP ranges — which are different from the proxy ones and are not on <span class="high">La Liga</span>'s blocklist.

The process in the <span class="high">Cloudflare</span> dashboard is straightforward:

1. Log into the <span class="high">Cloudflare</span> dashboard and navigate to **DNS > Records**.
2. Find the records pointing to the site — usually an **A** or **CNAME** record with the domain name.
3. In the **Proxy status** column, click the toggle with the orange cloud to turn it into a grey cloud (**DNS only**).
4. Save the changes.

The change propagates within minutes. From that point on, traffic arrives through a different route within <span class="high">Cloudflare</span> — one that is not in the crosshairs of <span class="high">La Liga</span>'s blocks.

Since my site is static and still hosted on <span class="high">Cloudflare Pages</span>, I notice virtually no difference in speed. I lose some proxy-layer features — like CDN-level firewall or caching at their edge nodes — but for a static portfolio website those benefits are marginal compared to the upside of having the site accessible to everyone during matches.

---

## My Result 🎯

My website now loads during <span class="high">La Liga</span> matches. Anyone trying to visit my portfolio or blog while the Champions League anthem is playing will no longer be greeted by a blank screen.

Five minutes. One click. Months of problems solved.

The lesson I take away is not technical — it is pragmatic. Whether I was right or not, my problem was either going to be solved by me or by no one. And I do believe I was right: my website should not have to be collateral damage from <span class="high">La Liga</span>'s blocks. Thanks, <span class="high">La Liga</span>.

**Keep coding, keep running** 🏃‍♂️

---
