##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/ControlStructures/ProhibitUntilBlocks.pm $
#     $Date: 2008-05-24 14:54:46 -0500 (Sat, 24 May 2008) $
#   $Author: clonezone $
# $Revision: 2401 $
##############################################################################

package Perl::Critic::Policy::ControlStructures::ProhibitUntilBlocks;

use strict;
use warnings;
use Readonly;

use Perl::Critic::Utils qw{ :severities };
use base 'Perl::Critic::Policy';

our $VERSION = '1.084';

#-----------------------------------------------------------------------------

Readonly::Scalar my $DESC => q{"until" block used};
Readonly::Scalar my $EXPL => [ 97 ];

#-----------------------------------------------------------------------------

sub supported_parameters { return ()                    }
sub default_severity     { return $SEVERITY_LOW         }
sub default_themes       { return qw(core pbp cosmetic) }
sub applies_to           { return 'PPI::Statement'      }

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;
    if ( $elem->first_element() eq 'until' ) {
        return $self->violation( $DESC, $EXPL, $elem );
    }
    return;    #ok!
}

1;

__END__

#-----------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::ControlStructures::ProhibitUntilBlocks - Write C<while(! $condition)> instead of C<until($condition)>.

=head1 AFFILIATION

This Policy is part of the core L<Perl::Critic> distribution.


=head1 DESCRIPTION

Conway discourages using C<until> because it leads to double-negatives
that are hard to understand.  Instead, reverse the logic and use C<while>.

  until($condition)     { do_something() } #not ok
  until(! $no_flag)     { do_something() } #really bad
  while( ! $condition)  { do_something() } #ok

This Policy only covers the block-form of C<until>.  For the postfix
variety, see C<ProhibitPostfixControls>.


=head1 CONFIGURATION

This Policy is not configurable except for the standard options.


=head1 SEE ALSO

L<Perl::Critic::Policy::ControlStructures::ProhibitPostfixControls>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2008 Jeffrey Ryan Thalhammer.  All rights reserved.

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
