/**
 * Cloudflare Pages Function — Proxy server-side GTM (Stape)
 * Rota: foto.asgrowhub.com/profissional/*  →  hsmzbjlo.sam.stape.io/profissional/*
 */
export async function onRequest(context) {
  const { request } = context;

  const url = new URL(request.url);
  url.hostname = 'hsmzbjlo.sam.stape.io';

  const newRequest = new Request(url.toString(), {
    method: request.method,
    headers: request.headers,
    body: request.method !== 'GET' && request.method !== 'HEAD'
      ? request.body
      : undefined,
  });

  const response = await fetch(newRequest);

  // Garante que cookies first-party sejam repassados corretamente
  const newHeaders = new Headers(response.headers);
  newHeaders.set('Access-Control-Allow-Origin', '*');

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: newHeaders,
  });
}
