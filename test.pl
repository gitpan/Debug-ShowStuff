#!/usr/bin/perl -w
use strict;
use lib '../../';
use Debug::ShowStuff ':all';
use Test;

# Not really sure what to test: it just outputs stuff.  This script
# just tests that the module loads.

BEGIN { plan tests => 1 };

println 'yup, it works';

ok(1);
