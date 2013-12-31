use strict;
use warnings;

use Test::More tests => 2;
use Test::Fatal qw(exception);

use Git::Repository qw(File Test);

my $repo = Git::Repository->new_tmp_repo('--bare');

is($repo->work_tree, undef, 'bare repo has no work_tree');
like(exception { $repo->file('foo') }, qr/work_tree/,
    'exception thrown when there is no work_tree');
