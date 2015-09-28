
use test::helper qw($_point $_real $_pidfile);
use strict;
use warnings;
use Test::More;
use POSIX qw(WEXITSTATUS);

system("umount $_point");

if(POSIX::WEXITSTATUS($?) != 0) {
	system("umount $_point");
}
ok(POSIX::WEXITSTATUS($?) == 0,"unmount");
system("rm -rf $_real $_pidfile");
rmdir($_point);

done_testing();
