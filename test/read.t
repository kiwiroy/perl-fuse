use strict;
use warnings;
use test::helper qw($_real $_point);
use Test::More;

chdir($_real);
open(my $file, '>','file');
print $file "frog\n";
close($file);
chdir($_point);
ok(open(FILE,"file"),"open");
my ($data) = <FILE>;
close(FILE);
is(length($data),5,"right amount read");
is($data,"frog\n","right data read");
unlink("file");

done_testing();
