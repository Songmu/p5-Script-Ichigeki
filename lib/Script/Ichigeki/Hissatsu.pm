package Script::Ichigeki::Hissatsu;
use Mouse;
use Mouse::Util::TypeConstraints;

use Time::Piece;
use Path::Class qw/file/;
use IO::Prompt::Simple qw/prompt/;
use IO::Handle;
use File::Tee qw/tee/;

subtype 'Time::Piece' => as Object => where { $_->isa('Time::Piece') };
coerce 'Time::Piece'
    => from 'Str',
    => via {
        my $t = Time::Piece->strptime($_, '%Y-%m-%d');
        die "Invalie time format: [$_] .(format should be '%Y-%m-%d'.)" unless $t;
        localtime($t);
    };

has exec_date => (
    is      => 'ro',
    isa     => 'Time::Piece',
    coerce => 1,
    default => sub {
        localtime(Time::Piece->strptime(localtime->ymd, "%Y-%m-%d"));
    }
);

has confirm_dialog => (
    is      => 'ro',
    default => 1,
);

has log_file_postfix => (
    is      => 'ro',
    default => '.log',
);

has script => (
    is       => 'ro',
    default  => sub { file($0) },
);

has is_running => (
    is       => 'rw',
);

has in_use => (
    is => 'ro'
);

no Mouse;

sub exiting {
    die shift ."\n";
}

sub execute {
    my $self = shift;

    my $now   = localtime;
    my $today = localtime(Time::Piece->strptime($now->ymd, "%Y-%m-%d"));
    exiting $self->exec_date .' is not today!' unless $self->exec_date == $today;

    exiting sprintf('execute log file [%s] is alredy exists!', $self->log_file) if -f $self->log_file;

    if ($self->confirm_dialog) {
        my $answer = prompt('Do you really execute `' . $self->script->basename . '` ? (y/n)');
        exiting 'canceled.' unless $answer =~ /^y(?:es)?$/i;
    }

    STDOUT->autoflush;
    STDERR->autoflush;

    my $fh = $self->log_file->open('>>');
    $fh->print(join "\n",
        '# This file is generated dy Script::Icigeki.',
        "start: @{[localtime->datetime]}",
        '---', ''
    );

    $self->is_running(1);
    tee STDOUT, $fh;
    tee STDERR, $fh;
}

{
    my  $_log_file;
    sub log_file {
        my $self = shift;
        $_log_file ||= do {
            my $script = $self->script;
            $script->dir->file('.' . $script->basename . $self->log_file_postfix);
        };
    }
}

sub end {
    my $self = shift;
    if ($self->is_running) {
        my $now = localtime->datetime;
        my $fh = $self->log_file->open('>>');
        $fh->print(join "\n",
            '---',
            "end: $now",'',
        );
    }
}

sub DEMOLISH {
    shift->end;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Script::Ichigeki::Hissatsu - Perl extention to do something

=head1 VERSION

This document describes Script::Ichigeki::Hissatsu version 0.01.

=head1 SYNOPSIS

    use Script::Ichigeki::Hissatsu;

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Masayuki Matsuki E<lt>y.songmu@gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Masayuki Matsuki. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
