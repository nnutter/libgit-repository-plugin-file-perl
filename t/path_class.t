use strict;
use warnings;

use Test::More;

use Class::Inspector qw();
use Git::Repository qw(File Test);
use Git::Repository::File;
use Path::Class qw();

# blacklist some methods because they require more nuanced testing
my @methods = grep {
    1
    && $_ ne 'carp'
    && $_ ne 'confess'
    && $_ ne 'croak'
    && $_ ne 'fastcwd'
    && $_ ne 'new'
    && $_ ne 'opena'
    && $_ ne 'openr'
    && $_ ne 'openw'
    && $_ ne 'touch'
} @{ Class::Inspector->methods('Path::Class::File', 'public') };
plan tests => scalar(@methods);


for my $method (@methods) {
    subtest $method => sub {
        plan tests => 3;

        my $repo = Git::Repository->new_tmp_repo();

        my $gr_file = $repo->file($method);
        my $pc_file = Path::Class::file($repo->work_tree, $method);

        my @args = args($method, $pc_file);

        set_up($method, $repo, $pc_file);
        my $gr_result = $gr_file->$method(@args);

        set_up($method, $repo, $pc_file);
        my $pc_result = $pc_file->$method(@args);

        my $equivalent_types = (
            ref($gr_result) eq 'Git::Repository::File' && ref($pc_result) eq 'Path::Class::File'
            || ref($gr_result) eq ref($pc_result)
        );
        ok($equivalent_types, "types are equivalent in scalar context");

        is($gr_result, $pc_result, "value matched in scalar context");

        set_up($method, $repo, $pc_file);
        my @gr_results = $gr_file->$method(@args);

        set_up($method, $repo, $pc_file);
        my @pc_results = $pc_file->$method(@args);

        is_deeply(\@gr_results, \@pc_results, "values matched in list context");
    };
}

sub set_up {
    my ($method_name, $repo, $pc_file) = @_;

    if (grep { $method_name eq $_ } qw(copy_to resolve)) {
        $pc_file->touch;
    } elsif ($method_name eq 'slurp') {
        $pc_file->openw->say('hello');
    } elsif ($method_name eq 'remove') {
        $pc_file->touch;
        $repo->run('add', $pc_file);
        $repo->run('commit', '-m', "add $pc_file", $pc_file);
    }
}

sub args {
    my ($method_name, $pc_file) = @_;

    if (grep { $method_name eq $_ } qw(copy_to move_to)) {
        return $pc_file->absolute . '_' . $method_name;
    } elsif ($method_name eq 'spew') {
        return 'hello';
    } elsif (grep { $method_name eq $_ } qw(as_foreign new_foreign)) {
        return 'Win32', 'hello';
    } elsif (grep { $method_name eq $_ } qw(traverse traverse_if)) {
        return sub {};
    }

    return;
}
