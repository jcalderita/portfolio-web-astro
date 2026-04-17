const FRIENDLY_BOTS = /Twitterbot|facebookexternalhit|LinkedInBot|Slackbot|Discordbot|TelegramBot|GPTBot|ChatGPT-User|ClaudeBot|Applebot|Googlebot|Bingbot|Google-Extended|PerplexityBot|anthropic-ai/i;

export default {
  async fetch(request, env) {
    const ua = request.headers.get("user-agent") || "";

    if (!FRIENDLY_BOTS.test(ua)) {
      return env.ASSETS.fetch(request);
    }

    let response = await env.ASSETS.fetch(request);

    // Follow redirects internally so bots always receive final HTML
    if (response.status >= 300 && response.status < 400) {
      const location = response.headers.get("location");
      if (location) {
        const redirectURL = new URL(location, request.url);
        response = await env.ASSETS.fetch(redirectURL.toString());
      }
    }

    const body = await response.arrayBuffer();
    const headers = new Headers(response.headers);
    headers.delete("content-encoding");
    headers.delete("content-length");
    headers.set("cache-control", "public, max-age=0, must-revalidate");

    return new Response(body, {
      status: response.status,
      headers,
    });
  },
};
