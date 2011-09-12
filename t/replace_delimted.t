use strict;
use warnings;
use Test::More;
use Unicode::CharNames::Replace qw( delimited );

my @tests = (
  ['i \N{HEAVY BLACK HEART} perl', "i \x{2764} perl", 'backslash N'],
  [  'i {HEAVY BLACK HEART} perl', "i \x{2764} perl", 'without backslash N'],
  [  'i {heavy black heart} perl', "i \x{2764} perl", 'lower case'],
  ['{black club suit}  <=>  {white club suit}', "\x{2663}  <=>  \x{2667}", '2 charnames'],
  ["{black club suit} \n-\n {white club suit}", "\x{2663} \n-\n \x{2667}", 'across newlines'],
  ["hi.\\N{LINE FEED (LF)}", "hi.\n", 'works with charnames outside the [\w\s-] class'],
  # FIXME: this should be an option (use replacement char)
  ["{CharThatCannot PossiblyExist}", "{CharThatCannot PossiblyExist}", 'invalid char stays'],
);

plan tests => scalar @tests;

foreach my $test ( @tests ){
  my ($str, $exp, $desc) = @$test;
  is delimited($str), $exp, $desc;
}
