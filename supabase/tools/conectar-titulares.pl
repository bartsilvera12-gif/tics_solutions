#!/usr/bin/perl
# Conecta con la base el titular y la entrada de las cinco paginas de marca.
#
# Hace las dos mitades en una sola pasada, a proposito: extrae el texto que
# hoy esta en el marcado, lo deja como respaldo en el bloque de logica, y en
# el mismo movimiento reemplaza el marcado por el binding. Si se hicieran por
# separado, el respaldo y lo que muestra el sitio podrian divergir.
use strict;
use warnings;
use utf8;
binmode(STDOUT, ':encoding(UTF-8)');

my $SITIO = "C:/NEURA/tics_solutions/Sitio Web.dc.html";
open(my $fh, '<:encoding(UTF-8)', $SITIO) or die $!;
my $html = do { local $/; <$fh> };
close $fh;

my @marcas = (
  ['ZWCAD',    'zwcad'],
  ['ZW3D',     'zw3d'],
  ['Aplitop',  'aplitop'],
  ['CADprofi', 'cadprofi'],
  ['Arcserve', 'arcserve'],
);

sub js {                       # texto -> literal JS entre comillas simples
  my ($t) = @_;
  $t = '' unless defined $t;
  $t =~ s/\\/\\\\/g;
  $t =~ s/'/\\'/g;
  return "'$t'";
}

my %base;
my $cambios = 0;

for my $m (@marcas) {
  my ($etiqueta, $slug) = @$m;

  # El bloque de esa pantalla.
  my ($ini) = $html =~ /(data-screen-label="\Q$etiqueta\E")/ ? $-[0] : undef;
  die "no encontre la pantalla $etiqueta\n" unless defined $ini;

  # El h1 y el parrafo de entrada que le sigue.
  my $resto = substr($html, $ini);
  my ($h1completo, $interior) = $resto =~ /(<h1\b[^>]*>(.*?)<\/h1>)/s;
  die "no encontre el h1 de $etiqueta\n" unless $h1completo;

  my ($entradaCompleta, $entradaTexto) =
    $resto =~ /(<p data-reveal="" style="font-size: clamp\(16px, 1\.25vw, 19px\)[^"]*"[^>]*>(.*?)<\/p>)/s;
  die "no encontre la entrada de $etiqueta\n" unless $entradaCompleta;

  # Partes del titular: lo de antes del span, lo resaltado y lo de despues.
  my ($antes, $resalte, $despues);
  if ($interior =~ /^(.*?)<span[^>]*>(.*?)<\/span>(.*)$/s) {
    ($antes, $resalte, $despues) = ($1, $2, $3);
  } else {
    ($antes, $resalte, $despues) = ($interior, '', '');
  }
  # OJO: aca no se recorta nada de $antes ni de $despues. El espacio que hay
  # antes del span es parte de la frase: sin el, "a la " + "manufactura" queda
  # "alamanufactura". Solo se limpia la entrada, que es un parrafo entero.
  $entradaTexto =~ s/^\s+|\s+$//g;

  $base{$slug} = {
    titular => "$antes$resalte$despues",
    resalte => $resalte,
    entrada => $entradaTexto
  };

  # El h1 pasa a leer del binding. Se conserva el span y su estilo: el
  # diseno no cambia, solo de donde sale el texto.
  my $h1nuevo = $h1completo;
  $h1nuevo =~ s{>\Q$interior\E</h1>}
               {>{{ t.$slug.antes }}<span style="color: #E71917;">{{ t.$slug.resalte }}</span>{{ t.$slug.despues }}</h1>};
  die "no pude reescribir el h1 de $etiqueta\n" if $h1nuevo eq $h1completo;

  my $entradaNueva = $entradaCompleta;
  $entradaNueva =~ s{>\Q$entradaTexto\E</p>}{>{{ t.$slug.entrada }}</p>};
  die "no pude reescribir la entrada de $etiqueta\n" if $entradaNueva eq $entradaCompleta;

  $html =~ s/\Q$h1completo\E/$h1nuevo/ or die "no aplique el h1 de $etiqueta\n";
  $html =~ s/\Q$entradaCompleta\E/$entradaNueva/ or die "no aplique la entrada de $etiqueta\n";
  $cambios += 2;
}

# ---------------------------------------------------------------------------
# El respaldo, dentro del bloque de logica.
# ---------------------------------------------------------------------------
my $tabla = "    // Lo que dice el sitio hoy. Es el respaldo: si la base no responde o\n" .
            "    // devuelve el campo vacio, se muestra esto y nadie nota nada.\n" .
            "    const TEXTOS_MARCA = {\n";
for my $m (@marcas) {
  my $slug = $m->[1];
  my $b = $base{$slug};
  $tabla .= sprintf("      %-9s { titular: %s,\n%s resalte: %s,\n%s entrada: %s },\n",
    "$slug:", js($b->{titular}),
    ' ' x 17, js($b->{resalte}),
    ' ' x 17, js($b->{entrada}));
}
$tabla .= "    };\n\n";

my $ancla = "    const partners = [";
$html =~ s/\Q$ancla\E/$tabla$ancla/ or die "no encontre donde poner el respaldo\n";

open(my $out, '>:encoding(UTF-8)', $SITIO) or die $!;
print $out $html;
close $out;

printf "reescritos: %d fragmentos en %d paginas\n", $cambios, scalar(@marcas);
for my $m (@marcas) {
  my $b = $base{$m->[1]};
  printf "  %-9s %s | resalte: %s\n", $m->[1], substr($b->{titular}, 0, 46), ($b->{resalte} || '(sin resalte)');
}
