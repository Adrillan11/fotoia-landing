/**
 * Cloudflare Pages Function — Proxy server-side GTM (Stape)
 * Rota: foto.asgrowhub.com/profissional/*  →  trawchqt.sam.stape.io/*
 * O prefixo /profissional é removido antes de encaminhar para a Stape,
 * pois a Stape está configurada com custom domain foto.asgrowhub.com (raiz).
 */
export async function onRequest(context) {
  const { request } = context;

  const url = new URL(request.url);

  // Acesso direto à raiz /profissional — redireciona para a home
  if (url.pathname === '/profissional' || url.pathname === '/profissional/') {
    return Response.redirect('https://foto.asgrowhub.com', 301);
  }

  // Remove o prefixo /profissional antes de encaminhar
  url.hostname = 'trawchqt.sam.stape.io';
  url.pathname = url.pathname.replace(/^\/profissional/, '') || '/';

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
