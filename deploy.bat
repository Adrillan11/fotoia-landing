@echo off
echo.
echo ========================================
echo   DEPLOY FotoIA - Cloudflare Pages
echo ========================================
echo.

:: 1. Limpa e recria a pasta dist
echo [1/4] Preparando arquivos...
if exist dist rmdir /s /q dist
mkdir dist
mkdir dist\assets

:: 2. Copia arquivos HTML
copy index_uma_v2.html dist\index.html >nul
copy politica-privacidade.html dist\ >nul
copy termos-uso.html dist\ >nul

:: 3. Copia imagens
xcopy assets\*.* dist\assets\ /q >nul

:: 4. Comprime imagens acima de 25MB com Python
echo [2/4] Verificando imagens...
py -c "
from PIL import Image
import os

assets_dir = 'dist/assets'
for f in os.listdir(assets_dir):
    path = os.path.join(assets_dir, f)
    if not os.path.isfile(path): continue
    size_mb = os.path.getsize(path) / (1024*1024)
    if size_mb > 20:
        print(f'  Comprimindo {f} ({size_mb:.1f}MB)...')
        img = Image.open(path)
        img.thumbnail((1800, 1800), Image.LANCZOS)
        ext = f.lower().split('.')[-1]
        fmt = 'JPEG' if ext in ['jpg','jpeg'] else 'PNG'
        img.save(path, format=fmt, optimize=True, quality=85)
        new_mb = os.path.getsize(path) / (1024*1024)
        print(f'  OK: {size_mb:.1f}MB -> {new_mb:.1f}MB')
" 2>&1

:: 5. Deploy no Cloudflare Pages
echo [3/4] Subindo para Cloudflare Pages...
npx wrangler pages deploy dist --project-name fotoia-landing --branch master --commit-dirty=true

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRO] Deploy falhou. Verifique a mensagem acima.
    pause
    exit /b 1
)

:: 6. Sobe no GitHub também
echo [4/4] Salvando no GitHub...
git add index_uma_v2.html politica-privacidade.html termos-uso.html assets\
git commit -m "update: deploy %date% %time%"
git push

echo.
echo ========================================
echo   DEPLOY CONCLUIDO COM SUCESSO!
echo   Site: https://fotoia-landing.pages.dev
echo ========================================
echo.
pause
