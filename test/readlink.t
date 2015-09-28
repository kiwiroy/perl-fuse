use strict;
use warnings;
use test::helper qw($_point $_real);
use Test::More;

ok(chdir($_real), 'change dir to real directory');
system("touch abc");

ok(symlink("abc","def"),"OS supports symlinks");
is(readlink("def"),"abc","OS supports symlinks");

sleep 10;

ok(chdir($_point), 'change dir to mountpoint');

ok(-l "def","symlink exists");
is(readlink("def"),"abc","readlink");

unlink("def");

done_testing();
