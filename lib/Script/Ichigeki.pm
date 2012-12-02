package Script::Ichigeki;
use 5.008_001;
use strict;
use warnings;
our $VERSION = '0.01';

use Script::Ichigeki::Hissatsu;

use parent qw/Exporter/;
our @EXPORT = qw/ichigeki/;

sub import {
    if ($_[1] && $_[1] eq '-ichigeki') {
        shift; shift;
        ichigeki(@_, in_use => 1);
    }
    else {
        goto &Exporter::import;
    }
}

{
    my $_HISSATSU;
    sub ichigeki {
        $_HISSATSU = Script::Ichigeki::Hissatsu->new(@_);
        $_HISSATSU->execute;
    }
}

1;
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
