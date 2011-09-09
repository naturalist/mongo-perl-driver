#!/usr/bin/env perl
package Base1;
use MongoDB::Base -base;
has 'bananas';

package Base2;
use MongoDB::Base 'Base1';
has [qw/ears eyes/] => sub {2};
has coconuts => 0;

package BaseTest;
use MongoDB::Base -strict;

use base 'Base2';

__PACKAGE__->attr(heads => 1);
__PACKAGE__->attr('name');

package main;
use MongoDB::Base -strict;

use Test::More tests => 405;

use_ok 'MongoDB::Base';

# Basic functionality
my $monkeys = [];
for my $i (1 .. 50) {
  $monkeys->[$i] = BaseTest->new;
  $monkeys->[$i]->bananas($i);
  is $monkeys->[$i]->bananas, $i, 'right attribute value';
}
for my $i (51 .. 100) {
  $monkeys->[$i] = BaseTest->new(bananas => $i);
  is $monkeys->[$i]->bananas, $i, 'right attribute value';
}

# Instance method
my $monkey = BaseTest->new;
$monkey->attr('mojo');
$monkey->mojo(23);
is $monkey->mojo, 23, 'monkey has mojo';

# "default" defined but false
my $m = $monkeys->[1];
ok defined($m->coconuts);
is $m->coconuts, 0, 'right attribute value';
$m->coconuts(5);
is $m->coconuts, 5, 'right attribute value';

# "default" support
my $y = 1;
for my $i (101 .. 150) {
  $y = !$y;
  $monkeys->[$i] = BaseTest->new;
  isa_ok $monkeys->[$i]->name('foobarbaz'),
    'BaseTest', 'attribute value has right class';
  $monkeys->[$i]->heads('3') if $y;
  $y
    ? is($monkeys->[$i]->heads, 3, 'right attribute value')
    : is($monkeys->[$i]->heads, 1, 'right attribute default value');
}

# "chained" and coderef "default" support
for my $i (151 .. 200) {
  $monkeys->[$i] = BaseTest->new;
  is $monkeys->[$i]->ears, 2, 'right attribute value';
  is $monkeys->[$i]->ears(6)->ears, 6, 'right chained attribute value';
  is $monkeys->[$i]->eyes, 2, 'right attribute value';
  is $monkeys->[$i]->eyes(6)->eyes, 6, 'right chained attribute value';
}

1;
