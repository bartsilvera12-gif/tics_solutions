# Arma la carpeta dist/ para subir a Hostinger.
#
#   powershell -ExecutionPolicy Bypass -File tools/construir-dist.ps1
#
# El proyecto no se compila: son archivos estaticos. "Construir" es juntar en
# un solo lugar lo que va al servidor web y dejar afuera lo que no, que es la
# parte facil de olvidarse a mano. Ya paso una vez: un despliegue publico la
# lista de schemas de la instancia compartida.
#
# Dos cosas cambian respecto del repositorio:
#
#   1. "Sitio Web.dc.html" se copia como index.html. El nombre original tiene
#      un espacio y una extension doble; en Apache anda igual con
#      DirectoryIndex, pero index.html no depende de ninguna configuracion.
#   2. El .htaccess se copia ajustando ese nombre, para que las dos versiones
#      no se separen con el tiempo: se edita el del repositorio y listo.

$ErrorActionPreference = "Stop"

$RAIZ = Split-Path -Parent $PSScriptRoot
$DIST = Join-Path $RAIZ "dist"
$SITIO = "Sitio Web.dc.html"

# Lo que va al servidor web.
$ARCHIVOS = @($SITIO, "support.js", "image-slot.js", "favicon.ico", "apple-touch-icon.png")
$CARPETAS = @("assets", "js", "admin")

# Lo que nunca va, este donde este.
$PROHIBIDOS = @("*.ps1", "*.pl", "*.sql", "*.md", ".env*", "*.thumbnail")

Write-Output "Armando $DIST"

if (Test-Path -LiteralPath $DIST) { Remove-Item -LiteralPath $DIST -Recurse -Force }
New-Item -ItemType Directory -Path $DIST -Force | Out-Null

# ---------- archivos sueltos ----------
foreach ($a in $ARCHIVOS) {
  $origen = Join-Path $RAIZ $a
  if (-not (Test-Path -LiteralPath $origen)) {
    Write-Output ("  FALTA  " + $a)
    continue
  }
  $destino = if ($a -eq $SITIO) { Join-Path $DIST "index.html" } else { Join-Path $DIST $a }
  Copy-Item -LiteralPath $origen -Destination $destino -Force
  $nombre = Split-Path $destino -Leaf
  Write-Output ("  {0,-24} {1:N0} KB" -f $nombre, ((Get-Item $destino).Length / 1KB))
}

# ---------- carpetas ----------
foreach ($c in $CARPETAS) {
  $origen = Join-Path $RAIZ $c
  if (-not (Test-Path -LiteralPath $origen)) { Write-Output ("  FALTA  " + $c); continue }
  Copy-Item -LiteralPath $origen -Destination (Join-Path $DIST $c) -Recurse -Force
}

# El .htaccess del panel viaja con la carpeta admin porque empieza con punto,
# y Copy-Item -Recurse no siempre lo arrastra.
$htAdmin = Join-Path $RAIZ "admin/.htaccess"
if (Test-Path -LiteralPath $htAdmin) {
  Copy-Item -LiteralPath $htAdmin -Destination (Join-Path $DIST "admin/.htaccess") -Force
}

# ---------- .htaccess de la raiz, apuntando a index.html ----------
$ht = Get-Content -LiteralPath (Join-Path $RAIZ ".htaccess") -Raw -Encoding UTF8
$ht = $ht.Replace('DirectoryIndex "Sitio Web.dc.html"', 'DirectoryIndex index.html')
$ht = $ht.Replace('/Sitio%20Web.dc.html', '/index.html')
[System.IO.File]::WriteAllText((Join-Path $DIST ".htaccess"), $ht, (New-Object System.Text.UTF8Encoding($false)))

# ---------- limpieza ----------
# Si alguna de las carpetas copiadas trae un script o un .md, sale de dist.
$borrados = 0
foreach ($p in $PROHIBIDOS) {
  Get-ChildItem -LiteralPath $DIST -Recurse -Force -Filter $p -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Force
    Write-Output ("  fuera: " + $_.FullName.Substring($DIST.Length + 1))
    $borrados++
  }
}

# ---------- control final ----------
Write-Output ""
$total = (Get-ChildItem -LiteralPath $DIST -Recurse -Force -File | Measure-Object -Property Length -Sum)
Write-Output ("Listo: {0} archivos, {1:N1} MB" -f $total.Count, ($total.Sum / 1MB))

# Lo que no tiene que estar, dicho en voz alta y no supuesto.
$fugas = @()
foreach ($n in @("supabase", "api", "uploads", "node_modules", ".git", "vercel.json", "package.json")) {
  if (Test-Path -LiteralPath (Join-Path $DIST $n)) { $fugas += $n }
}
if ($fugas.Count -gt 0) {
  Write-Output ("AVISO: quedo adentro lo que no debia -> " + ($fugas -join ", "))
} else {
  Write-Output "Sin supabase/, api/, uploads/ ni credenciales."
}

# El formulario de contacto necesita un servidor que ejecute algo, y Hostinger
# sirve estos archivos tal cual. Se avisa siempre, para que no se descubra
# cuando alguien no pueda escribir.
$sitio = Get-Content -LiteralPath (Join-Path $DIST "index.html") -Raw -Encoding UTF8
if ($sitio -match "url:\s*'/api/contact'") {
  Write-Output ""
  Write-Output "OJO: el formulario apunta a /api/contact, que en Hostinger no existe."
  Write-Output "     Esa ruta la resuelve la funcion de Vercel. Hay que apuntarla a la"
  Write-Output "     URL completa de Vercel (y habilitar CORS ahi) o dejar el sitio en Vercel."
}
