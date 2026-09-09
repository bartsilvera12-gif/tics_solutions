#!/usr/bin/perl
# Genera el seed de page_sections leyendo TEXTOS_SECCION del propio sitio.
#
# Se extrae en vez de tipearlo a mano a proposito: la tabla del sitio es el
# respaldo y la base es la fuente. Si se escribieran por separado, un acento
# de diferencia haria que el sitio cambie de texto al conectarse la base.
use strict;
use warnings;
use utf8;
binmode(STDOUT, ':encoding(UTF-8)');

my $SITIO  = "C:/NEURA/tics_solutions/Sitio Web.dc.html";
my $SALIDA = "C:/NEURA/tics_solutions/supabase/seeds/002_ticspy_secciones.sql";

open(my $fh, '<:encoding(UTF-8)', $SITIO) or die $!;
my $html = do { local $/; <$fh> };
close $fh;

my ($tabla) = $html =~ /const TEXTOS_SECCION = \{(.*?)\n    \};/s
  or die "no encontre TEXTOS_SECCION\n";

# clave => [pagina, tipo, orden]
my %destino = (
  hero           => ['inicio',         'hero',     1],
  nosotros       => ['nosotros',       'text',     1],
  servicios      => ['servicios',      'text',     1],
  beneficios     => ['inicio',         'benefits', 2],
  partnersHome   => ['partners',       'partners', 1],
  mision         => ['nosotros',       'text',     2],
  contacto       => ['contacto',       'contact',  1],
  novedades      => ['novedades',      'text',     1],
  unidadAec      => ['unidad-aec',     'text',     1],
  ciberseguridad => ['ciberseguridad', 'text',     1],
);

my $COMILLA = chr(39);
my $BARRA   = chr(92);

sub desescapar {                     # literal JS -> texto
  my ($t) = @_;
  $t =~ s/\Q$BARRA$COMILLA\E/$COMILLA/g;
  $t =~ s/\Q$BARRA$BARRA\E/$BARRA/g;
  return $t;
}

sub sql {                            # texto -> literal SQL, o NULL si vacio
  my ($t) = @_;
  return 'NULL' if !defined $t || $t eq '';
  $t =~ s/\Q$COMILLA\E/$COMILLA$COMILLA/g;
  return $COMILLA . $t . $COMILLA;
}

# \x27 es la comilla simple y \x5c la barra invertida. Se escriben asi para
# no tener que pelear con el escapado de la comilla dentro del propio patron.
my $campo = '(?:[^\x27\x5c]|\x5c.)*';
my $re = qr/(\w+):\s*\{\s*titular:\s*\x27($campo)\x27,\s*resalte:\s*\x27($campo)\x27,\s*entrada:\s*\x27($campo)\x27\s*\}/s;

my @filas;
while ($tabla =~ /$re/g) {
  my ($clave, $titular, $resalte, $entrada) =
    ($1, desescapar($2), desescapar($3), desescapar($4));
  die "clave sin destino: $clave\n" unless $destino{$clave};
  push @filas, [$clave, $titular, $resalte, $entrada];
}

die "lei " . scalar(@filas) . " secciones de " . scalar(keys %destino) . "\n"
  if scalar(@filas) != scalar(keys %destino);

open(my $out, '>:encoding(UTF-8)', $SALIDA) or die $!;
print $out <<'CAB';
-- ===========================================================================
--  Seed 002 :: textos de las secciones que no son de marca
-- ===========================================================================
--  Generado por supabase/tools/generar-seed-secciones.pl a partir del sitio.
--  No editar a mano: se pisa en la proxima corrida. Para cambiar un texto,
--  usar el panel; para cambiar el respaldo, tocar TEXTOS_SECCION en el sitio.
--
--  El titulo viaja entero y highlight_text dice que fragmento va en rojo. El
--  sitio parte la frase al pintarla, asi que la base nunca guarda HTML.
--
--  Es idempotente: ON CONFLICT sobre UNIQUE (page_id, section_key).
-- ===========================================================================

CAB

for my $c (sort { $destino{$a->[0]}[0] cmp $destino{$b->[0]}[0] } @filas) {
  my ($clave, $titular, $resalte, $entrada) = @$c;
  my ($pagina, $tipo, $orden) = @{ $destino{$clave} };
  printf $out
    "INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)\n" .
    "SELECT id, '%s', '%s', %s, %s, %s, true, %d FROM ticspy.pages WHERE slug = '%s'\n" .
    "ON CONFLICT (page_id, section_key) DO UPDATE SET\n" .
    "  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,\n" .
    "  body = EXCLUDED.body, section_type = EXCLUDED.section_type,\n" .
    "  sort_order = EXCLUDED.sort_order;\n\n",
    $clave, $tipo, sql($titular), sql($resalte), sql($entrada), $orden, $pagina;
  printf "%-16s -> %-15s %s\n", $clave, $pagina, substr($titular, 0, 46);
}
close $out;
print "\nescrito: $SALIDA (" . scalar(@filas) . " secciones)\n";
