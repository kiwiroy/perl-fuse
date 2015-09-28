use strict;
use warnings;
use File::Spec::Functions qw{catdir};
use test::helper qw($_real $_point);
use Test::More;
my (@names) = sort
  qw{abc def ghi jkl mno pqr stu jlk sfdaljk sdfakjlsdfa kjldsf kjl;sdf
     akjl;asdf klj;asdf
     lkjsdflkjsdfkjlsdfakjsdfakjlsadfkjl;asdfklj;asdfkjl;asdfklj;asdfkjl;asdfkjlasdflkj;sadf};

ok(chdir($_real), 'change directory');

# create entries
foreach my $fname (@names) {
    open(my $file, '>', $fname);
    close($file);
}

# make sure they exist in real dir
foreach my $n(@names) {
  my $rname = catdir $_real, $n;
  ok(-e $rname, "entry $n");
}

# make sure they exist in fuse dir
foreach my $n(@names) {
  my $rname = catdir $_point, $n;
  ok(-e $rname, "entry $n");
}

# remove them
map { ok(unlink($_), "removed $_") } @names;

done_testing();
