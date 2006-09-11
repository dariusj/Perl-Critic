#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.20/lib/Perl/Critic/Policy/References/ProhibitDoubleSigils.pm $
#     $Date: 2006-09-10 21:18:18 -0700 (Sun, 10 Sep 2006) $
#   $Author: thaljef $
# $Revision: 663 $
# ex: set ts=8 sts=4 sw=4 expandtab
########################################################################

package Perl::Critic::Policy::References::ProhibitDoubleSigils;

use strict;
use warnings;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = 0.20;

#----------------------------------------------------------------------------

my $desc = q{Double-sigil dereference};
my $expl = [ 228 ];

#----------------------------------------------------------------------------

sub default_severity { return $SEVERITY_LOW }
sub applies_to { return 'PPI::Token::Cast' }

#----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;
    return if $elem eq q{\\};

    my $sib = $elem->snext_sibling;
    return if !$sib;
    if ( ! $sib->isa('PPI::Structure::Block') ) {
        return $self->violation( $desc, $expl, $elem );
    }
    return; #ok!
}

1;

__END__

#----------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::References::ProhibitDoubleSigils

=head1 DESCRIPTION

When dereferencing a reference, put braces around the reference to
separate the sigils.  Especially for newbies, the braces eliminate any
potential confusion about the relative precedence of the sigils.

  push @$array_ref, 'foo', 'bar', 'baz';      #not ok
  push @{ $array_ref }, 'foo', 'bar', 'baz';  #ok

  foreach ( keys %$hash_ref ){}               #not ok
  foreach ( keys %{ $hash_ref } ){}           #ok

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2006 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
