#!/usr/bin/perl
# Genera supabase/seeds/001_ticspy_contenido.sql leyendo el sitio.
#
# Se extrae en vez de transcribir: el copy tiene acentos, comillas tipograficas
# y entidades HTML, y una sola letra cambiada seria contenido inventado.
#
# Idempotente: todo va con ON CONFLICT sobre la clave natural (slug o route),
# asi que correrlo dos veces actualiza en vez de duplicar.

use strict;
use warnings;
use utf8;

my $SITIO = "C:/NEURA/tics_solutions/Sitio Web.dc.html";
# Con :raw el HTML entra como bytes y los literales de este script como
# caracteres. Mezclar las dos cosas y escribir a un handle sin capa deja el
# UTF-8 doble codificado: "Diseño" sale "DiseÃ±o". Se decodifica al leer y se
# codifica al escribir, y todo el camino intermedio es texto.
open(my $fh, '<:encoding(UTF-8)', $SITIO) or die "No pude abrir el sitio: $!";
my $html = do { local $/; <$fh> };
close $fh;

# ---------------------------------------------------------------- utilidades

sub sql {                      # texto -> literal SQL
  my ($t) = @_;
  return 'NULL' unless defined $t && length $t;
  $t =~ s/'/''/g;
  return "'$t'";
}

sub limpiar {                  # entidades y espacios sobrantes
  my ($t) = @_;
  return '' unless defined $t;
  $t =~ s/&mdash;/—/g;  $t =~ s/&ndash;/–/g;   $t =~ s/&times;/×/g;
  $t =~ s/&rsquo;/’/g;  $t =~ s/&nbsp;/ /g;    $t =~ s/&middot;/·/g;
  $t =~ s/&reg;/®/g;    $t =~ s/&iquest;/¿/g;  $t =~ s/&aacute;/á/g;
  $t =~ s/&eacute;/é/g; $t =~ s/&iacute;/í/g;  $t =~ s/&oacute;/ó/g;
  $t =~ s/&uacute;/ú/g; $t =~ s/&ntilde;/ñ/g;  $t =~ s/&amp;/&/g;
  $t =~ s/\s+/ /g;
  $t =~ s/^\s+|\s+$//g;
  return $t;
}

# Devuelve el bloque de un array del script de logica.
sub bloque {
  my ($nombre) = @_;
  return $1 if $html =~ /const \Q$nombre\E = \[(.*?)\n    \];/s;
  die "No encontre el array $nombre\n";
}

# Campos sueltos de un objeto literal de JS: clave: 'valor'
sub campos {
  my ($txt) = @_;
  my %c;
  while ($txt =~ /(\w+)\s*:\s*'((?:[^'\\]|\\.)*)'/g) {
    my ($k, $v) = ($1, $2);
    $v =~ s/\\'/'/g;
    $c{$k} = limpiar($v);
  }
  return %c;
}

# Parte un array en objetos { ... } de primer nivel.
sub objetos {
  my ($txt) = @_;
  my @out; my $prof = 0; my $act = '';
  for my $ch (split //, $txt) {
    $prof++ if $ch eq '{';
    $act .= $ch if $prof > 0;
    if ($ch eq '}') { $prof--; if ($prof == 0) { push @out, $act; $act = ''; } }
  }
  return @out;
}

my @SQL;
push @SQL, <<'CAB';
-- ============================================================================
--  Tic's Solutions - contenido inicial del CMS
--
--  GENERADO. No editar a mano: se regenera con
--  .claude/generar-seed.pl leyendo "Sitio Web.dc.html".
--
--  Todo el contenido sale del sitio tal como esta publicado hoy. No se
--  reescribio, resumio ni tradujo nada.
--
--  Idempotente: ON CONFLICT sobre slug o route, asi que correrlo de nuevo
--  actualiza en vez de duplicar.
-- ============================================================================

set search_path = ticspy, public;

CAB

# ------------------------------------------------------------------ 1. media
# Los 58 archivos del repositorio se registran como 'local': siguen
# sirviendose desde el sitio, no se mueven a Storage.

push @SQL, "-- ---------------------------------------------------------------- media\n";
my @assets;
my $dir = "C:/NEURA/tics_solutions/assets";
sub recorrer {
  my ($d, $rel) = @_;
  opendir(my $dh, $d) or return;
  for my $f (sort readdir $dh) {
    next if $f =~ /^\./;
    my $ruta = "$d/$f";
    my $r = $rel ? "$rel/$f" : $f;
    if (-d $ruta) { recorrer($ruta, $r); }
    else { push @assets, { rel => $r, size => -s $ruta }; }
  }
  closedir $dh;
}
recorrer($dir, '');

