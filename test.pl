#!/usr/bin/env perl

BEGIN { $ENV{HARNESS_IGNORE_EXITCODE} = 1; }

use Test::Harness qw(&runtests $verbose);
$verbose=0;
die "cannot find test directory!" unless -d "test";
my (@files) = sort glob 'test/*.t';
runtests("test/s/mount.t", @files ,"test/s/umount.t");
