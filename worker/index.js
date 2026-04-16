const SOCIAL_BOTS = /Twitterbot|facebookexternalhit|LinkedInBot|Slackbot|Discordbot|TelegramBot/i;

export default {
  async fetch(request, env) {
    const ua = request.headers.get("user-agent") || "";

    if (!SOCIAL_BOTS.test(ua)) {
      return env.ASSETS.fetch(request);
    }

    const response = await env.ASSETS.fetch(request);

    if (!response.ok || !response.headers.get("content-type")?.includes("text/html")) {
      return response;
    }

    const html = await response.text();
    return new Response(html, {
      status: 200,
      headers: {
        "content-type": "text/html; charset=utf-8",
        "cache-control": "public, max-age=0, must-revalidate",
      },
    });
  },
};
