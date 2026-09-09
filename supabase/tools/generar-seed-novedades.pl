#!/usr/bin/perl
# Genera el seed de news_items leyendo la tabla de respaldo del propio sitio.
#
# Igual que el de las secciones: se extrae en vez de tipearlo a mano para que
# el respaldo del sitio y lo que hay en la base no puedan divergir.
use strict;
use warnings;
use utf8;
binmode(STDOUT, ':encoding(UTF-8)');

my $SITIO  = "C:/NEURA/tics_solutions/Sitio Web.dc.html";
my $SALIDA = "C:/NEURA/tics_solutions/supabase/seeds/003_ticspy_novedades.sql";

open(my $fh, '<:encoding(UTF-8)', $SITIO) or die $!;
my $html = do { local $/; <$fh> };
close $fh;

my ($tabla) = $html =~ /const publicaciones = \[(.*?)\n    \];/s
  or die "no encontre la tabla publicaciones\n";

my $COMILLA = chr(39);
my $BARRA   = chr(92);

sub desescapar {
  my ($t) = @_;
  $t =~ s/\Q$BARRA$COMILLA\E/$COMILLA/g;
  $t =~ s/\Q$BARRA$BARRA\E/$BARRA/g;
  return $t;
}

sub sql {
  my ($t) = @_;
  return 'NULL' if !defined $t || $t eq '';
  $t =~ s/\Q$COMILLA\E/$COMILLA$COMILLA/g;
  return $COMILLA . $t . $COMILLA;
}

# Un slug legible a partir del titulo, igual que el que arma el panel.
sub slug {
  my ($t) = @_;
  $t = lc $t;
  $t =~ tr/\x{e1}\x{e9}\x{ed}\x{f3}\x{fa}\x{f1}\x{fc}/aeiounu/;
  $t =~ s/[^a-z0-9]+/-/g;
  $t =~ s/^-+|-+$//g;
  return $t;
}

my $campo = '(?:[^\x27\x5c]|\x5c.)*';
my $re = qr/\{\s*fecha:\s*\x27($campo)\x27,\s*etiqueta:\s*\x27($campo)\x27,\s*
            n:\s*\x27($campo)\x27,\s*
            txt:\s*\x27($campo)\x27,\s*
            enlace:\s*\x27($campo)\x27,\s*
            textoEnlace:\s*\x27($campo)\x27,\s*
            enlace2:\s*\x27($campo)\x27,\s*textoEnlace2:\s*\x27($campo)\x27\s*\}/sx;

my @filas;
while ($tabla =~ /$re/g) {
  push @filas, {
    fecha    => desescapar($1), etiqueta => desescapar($2),
    titulo   => desescapar($3), resumen  => desescapar($4),
    enlace   => desescapar($5), texto    => desescapar($6),
    enlace2  => desescapar($7), texto2   => desescapar($8)
  };
}
die "no lei ninguna publicacion\n" unless @filas;

open(my $out, '>:encoding(UTF-8)', $SALIDA) or die $!;
print $out <<'CAB';
-- ===========================================================================
--  Seed 003 :: las novedades que ya se veian en /novedades
-- ===========================================================================
--  Generado por supabase/tools/generar-seed-novedades.pl a partir del sitio.
--  No editar a mano: se pisa en la proxima corrida. Para cargar una novedad
--  nueva, usar el panel.
--
--  La fecha se guarda al mediodia y no a la medianoche: guardada a las 00:00
--  UTC, en Paraguay caeria el dia anterior.
--
--  Es idempotente: ON CONFLICT sobre el slug, que es unico.
-- ===========================================================================

CAB

for my $f (@filas) {
  my $s = slug($f->{titulo});
  printf $out
    "INSERT INTO ticspy.news_items (slug, title, label, summary, published_at,\n" .
    "  link_url, link_label, secondary_link_url, secondary_link_label, status)\n" .
    "VALUES (%s, %s, %s, %s, %s::timestamptz,\n" .
    "  %s, %s, %s, %s, 'published')\n" .
    "ON CONFLICT (slug) DO UPDATE SET\n" .
    "  title = EXCLUDED.title, label = EXCLUDED.label, summary = EXCLUDED.summary,\n" .
    "  published_at = EXCLUDED.published_at, link_url = EXCLUDED.link_url,\n" .
    "  link_label = EXCLUDED.link_label,\n" .
    "  secondary_link_url = EXCLUDED.secondary_link_url,\n" .
    "  secondary_link_label = EXCLUDED.secondary_link_label,\n" .
    "  status = EXCLUDED.status;\n\n",
    sql($s), sql($f->{titulo}), sql($f->{etiqueta}), sql($f->{resumen}),
    sql($f->{fecha} . ' 12:00:00+00'),
    sql($f->{enlace}), sql($f->{texto}), sql($f->{enlace2}), sql($f->{texto2});
  printf "%-12s %-9s %s\n", $f->{fecha}, $f->{etiqueta}, substr($f->{titulo}, 0, 44);
}
close $out;
print "\nescrito: $SALIDA (" . scalar(@filas) . " novedades)\n";
