#!/usr/bin/perl
# Conecta con la base los datos de la empresa: telefono, correo, WhatsApp,
# quien atiende y el lema. Aparecen repetidos en cinco lugares del sitio (el
# boton flotante, el desplegable del menu, la seccion de contacto, la politica
# de privacidad y el pie), y hasta ahora habia que cambiarlos uno por uno.
#
# Solo toca el marcado. Lo que esta despues de </x-dc> es el bloque de logica,
# donde las mismas cadenas son constantes de JavaScript y no deben tocarse.
#
# Sin --aplicar solo cuenta lo que encontro.
use strict;
use warnings;
use utf8;
binmode(STDOUT, ':encoding(UTF-8)');

my $aplicar = grep { $_ eq '--aplicar' } @ARGV;

my $SITIO = "C:/NEURA/tics_solutions/Sitio Web.dc.html";
open(my $fh, '<:encoding(UTF-8)', $SITIO) or die $!;
my $html = do { local $/; <$fh> };
close $fh;

my $corte = index($html, '</x-dc>');
die "no encontre el final del marcado\n" if $corte < 0;
my $marcado = substr($html, 0, $corte);
my $logica  = substr($html, $corte);

# de => a
my @cambios = (
  ['href="tel:+595981171372"',                  'href="{{ emp.tel }}"'],
  ['href="mailto:arturo.osorio@tics-py.com"',   'href="{{ emp.mailto }}"'],
  ['href="https://wa.me/595981171372"',         'href="{{ emp.wa }}"'],
  ['(+595) 981 171 372',                        '{{ emp.telTexto }}'],
  ['arturo.osorio@tics-py.com',                 '{{ emp.correo }}'],
  ['>Arturo Osorio<',                           '>{{ emp.contacto }}<'],
  ['>Director Ejecutivo<',                      '>{{ emp.cargo }}<'],
  ['>Tecnología a tu alcance<',                 '>{{ emp.lema }}<'],
);

my $total = 0;
for my $c (@cambios) {
  my ($de, $a) = @$c;
  my $n = 0;
  $n++ while $marcado =~ /\Q$de\E/g;
  printf "%-46s %d\n", substr($de, 0, 44), $n;
  $total += $n;
  next unless $aplicar;
  $marcado =~ s/\Q$de\E/$a/g;
}
print "\ntotal: $total\n";

exit 0 unless $aplicar;

open(my $out, '>:encoding(UTF-8)', $SITIO) or die $!;
print $out $marcado . $logica;
close $out;
print "aplicado\n";
