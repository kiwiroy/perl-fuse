
use strict;
use warnings;
use test::helper qw($_real $_point);
use Test::More;
use English;

my $filename = 'file-to-chown';
my (@stat);

ok(chdir($_point), 'change directory');

open(my $file, '>', $filename);
print $file "frog\n";
close($file);

SKIP: {
	skip('Need root to give away ownership', 4) unless ($UID == 0);

	ok(chown(0,0, $filename),"set 0,0");
	@stat = stat($filename);
	ok($stat[4] == 0 && $stat[5] == 0,"0,0");
	ok(chown(1,1,$filename),"set 1,1");
	@stat = stat($filename);
	ok($stat[4] == 1 && $stat[5] == 1,"1,1");
}

ok(unlink($filename), "removed $filename");

done_testing();
