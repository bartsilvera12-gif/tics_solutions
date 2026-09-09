#!/usr/bin/perl
# Conecta las cuatro tarjetas de /servicios con la base.
#
# Ademas de reemplazar el marcado por un sc-for, arregla un anidado: hoy la
# primera tarjeta nunca se cierra, la segunda tampoco, y el navegador termina
# metiendo una dentro de otra. Se ve como cajas encajadas y corridas hacia la
# derecha. Con el sc-for quedan cuatro hermanas, que es lo que se buscaba.
#
# Sin --aplicar solo muestra lo que encontro.
use strict;
use warnings;
use utf8;
binmode(STDOUT, ':encoding(UTF-8)');

my $aplicar = grep { $_ eq '--aplicar' } @ARGV;

my $SITIO  = "C:/NEURA/tics_solutions/Sitio Web.dc.html";
my $SEED   = "C:/NEURA/tics_solutions/supabase/seeds/004_ticspy_servicios.sql";

open(my $fh, '<:encoding(UTF-8)', $SITIO) or die $!;
my $html = do { local $/; <$fh> };
close $fh;

my $COMILLA = chr(39);
my $BARRA   = chr(92);

sub limpiar {
  my ($t) = @_;
  $t =~ s/&rsquo;/\x{2019}/g; $t =~ s/&mdash;/\x{2014}/g; $t =~ s/&nbsp;/ /g;
  $t =~ s/&amp;/&/g;
  $t =~ s/\s+/ /g; $t =~ s/^\s+|\s+$//g;
  return $t;
}
sub js  { my ($t)=@_; $t=~s/\Q$BARRA\E/$BARRA$BARRA/g; $t=~s/\Q$COMILLA\E/$BARRA$COMILLA/g; return $COMILLA.$t.$COMILLA; }
sub sql { my ($t)=@_; return 'NULL' if !defined $t || $t eq ''; $t=~s/\Q$COMILLA\E/$COMILLA$COMILLA/g; return $COMILLA.$t.$COMILLA; }
sub slug {
  my ($t) = @_; $t = lc $t;
  $t =~ tr/\x{e1}\x{e9}\x{ed}\x{f3}\x{fa}\x{f1}/aeioun/;
  $t =~ s/[^a-z0-9]+/-/g; $t =~ s/^-+|-+$//g; return $t;
}

# ---- el bloque de las tarjetas ----
my $ini = ($html =~ /data-screen-label="Servicios"/) ? $-[0] : die "no encontre la pantalla\n";
my $resto = substr($html, $ini);

my ($bloque) = $resto =~ /(<div style="display: grid; grid-template-columns: repeat\(auto-fit, minmax\(min\(100%, 400px\).*?<\/div>\n      <\/div>)/s
  or die "no encontre la grilla de tarjetas\n";

my @tarjetas;
while ($bloque =~ /<h3[^>]*>(.*?)<\/h3>\s*<p[^>]*>(.*?)<\/p>/gs) {
  push @tarjetas, { titulo => limpiar($1), texto => limpiar($2) };
}
die "esperaba 4 tarjetas, encontre " . scalar(@tarjetas) . "\n" unless @tarjetas == 4;

my $i = 0;
for my $t (@tarjetas) {
  $i++;
  printf "%d. %s\n   %s\n\n", $i, $t->{titulo}, substr($t->{texto}, 0, 76) . '...';
}

exit 0 unless $aplicar;

# ---- el sc-for ----
my $E_CAJA = 'border: 1px solid rgba(29,30,30,.1); background: #FAFBFC; padding: clamp(28px, 3vw, 40px);';
my ($hoverCaja) = $bloque =~ /class="om-spot"[^>]*style-hover="([^"]*)"/;
$hoverCaja = 'border-color: rgba(231,25,23,.3);' unless $hoverCaja;
my ($estiloH3) = $bloque =~ /<h3 style="([^"]*)"/;
my ($estiloP)  = $bloque =~ /<h3[^>]*>.*?<p style="([^"]*)"/s;

my $nuevo = <<"FIN";
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 400px), 1fr)); gap: clamp(28px, 4vw, 56px); align-items: stretch;">
        <div style="display: flex; flex-direction: column; gap: clamp(20px, 2.4vw, 28px);">
          <!-- SpotlightCard (React Bits) -->
          <sc-for list="{{ servicios }}" as="sv" hint-placeholder-count="4">
          <div data-reveal="" data-spotlight="" class="om-spot" style="$E_CAJA" style-hover="$hoverCaja">
            <div style="position: relative; z-index: 1;">
              <h3 style="$estiloH3">{{ sv.n }}</h3>
              <p style="$estiloP">{{ sv.txt }}</p>
            </div>
          </div>
          </sc-for>
        </div>
      </div>
FIN
chomp $nuevo;

my $p = index($html, $bloque);
substr($html, $p, length($bloque)) = $nuevo;

# ---- respaldo ----
my $tabla = "    // Las tarjetas de /servicios. Respaldo, igual que el resto.\n" .
            "    const servicios = [\n";
for my $t (@tarjetas) {
  $tabla .= "      { n: " . js($t->{titulo}) . ",\n        txt: " . js($t->{texto}) . " },\n";
}
$tabla .= "    ];\n\n";

my $ancla = "    const partners = [";
$html =~ s/\Q$ancla\E/$tabla$ancla/ or die "no encontre donde poner el respaldo\n";

open(my $out, '>:encoding(UTF-8)', $SITIO) or die $!;
print $out $html;
close $out;

# ---- seed ----
open(my $sd, '>:encoding(UTF-8)', $SEED) or die $!;
print $sd <<'CAB';
-- ===========================================================================
--  Seed 004 :: los cuatro servicios que ya se veian en /servicios
-- ===========================================================================
--  Generado por supabase/tools/generar-seed-servicios.pl a partir del sitio.
--  No editar a mano: se pisa en la proxima corrida. Para cambiar un texto,
--  usar el panel.
--
--  El seed 001 los habia cargado con el titulo pero sin el texto, asi que en
--  el panel se veian vacios. Aca se completan.
--
--  Es idempotente: ON CONFLICT sobre el slug, que es unico.
-- ===========================================================================

CAB
my $orden = 0;
for my $t (@tarjetas) {
  $orden++;
  printf $sd
    "INSERT INTO ticspy.services (slug, title, short_description, description, status, sort_order)\n" .
    "VALUES (%s, %s, %s, %s, 'published', %d)\n" .
    "ON CONFLICT (slug) DO UPDATE SET\n" .
    "  title = EXCLUDED.title, short_description = EXCLUDED.short_description,\n" .
    "  description = EXCLUDED.description, status = EXCLUDED.status,\n" .
    "  sort_order = EXCLUDED.sort_order;\n\n",
    sql(slug($t->{titulo})), sql($t->{titulo}),
    sql(substr($t->{texto}, 0, 120)), sql($t->{texto}), $orden;
}
close $sd;

print "listo: 4 servicios al sc-for, al respaldo y al seed\n";
