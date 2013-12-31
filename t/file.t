use strict;
use warnings;

use Test::More tests => 7;

use Git::Repository qw(File Test);
use Path::Class qw();

my $repo = Git::Repository->new_tmp_repo();

my @path = ('foo', 'bar');
my $pc_file = Path::Class::file($repo->work_tree, @path);

my $file = $repo->file(@path);
ok($file->isa('Git::Repository::File'), 'file returned a Git::Repository::File object');

is($file->absolute, $pc_file->absolute, 'file return same absolute path as Path::Class::File');

my $content = 'something';
my $message = 'committed something';
$file->parent->mkpath;
ok(-d $file->parent, 'parent directory exists');
$file->openw->say($content);
ok(-f $file, 'file exists');
$file->add->commit('-m', $message);

like($repo->run('log', '-n', 1, '--oneline'), qr/$message/, 'last commit contains expected message');
is($file->slurp(chomp => 1), $content, 'file contains correct content');

$file->remove;
ok(!-f $file, 'file was removed');
