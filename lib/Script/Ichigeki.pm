package Script::Ichigeki;
use 5.008_001;
use strict;
use warnings;

use Time::Piece;
use Path::Class qw/file/;
use IO::Prompt::Simple qw/prompt/;
use IO::Handle;
use File::Tee qw/tee/;

use Mouse;
use Mouse::Util::TypeConstraints;

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
    required => 1,
);

has is_running => (
    is       => 'rw',
);

no Mouse;

sub exiting {
    warn shift;
    exit(1);
}

our $SELF;
sub import {
    my $pkg = shift;
    my %args = @_;

    exiting 'Already running!' if $SELF;

    $args{script} = file($0);
    $SELF = $pkg->new(%args);

    my $now   = localtime;
    my $today = localtime(Time::Piece->strptime($now->ymd, "%Y-%m-%d"));
    exiting $SELF->exec_date .' is not today!' unless $SELF->exec_date == $today;

    exiting sprintf('execute log file [%s] is exists!', $SELF->log_file) if -f $SELF->log_file;

    if ($SELF->confirm_dialog) {
        my $answer = prompt('Do you really execute `' . $SELF->script->basename . '` ? (y/n)');
        exiting 'canceled.' unless $answer =~ /^y(?:es)?$/i;
    }

    STDOUT->autoflush;
    STDERR->autoflush;

    open STDERR, ">&", *STDOUT;
    my $fh = $SELF->log_file->openw;
    $fh->print(join "\n",
        '# This file is generate dy Script::Icigeki',
        "start: $now",
        '---', ''
    );

    $SELF->is_running(1);
    tee STDOUT, $fh;
}

{
    my  $_log_file;
    sub log_file {
        my $self = shift;
        $_log_file ||= do {
            my $script = $self->script;
            file($script->dir . '/.' . $script->basename . $self->log_file_postfix);
        };
    }
}

END {
    if ($SELF->is_running) {
        my $now = localtime;
        my $fh = $SELF->log_file->openw;
        $fh->print(join "\n",
            '---',
            "start: $now",'',
        );
    }
}

__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Script::Ichigeki - Perl extention to do something

=head1 VERSION

This document describes Script::Ichigeki version 0.01.

=head1 SYNOPSIS

    use Script::Ichigeki;

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
