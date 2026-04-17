const FRIENDLY_BOTS = /Twitterbot|facebookexternalhit|LinkedInBot|Slackbot|Discordbot|TelegramBot|GPTBot|ChatGPT-User|ClaudeBot|Applebot|Googlebot|Bingbot|Google-Extended|PerplexityBot|anthropic-ai/i;

export default {
  async fetch(request, env) {
    const ua = request.headers.get("user-agent") || "";

    if (!FRIENDLY_BOTS.test(ua)) {
      return env.ASSETS.fetch(request);
    }

    const response = await env.ASSETS.fetch(request);
    const body = await response.arrayBuffer();

    return new Response(body, {
      status: response.status,
      headers: {
        ...Object.fromEntries(response.headers),
        "cache-control": "public, max-age=0, must-revalidate",
      },
    });
  },
};
