package Git::Repository::File;
our $VERSION = '0.002'; # VERSION: generated by DZP::OurPkgVersion

use strict;
use warnings FATAL => 'all';

use parent qw(Path::Class::File);

sub _new_from_class {
    my $class = shift;
    my $repo = shift;
    my @extra = @_;

    unless ($repo->isa('Git::Repository')) {
        die 'Git::Repository';
    }
    unless ($repo->work_tree) {
        die 'work_tree';
    }

    my $self = $class->SUPER::new($repo->work_tree, @extra);
    $self->{repo} = $repo;
    return bless $self, $class;
}

sub _new_from_instance {
    my $self = shift;
    my @extra = @_;

    my $class = ref($self) || $self;
    my $repo = $self->{repo};
    $self = $self->SUPER::new(@extra);
    $self->{repo} = $repo;
    return bless $self, $class;
}

sub new {
    my $self = shift;
    my @extra = @_;

    if (ref($self)) {
        $self = $self->_new_from_instance(@extra);
    } else {
        $self = $self->_new_from_class(@extra);
    }

    return $self;
}

# New methods (relative to Path::Class::File)

sub add {
    my $self = shift;
    my @args = @_;
    $self->{repo}->run('add', @args, $self);
    return $self;
}

sub commit {
    my $self = shift;
    my @args = @_;
    $self->{repo}->run('commit', @args, $self);
    return $self;
}

# Overridden methods (relative to Path::Class::File)

sub remove {
    my $self = shift;
    my @args = @_;
    $self->{repo}->run('rm', @args, $self);
    return not -e $self;
}

1;

__END__

=pod

=head1 NAME

Git::Repository::File - Objects representing files in a Git::Repository

=head1 VERSION

version 0.002

=head1 SYNOPSIS

    use Git::Repository qw(File);

    my $repo = Git::Repository->new();
    my $file = $repo->file('lib', 'Git', 'Repository', 'File.pm');

    # provides Path::Class::File API
    $file->openw->say('line one');

    # also provides add, commit, and remove
    $file->add;
    $file->commit('-m', "commit $file");
    $file->remove;
    $file->commit('-m', "removed $file");

=head1 DESCRIPTION

C<Git::Repository::File> mostly wraps <Path::Class::File>.

=head1 METHODS

L<Git::Repository::File|Git::Repository::File> adds the
following methods on to a L<Path::Class::File|Path::Class::File>-like API:

=head2 add(@options)

Does something....

=head1 SEE ALSO

L<Git::Repository|Git::Repository>,
L<Git::Repository::Plugin::File|Git::Repository::Plugin::File>,
L<Path::Class::File|Path::Class::File>

=head1 AUTHOR

Nathaniel G. Nutter <nnutter@cpan.org>

=head1 COPYRIGHT

Copyright 2013 - Nathaniel G. Nutter

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
