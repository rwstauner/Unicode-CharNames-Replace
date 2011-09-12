# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;
use 5.014; # charnames::string_vianame() requires 5.14; this could be relaxed by switching to vianame()

package Unicode::CharNames::Replace;
# ABSTRACT: Replace unicode charnames with characters at runtime
use Sub::Exporter -setup => {
  exports => [
    #map { ("replace_$_" => \
    delimited =>
    loose     =>
    replace_charnames =>
  ],
#  groups => {
#    default => {
#      -prefix => 'replace_'
#    }
#  }
};

use charnames ':full';

sub replace_charnames {
  my $string = shift;
  # FIXME: what should the default be?
  my $opts   = shift || die q[Without options replace_charnames does nothing];
  # delimited first so that we don't strip out charnames and end up with extra braces
  $string = delimited($string, $opts) if $opts->{delimited};
  $string = loose(    $string, $opts) if $opts->{loose};
  return $string;
}

sub delimited {
  my $string = shift;
  my $opts   = shift || {};
  my $start  = $opts->{start} || qr/(?:\\N)?\{/;
  my $end    = $opts->{end}   || qr/\}/;

  # this regexp is currently naively simple but currently so are charnames - 2011-09-12 rwstauner
  $string =~ s/(${start})(.+?)(${end})/charnames::string_vianame(uc($2)) || ($1.$2.$3)/ge;

  return $string;
}

sub loose {
  my $string = shift;
  my $opts   = shift || {};
  my $re = _charnames_re_str();

  $re = $opts->{insensitive} || $opts->{i}
    ? qr/$re/i
    : qr/$re/;

  $re = qr/\b$re\b/
    unless $opts->{nobounaries} || $opts->{nb};

  $string =~ s/($re)/charnames::string_vianame(uc($1)) || $1/ge;
  return $string;
}

my $_charnames_re_str;
sub _charnames_re_str {
  return $_charnames_re_str ||= join '|',
    map {
      quotemeta( (split(/\t/))[1] )
    }
    split /\n/, require 'unicore/Name.pl';
}

1;

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

=for :list
* L<unirep> - Command line version that works like C<echo> or C<cat>

=head1 TODO

=for :list
* relax requirement for 5.14
* Rename methods
* Document methods
* Document usefulness (runtime)
* Make use of Sub::Exporter with default options, etc
* Allow for escaping the opening delimiter?
* By default ignore non-printing characters (CHARACTER TABULATION, LINE FEED (LF), SPACE, NULL) to avoid confusion
* aliases?  is this necessary beyond the alias functionality of charnames?
* a set of default aliases (heart, poo, razzberry)?

=cut
