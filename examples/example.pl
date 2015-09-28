#!/usr/bin/env perl
use strict;
use warnings;

use Data::Dumper;

#use blib;
use Fuse qw(fuse_get_context);
use POSIX qw(ENOENT EISDIR EINVAL);

my (%files) = (
	'.' => {
		type => 0040,
		mode => 0755,
		ctime => time()-1000
	},
	a => {
		cont => "File 'a'.\n",
		type => 0100,
		mode => 0755,
		ctime => time()-2000
	},
	b => {
		cont => "This is file 'b'.\n",
		type => 0100,
		mode => 0644,
		ctime => time()-1000
	},
	me => {
		size => 45,
		type => 0100,
		mode => 0644,
		ctime => time()-1000
	},
);

sub filename_fixup {
	my ($file) = shift;
	$file =~ s,^/,,;
	$file = '.' unless length($file);
	return $file;
}

sub e_getattr {
	my ($file) = filename_fixup(shift);
	$file =~ s,^/,,;
	$file = '.' unless length($file);
	return -ENOENT() unless exists($files{$file});
	my ($size) = exists($files{$file}{cont}) ? length($files{$file}{cont}) : 0;
	$size = $files{$file}{size} if exists $files{$file}{size};
	my ($modes) = ($files{$file}{type}<<9) + $files{$file}{mode};
	my ($dev, $ino, $rdev, $blocks, $gid, $uid, $nlink, $blksize) = (0,0,0,1,0,0,1,1024);
	my ($atime, $ctime, $mtime);
	$atime = $ctime = $mtime = $files{$file}{ctime};
	# 2 possible types of return values:
	#return -ENOENT(); # or any other error you care to
	#print(join(",",($dev,$ino,$modes,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)),"\n");
	return ($dev,$ino,$modes,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);
}

sub e_getdir {
	# return as many text filenames as you like, followed by the retval.
	print((scalar keys %files)."\n");
	return (keys %files),0;
}

sub e_open {
	# VFS sanity check; it keeps all the necessary state, not much to do here.
    my $file = filename_fixup(shift);
    my ($flags, $fileinfo) = @_;
    print("open called $file, $flags, $fileinfo\n");
	return -ENOENT() unless exists($files{$file});
	return -EISDIR() if $files{$file}{type} & 0040;

    my $fh = [ rand() ];

    print("open ok (handle $fh)\n");
    return (0, $fh);
}

sub e_read {
	# return an error numeric, or binary/text string.  (note: 0 means EOF, "0" will
	# give a byte (ascii "0") to the reading program)
	my ($file) = filename_fixup(shift);
    my ($buf, $off, $fh) = @_;
    print "read from $file, $buf \@ $off\n";
    print "file handle:\n", Dumper($fh);
	return -ENOENT() unless exists($files{$file});
	if(!exists($files{$file}{cont})) {
		return -EINVAL() if $off > 0;
		my $context = fuse_get_context();
		return sprintf("pid=0x%08x uid=0x%08x gid=0x%08x\n",@$context{'pid','uid','gid'});
	}
	return -EINVAL() if $off > length($files{$file}{cont});
	return 0 if $off == length($files{$file}{cont});
	return substr($files{$file}{cont},$off,$buf);
}

sub e_statfs { return 255, 1, 1, 1, 1, 2 }

# If you run the script directly, it will run fusermount, which will in turn
# re-run this script.  Hence the funky semantics.
my ($mountpoint) = "";
$mountpoint = shift(@ARGV) if @ARGV;
Fuse::main(
	mountpoint=>$mountpoint,
	getattr=>"main::e_getattr",
	getdir =>"main::e_getdir",
	open   =>"main::e_open",
	statfs =>"main::e_statfs",
	read   =>"main::e_read",
	threaded=>0
);
