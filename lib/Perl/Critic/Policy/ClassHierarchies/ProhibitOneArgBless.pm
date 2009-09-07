##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/Perl-Critic-backlog/lib/Perl/Critic/Policy/ClassHierarchies/ProhibitOneArgBless.pm $
#     $Date: 2009-09-07 16:19:21 -0500 (Mon, 07 Sep 2009) $
#   $Author: clonezone $
# $Revision: 3629 $
##############################################################################

package Perl::Critic::Policy::ClassHierarchies::ProhibitOneArgBless;

use 5.006001;
use strict;
use warnings;
use Readonly;

use Perl::Critic::Utils qw{ :booleans :severities :classification :ppi };
use base 'Perl::Critic::Policy';

our $VERSION = '1.105';

#-----------------------------------------------------------------------------

Readonly::Scalar my $DESC => q{One-argument "bless" used};
Readonly::Scalar my $EXPL => [ 365 ];

#-----------------------------------------------------------------------------

sub supported_parameters { return ()                  }
sub default_severity     { return $SEVERITY_HIGHEST   }
sub default_themes       { return qw( core pbp bugs ) }
sub applies_to           { return 'PPI::Token::Word'  }

#-----------------------------------------------------------------------------

sub violates {
    my ($self, $elem, undef) = @_;

    return if $elem ne 'bless';
    return if ! is_function_call($elem);

    if( scalar parse_arg_list($elem) == 1 ) {
        return $self->violation( $DESC, $EXPL, $elem );
    }
    return; #ok!
}

1;

#-----------------------------------------------------------------------------

__END__

=pod

=head1 NAME

Perl::Critic::Policy::ClassHierarchies::ProhibitOneArgBless - Write C<bless {}, $class;> instead of just C<bless {};>.


=head1 AFFILIATION

This Policy is part of the core L<Perl::Critic|Perl::Critic>
distribution.


=head1 DESCRIPTION

Always use the two-argument form of C<bless> because it allows
subclasses to inherit your constructor.

    sub new {
        my $class = shift;
        my $self = bless {};          # not ok
        my $self = bless {}, $class;  # ok
        return $self;
    }


=head1 CONFIGURATION

This Policy is not configurable except for the standard options.


=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2009 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
