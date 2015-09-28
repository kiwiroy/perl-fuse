use strict;
use warnings;
use test::helper qw($_real $_point);
use Test::More;

chdir($_point);
ok(mkdir("dir"),"mkdir");
ok(-d "dir","dir exists");
chdir($_real);
ok(-d "dir","dir really exists");
chdir($_point);
rmdir("dir");

done_testing();
