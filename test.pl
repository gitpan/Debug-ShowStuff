#!/usr/local/bin/perl -w
use strict;
use Debug::ShowStuff ':all';
use Test;


BEGIN { plan tests => 5 };

my ($str, %hash, @arr, $scalar);

%hash = qw[a 1 b 2 c 3];
@arr = %hash;
$scalar = @arr;

$str = showhash %hash;
ok 1;
$str = showhash \%hash;
ok 1;

$str = showarr @arr;
ok 1;
$str = showarr \@arr;
ok 1;

$str = showscalar $scalar;
ok 1;
