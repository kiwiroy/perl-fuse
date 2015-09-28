
use test::helper qw($_point $_loop $_opts $_real $_pidfile);
use strict;
use warnings;
use Errno qw(:POSIX);
use Test::More tests => 3;

sub is_mounted {
	my $diag = -e '/proc/mounts' ? `cat /proc/mounts` : ($^O eq 'linux' ? `/bin/mount` : ($^O eq 'solaris' ? `/usr/sbin/mount` : `/sbin/mount`));
	my $pattern = $^O eq 'solaris' ? qr{^$_point }m : qr{ (?:/private)?$_point };
	return $diag =~ $pattern;
}

ok(!is_mounted(),"already mounted");
ok(-f $_loop,"loopback exists");

mkdir $_point;
mkdir $_real;
diag "mounting $_loop to $_point";
open REALSTDOUT, '>&STDOUT';
open REALSTDERR, '>&STDERR';
open STDOUT, '>', '/dev/null';
open STDERR, '>&', \*STDOUT;
diag "$_loop $_opts $_point";
system("perl -Iblib/lib -Iblib/arch $_loop $_opts $_point");
open STDOUT, '>&', \*REALSTDOUT;
open STDERR, '>&', \*REALSTDERR;

my ($success, $count) = (0,0);
while ($count++ < 50 && !$success) {
	select(undef, undef, undef, 0.1);
	($success) = is_mounted();
}
diag "Mounted in ", $count/10, " secs";

ok($success,"mount succeeded");
system("rm -rf $_real");
unless($success) {
	kill('INT',`cat $_pidfile`);
	unlink($_pidfile);
} else {
	mkdir($_real);
}
