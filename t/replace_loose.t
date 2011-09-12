use strict;
use warnings;
use Test::More;
use Unicode::CharNames::Replace qw( loose );

# TODO: test that shorter names don't chop up longer ones (and sort by length to fix it)
my @tests = (
  [  'i HEAVY BLACK HEART perl', {},       "i \x{2764} perl", 'upper case'],
  [  'i heavy black heart perl', {},       "i heavy black heart perl", 'lower case not replaced without option'],
  [  'i heavy black heart perl', {i => 1}, "i \x{2764} perl",          'lower case replaced'],
  [  'i heavy black heart perl', {i => 0}, "i heavy black heart perl", 'lower case not replaced with false option'],
  ['black club suit  <=>  white club suit', {i => 1}, "\x{2663}  <=>  \x{2667}", '2 charnames'],
  ["BLACK CLUB SUIT \n-\n WHITE CLUB SUIT", {      }, "\x{2663} \n-\n \x{2667}", 'across newlines'],
  # unknown chars are just the rest of the string
  ["CharThatCannot PossiblyExist", {}, "CharThatCannot PossiblyExist", 'invalid char stays'],
);

plan tests => scalar @tests;

foreach my $test ( @tests ){
  my ($str, $opts, $exp, $desc) = @$test;
  is loose($str, $opts), $exp, $desc;
}