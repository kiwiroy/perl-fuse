
use strict;
use warnings;
use test::helper qw($_real $_point);
use Test::More;

chdir($_real);
open(my $file, '>', 'file');
print $file "frog\n";
close($file);
chdir($_point);
ok(open(FILE,"file"),"open");
close(FILE);
unlink("file");

done_testing();
