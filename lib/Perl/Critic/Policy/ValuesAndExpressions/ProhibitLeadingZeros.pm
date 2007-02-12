##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-1.02/lib/Perl/Critic/Policy/ValuesAndExpressions/ProhibitLeadingZeros.pm $
#     $Date: 2007-02-11 22:57:01 -0800 (Sun, 11 Feb 2007) $
#   $Author: thaljef $
# $Revision: 1228 $
##############################################################################

package Perl::Critic::Policy::ValuesAndExpressions::ProhibitLeadingZeros;

use strict;
use warnings;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = 1.02;

#-----------------------------------------------------------------------------

my $leading_rx = qr{\A [+-]? (?: 0+ _* )+ [1-9]}mx;
my $desc       = q{Integer with leading zeros};
my $expl       = [ 58 ];

#-----------------------------------------------------------------------------

sub supported_parameters { return() }
sub default_severity { return $SEVERITY_HIGHEST    }
sub default_themes    { return qw( core pbp bugs )     }
sub applies_to       { return 'PPI::Token::Number' }

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;

    if ( $elem =~ $leading_rx ) {
        return $self->violation( $desc, $expl, $elem );
    }
    return;    #ok!
}

1;

__END__

#-----------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::ProhibitLeadingZeros

=head1 DESCRIPTION

Perl interprets numbers with leading zeros as octal.  If that's what
you really want, its better to use C<oct> and make it obvious.

  $var = 041;     #not ok, actually 33
  $var = oct(41); #ok

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2007 Jeffrey Ryan Thalhammer.  All rights reserved.

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
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
