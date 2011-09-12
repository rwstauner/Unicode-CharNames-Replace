# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;

package Unicode::CharNames::Replace;
# ABSTRACT: undef
use Sub::Exporter -setup => {
  exports => [
    #map { ("replace_$_" => \
    delimited =>
    loose     =>
  ],
#  groups => {
#    default => {
#      -prefix => 'replace_'
#    }
#  }
};

use charnames ':full';

sub delimited {
  my $string = shift;
  my $opts   = shift || {};
  my $start  = $opts->{start} || qr/(?:\\N)?\{/;
  my $end    = $opts->{end}   || qr/\}/;
  $string =~ s/(${start})(.+?)(${end})/charnames::string_vianame(uc($2)) || ($1.$2.$3)/ge;
  return $string;
}


1;

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut
