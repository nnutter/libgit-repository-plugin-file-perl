use strict;
use warnings;

use Test::More tests => 6;

use Git::Repository qw(File Test);
use Path::Class qw();

my $repo = Git::Repository->new_tmp_repo();

my $method = 'opena';
my $gr_file = $repo->file($method);
my $pc_file = Path::Class::file($repo->work_tree, $method);

ok(!-f $gr_file, 'file does not exist yet');
$gr_file->touch;
ok(-f $gr_file, 'touched file exists');

my @content = ('line one', 'line two', 'line three');
{ # scope so file closes
    $gr_file->openw->say(join("\n", @content[0..1]));
}

{
    my @lines = $gr_file->slurp(chomp => 1);
    is(scalar(@lines), 2, 'two lines written');
}

{ # scope so file closes
    $gr_file->opena->say($content[2]);
}

{
    my @lines = $gr_file->slurp(chomp => 1);
    is(scalar(@lines), 3, 'third line appended');
    is_deeply(\@lines, \@content, 'slurped lines match');
}

{
    my @lines = $gr_file->openr->getlines;
    chomp @lines;
    is_deeply(\@lines, \@content, 'getlines match');
}
