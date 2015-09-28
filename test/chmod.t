
use strict;
use warnings;
use test::helper qw($_real $_point);
use Test::More;

$| = 1;

ok(chdir($_point), 'changed directory');

my $filename = 'file-to-chmod';

open(my $file, '>', $filename);
print $file "frog\n";
close($file);
sleep(1);

my $sixfourfour = chmod 0644, $filename;
ok($sixfourfour, "set unexecutable");
ok((! -x $filename), "$filename is not executable");

sleep(1);
my $sevenfivefive = chmod 0755, $filename;
ok($sevenfivefive, "set executable");
ok((-x $filename),"executable");
sleep(1);

ok(unlink($filename), "removed $filename");

done_testing();
