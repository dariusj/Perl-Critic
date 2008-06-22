##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Exception/Fatal/Generic.pm $
#     $Date: 2008-06-12 13:17:36 -0500 (Thu, 12 Jun 2008) $
#   $Author: clonezone $
# $Revision: 2443 $
##############################################################################

package Perl::Critic::Exception::Fatal::Generic;

use 5.006001;
use strict;
use warnings;

use Readonly;

our $VERSION = '1.087';

#-----------------------------------------------------------------------------

use Exception::Class (
    'Perl::Critic::Exception::Fatal::Generic' => {
        isa         => 'Perl::Critic::Exception::Fatal',
        description => 'A general problem was found.',
        alias       => 'throw_generic',
    },
);

#-----------------------------------------------------------------------------

Readonly::Array our @EXPORT_OK => qw< throw_generic >;

#-----------------------------------------------------------------------------


1;

__END__

#-----------------------------------------------------------------------------

=pod

=for stopwords

=head1 NAME

Perl::Critic::Exception::Fatal::Generic - A problem for which there is no specialized information.

=head1 DESCRIPTION

A general problem, e.g. I/O errors and problems that may or not be bugs.


=head1 METHODS

Only inherited ones.


=head1 AUTHOR

Elliot Shank <perl@galumph.com>

=head1 COPYRIGHT

Copyright (c) 2007-2008 Elliot Shank.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