my %mime = (jpg=>'image/jpeg', jpeg=>'image/jpeg', png=>'image/png',
            webp=>'image/webp', gif=>'image/gif', mp4=>'video/mp4', svg=>'image/svg+xml');

for my $a (@assets) {
  my ($ext) = $a->{rel} =~ /\.(\w+)$/;
  my $m = $mime{lc($ext // '')} // 'application/octet-stream';
  # Absoluta desde la raiz: el panel vive en /admin y una ruta que empiece
  # con "./" resolveria a /admin/assets y daria 404.
  my $url = "/assets/" . $a->{rel};
  my ($nombre) = $a->{rel} =~ m{([^/]+)$};
  push @SQL, sprintf(
    "INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)\n" .
    "VALUES ('local', %s, %s, %s, %s, %d)\nON CONFLICT DO NOTHING;\n",
    sql("assets/" . $a->{rel}), sql($url), sql($nombre), sql($m), $a->{size});
}

# Ayuda para referenciar un asset por su ruta.
push @SQL, "\n";

# ------------------------------------------------------------------ 2. paginas
push @SQL, "-- -------------------------------------------------------------- paginas\n";
my @paginas = (
  ['inicio',             '/',                    'Inicio',                'Inicio',           1],
  ['nosotros',           '/nosotros',            'Nosotros',              'Nosotros',         2],
  ['servicios',          '/servicios',           'Servicios',             'Servicios',        3],
  ['partners',           '/partners',            'Partners',              'Soluciones',       4],
  ['unidad-aec',         '/unidad-aec',          'Unidad AEC',            'Unidad AEC',       5],
  ['ciberseguridad',     '/ciberseguridad',      'Ciberseguridad',        'Ciberseguridad',   6],
  ['zwcad',              '/zwcad',               'ZWCAD',                 'ZWCAD',            7],
  ['zw3d',               '/zw3d',                'ZW3D WuKong 2027',      'ZW3D',             8],
  ['aplitop',            '/aplitop',             'Aplitop',               'Aplitop',          9],
  ['cadprofi',           '/cadprofi',            'CADprofi',              'CADprofi',        10],
  ['arcserve',           '/arcserve',            'Arcserve',              'Arcserve',        11],
  ['novedades',          '/novedades',           'Novedades',             'Novedades',       12],
  ['contacto',           '/contacto',            'Contacto',              'Contactanos',     13],
  ['politicadeprivacidad','/politicadeprivacidad','Politica de privacidad','Privacidad',      14],
);
for my $p (@paginas) {
  my ($slug, $route, $name, $nav, $orden) = @$p;
  push @SQL, sprintf(
    "INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)\n" .
    "VALUES (%s, %s, %s, %s, 'published', %s, %d)\n" .
    "ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;\n",
    sql($slug), sql($route), sql($name), sql($nav),
    ($slug eq 'politicadeprivacidad' ? 'false' : 'true'), $orden);
}
push @SQL, "\n";

# ------------------------------------------------------- 3. unidades y soluciones
push @SQL, "-- --------------------------------------------- unidades de solucion\n";
push @SQL, <<'UNI';
INSERT INTO ticspy.solution_units (slug, name, eyebrow, title, route, status, sort_order) VALUES
  ('unidad-aec', 'Unidad AEC', '[ Unidad ] // Unidad AEC', 'CAD, topografía, electricidad y diseño de maquinarias.', '/unidad-aec', 'published', 1),
  ('ciberseguridad', 'Ciberseguridad', '[ Unidad ] // Ciberseguridad', 'Respaldo, recuperación y protección de los equipos.', '/ciberseguridad', 'published', 2)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, title = EXCLUDED.title;

UNI

push @SQL, "-- ------------------------------------------------------------ soluciones\n";
my @sol = (
  ['zwcad',    'ZWCAD',                'ZWCAD',    'unidad-aec',     '/zwcad',    1],
  ['zw3d',     'ZW3D WuKong 2027',     'ZW3D',     'unidad-aec',     '/zw3d',     2],
  ['aplitop',  'Aplitop',              'Aplitop',  'unidad-aec',     '/aplitop',  3],
  ['cadprofi', 'CADprofi',             'CADprofi', 'unidad-aec',     '/cadprofi', 4],
  ['arcserve', 'Arcserve',             'Arcserve', 'ciberseguridad', '/arcserve', 5],
);
# El titular y la entrada de cada solucion salen del propio marcado.
my %titular; my %resalte; my %intro;
for my $s (@sol) {
  my $etiqueta = $s->[1];
  my $label = $s->[0] eq 'zw3d' ? 'ZW3D' : ($s->[0] eq 'zwcad' ? 'ZWCAD' :
              ($s->[0] eq 'aplitop' ? 'Aplitop' : ($s->[0] eq 'cadprofi' ? 'CADprofi' : 'Arcserve')));
  if ($html =~ /data-screen-label="\Q$label\E".*?<h1[^>]*>(.*?)<\/h1>.*?<p data-reveal="" style="font-size: clamp\(16px[^"]*"[^>]*>(.*?)<\/p>/s) {
    my ($h1, $p) = ($1, $2);
    my $hl = ($h1 =~ /<span[^>]*>(.*?)<\/span>/s) ? limpiar($1) : '';
    my $plano = $h1; $plano =~ s/<[^>]*>//g;
    $titular{$s->[0]} = limpiar($plano);
    $resalte{$s->[0]} = $hl;
    my $ip = $p; $ip =~ s/<[^>]*>//g;
    $intro{$s->[0]} = limpiar($ip);
  }
}
for my $s (@sol) {
  my ($slug, $name, $short, $unidad, $route, $orden) = @$s;
  push @SQL, sprintf(
    "INSERT INTO ticspy.solutions (unit_id, page_id, slug, name, short_name, headline, headline_highlight, intro, status, sort_order)\n" .
    "VALUES ((SELECT id FROM ticspy.solution_units WHERE slug = %s),\n" .
    "        (SELECT id FROM ticspy.pages WHERE route = %s),\n" .
    "        %s, %s, %s, %s, %s, %s, 'published', %d)\n" .
    "ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, headline = EXCLUDED.headline,\n" .
    "  headline_highlight = EXCLUDED.headline_highlight, intro = EXCLUDED.intro;\n",
    sql($unidad), sql($route), sql($slug), sql($name), sql($short),
    sql($titular{$slug}), sql($resalte{$slug}), sql($intro{$slug}), $orden);
}
push @SQL, "\n";

# --------------------------------------------------------------- 4. marcas
push @SQL, "-- ------------------------------------------------------ marcas y partners\n";
for my $par (['partners','partner'], ['marcas','brand']) {
  my ($arr, $tipo) = @$par;
  my $i = 0;
  for my $o (objetos(bloque($arr))) {
    my %c = campos($o);
    next unless $c{n} && $c{logo};
    $i++;
    my $slug = lc($c{n});
    $slug =~ s/[^a-z0-9]+/-/g; $slug =~ s/^-|-$//g;
    $slug = "$tipo-$slug";
    my $ruta = ($tipo eq 'partner') ? "/" . ($c{n} =~ /^ZWCAD$/i ? 'zwcad' :
               $c{n} =~ /^Aplitop$/i ? 'aplitop' : $c{n} =~ /^CADprofi$/i ? 'cadprofi' :
               $c{n} =~ /^Arcserve$/i ? 'arcserve' : '') : '';
    $ruta = '' if $ruta eq '/';
    push @SQL, sprintf(
      "INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)\n" .
      "VALUES (%s, %s, %s, (SELECT id FROM ticspy.media_assets WHERE path = %s), %s, %s, 'published', %d)\n" .
      "ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,\n" .
      "  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;\n",
      sql($tipo), sql($c{n}), sql($slug), sql("assets/marcas/" . $c{logo}),
      sql($ruta || undef), sql($c{alto}), $i);
  }
}
push @SQL, "\n";

# ------------------------------------------------- 5. novedades de ZWCAD
push @SQL, "-- ----------------------------------- caracteristicas: novedades de ZWCAD\n";
my $i = 0;
for my $o (objetos(bloque('novedades'))) {
  my %c = campos($o);
  next unless $c{n};
  $i++;
  push @SQL, sprintf(
    "INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)\n" .
    "VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', %s, %s, %s, %s,\n" .
    "        (SELECT id FROM ticspy.media_assets WHERE path = %s), 'published', %d)\n" .
    "ON CONFLICT DO NOTHING;\n",
    sql($c{img}), sql($c{etiqueta}), sql($c{n}), sql($c{txt}),
    sql("assets/zwcad/" . ($c{img} // '') . ".jpg"), $i);
}
push @SQL, "\n";

# ------------------------------------------- 6. modulos especializados ZW3D
push @SQL, "-- ------------------------------ caracteristicas: diseno especializado ZW3D\n";
$i = 0;
for my $o (objetos(bloque('zw3dEspecializado'))) {
  my %c = campos($o);
  next unless $c{n};
  $i++;
  # Los bullets van como arreglo JSON.
  my @pts;
  if ($o =~ /puntos:\s*\[(.*?)\]/s) {
    my $p = $1;
    while ($p =~ /'((?:[^'\\]|\\.)*)'/g) { my $v = $1; $v =~ s/\\'/'/g; push @pts, limpiar($v); }
  }
  my $json = '[' . join(',', map { my $t = $_; $t =~ s/\\/\\\\/g; $t =~ s/"/\\"/g; "\"$t\"" } @pts) . ']';
  push @SQL, sprintf(
    "INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, title, bullets, media_id, status, sort_order)\n" .
    "VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zw3d'), 'especializado', %s, %s, %s::jsonb,\n" .
    "        (SELECT id FROM ticspy.media_assets WHERE path = %s), 'published', %d)\n" .
    "ON CONFLICT DO NOTHING;\n",
    sql($c{img}), sql($c{n}), sql($json),
    sql("assets/zw3d/esp-" . ($c{img} // '') . ".jpg"), $i);
}
push @SQL, "\n";

# ------------------------------------------------- 7. demos de CADprofi
push @SQL, "-- ------------------------------------------------ demos: CADprofi electrico\n";
$i = 0;
for my $o (objetos(bloque('demosElectrico'))) {
  my %c = campos($o);
  next unless $c{n};
  $i++;
  push @SQL, sprintf(
    "INSERT INTO ticspy.solution_demos (solution_id, slug, title, description, video_media_id, status, sort_order)\n" .
    "VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'cadprofi'), %s, %s, %s,\n" .
    "        (SELECT id FROM ticspy.media_assets WHERE path = %s), 'published', %d)\n" .
    "ON CONFLICT DO NOTHING;\n",
    sql($c{v}), sql($c{n}), sql($c{txt}),
    sql("assets/cadprofi/" . ($c{v} // '') . ".mp4"), $i);
}
push @SQL, "\n";

# --------------------------------------------------------- 8. configuracion
push @SQL, "-- -------------------------------------------------------- configuracion\n";
my ($anios) = $html =~ /Somos una empresa con (\d+) años de experiencia/;
my ($correo) = $html =~ /correo: '([^']+)'/;
my ($wapp)   = $html =~ /numero: '(\d+)'/;
my ($desc)   = $html =~ /<meta name="description" content="([^"]*)"/;
push @SQL, sprintf(
  "INSERT INTO ticspy.site_settings (singleton, company_name, tagline, years_experience,\n" .
  "  contact_email, whatsapp_number, contact_phone_display, location)\n" .
  "VALUES (true, %s, %s, %s, %s, %s, %s, %s)\n" .
  "ON CONFLICT (singleton) DO UPDATE SET company_name = EXCLUDED.company_name,\n" .
  "  tagline = EXCLUDED.tagline, years_experience = EXCLUDED.years_experience,\n" .
  "  contact_email = EXCLUDED.contact_email, whatsapp_number = EXCLUDED.whatsapp_number;\n",
  sql("Tic's Solutions"), sql('Tecnología a tu alcance'), ($anios // 'NULL'),
  sql($correo), sql($wapp), sql('(+595) 981 171 372'), sql('Paraguay'));
push @SQL, "\n";

# ---------------------------------------------------------- 9. navegacion
push @SQL, "-- ----------------------------------------------------------- navegacion\n";
my @nav = (
  ['header','Inicio','#/',1], ['header','Nosotros','#/nosotros',2],
  ['header','Servicios','#/servicios',3], ['header','Soluciones','#/partners',4],
  ['header','Novedades','#/novedades',5], ['header','Contactanos','#/contacto',6],
);
for my $n (@nav) {
  push @SQL, sprintf(
    "INSERT INTO ticspy.navigation_items (placement, label, href, is_visible, sort_order)\n" .
    "VALUES (%s, %s, %s, true, %d) ON CONFLICT DO NOTHING;\n",
    sql($n->[0]), sql($n->[1]), sql($n->[2]), $n->[3]);
}

my $salida = "C:/NEURA/tics_solutions/supabase/seeds/001_ticspy_contenido.sql";
open(my $out, '>:encoding(UTF-8)', $salida) or die $!;
print $out join('', @SQL);
close $out;

printf "generado: %d assets, %d paginas, %d soluciones\n",
  scalar(@assets), scalar(@paginas), scalar(@sol);
