# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;
use 5.014; # charnames::string_vianame() requires 5.14; this could be relaxed by switching to vianame()

package Unicode::CharNames::Replace;
# ABSTRACT: Replace unicode charnames with characters at runtime
use Sub::Exporter -setup => {
  exports => [
    #map { ("replace_$_" => \
    replace_delimited =>
    replace_bare      =>
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
  # delimited first so that we don't strip out charnames and leave delimiters behind
  $string = replace_delimited($string, $opts) if $opts->{delimited};
  $string = replace_bare(     $string, $opts) if $opts->{bare};
  return $string;
}

sub replace_delimited {
  my $string = shift;
  my $opts   = shift || {};
  my $start  = $opts->{start} || qr/(?:\\N)?\{/;
  my $end    = $opts->{end}   || qr/\}/;

  # this regexp is currently naively simple but currently so are charnames - 2011-09-12 rwstauner
  $string =~ s/(${start})(.+?)(${end})/charnames::string_vianame(uc($2)) || ($1.$2.$3)/ge;

  return $string;
}

sub replace_bare {
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
    # match longest possible char name first
    sort { length($b) <=> length($a) }
    split /\n/, require 'unicore/Name.pl';
}

1;

=encoding utf8

=for test_synopsis
my ($str);

=head1 SYNOPSIS

  use Unicode::CharNames::Replace qw( replace_charnames );

  my $str = replace_charnames($input, \%options);

=head1 DESCRIPTION

This module provides functions for replacing unicode character names
with their corresponding characters at runtime.

The L<charnames> pragma provides a way to place "\N{CHARNAME}" into
strings, but it does this at compile time.
This module will search for character names in strings
created dynamically during your program's execution,
for example, from user input.

The use-case that was the impetus for this module
is the provided L<unirep> script
which replaces charnames with characters
from C<@ARGV> or C<< <STDIN> >>.

=head1 SEE ALSO

=for :list
* L<unirep> - Command line version that works like C<echo> or C<cat>

=head1 TODO

=for :list
* relax requirement for 5.14
* Rename methods
* Document methods
* Make use of Sub::Exporter with default options, etc
* Allow for escaping the opening delimiter?
* If delimited item is not exact, try matching as a regexp
* By default ignore non-printing characters (CHARACTER TABULATION, LINE FEED (LF), SPACE, NULL) to avoid confusion
* aliases?  is this necessary beyond the alias functionality of charnames?
* a set of default aliases (heart, poo, razzberry)?

=cut
