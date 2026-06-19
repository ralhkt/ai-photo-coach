/**
 * Cloudflare Worker — forward Gemini vision requests from unsupported regions (e.g. Hong Kong).
 *
 * Deploy in Singapore or Taiwan:
 *   npx wrangler deploy tool/gemini_proxy_worker.mjs --name photo-coach-gemini-proxy
 *
 * Set secret:
 *   npx wrangler secret put GEMINI_API_KEY
 *
 * App config:
 *   --dart-define=VISION_PROVIDER=proxy
 *   --dart-define=GEMINI_PROXY_URL=https://photo-coach-gemini-proxy.<account>.workers.dev/gemini
 *
 * Optional auth (recommended for production):
 *   npx wrangler secret put PROXY_TOKEN
 *   --dart-define=GEMINI_PROXY_TOKEN=your_token
 */

const GEMINI_HOST = 'generativelanguage.googleapis.com';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);
    if (request.method !== 'POST' || url.pathname !== '/gemini') {
      return new Response('Not found', { status: 404, headers: corsHeaders });
    }

    if (env.PROXY_TOKEN) {
      const auth = request.headers.get('Authorization') ?? '';
      const token = auth.startsWith('Bearer ') ? auth.slice(7) : '';
      if (token !== env.PROXY_TOKEN) {
        return new Response('Unauthorized', { status: 401, headers: corsHeaders });
      }
    }

    // Prefer server secret; allow app header for dev/MVP when secret not set.
    const apiKey =
      env.GEMINI_API_KEY || request.headers.get('X-Gemini-Api-Key');
    if (!apiKey) {
      return new Response(
        'GEMINI_API_KEY not configured (set wrangler secret or X-Gemini-Api-Key header)',
        { status: 500, headers: corsHeaders },
      );
    }

    const model = url.searchParams.get('model') ?? 'gemini-2.0-flash';
    const target = new URL(
      `https://${GEMINI_HOST}/v1beta/models/${model}:generateContent`,
    );
    target.searchParams.set('key', apiKey);

    const upstream = await fetch(target, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: await request.text(),
    });

    return new Response(await upstream.text(), {
      status: upstream.status,
      headers: {
        ...corsHeaders,
        'Content-Type': upstream.headers.get('Content-Type') ?? 'application/json',
      },
    });
  },
};