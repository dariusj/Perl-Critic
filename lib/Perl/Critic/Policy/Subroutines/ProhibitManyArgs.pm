##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/Subroutines/ProhibitManyArgs.pm $
#     $Date: 2007-12-16 13:14:12 -0600 (Sun, 16 Dec 2007) $
#   $Author: clonezone $
# $Revision: 2047 $
##############################################################################

package Perl::Critic::Policy::Subroutines::ProhibitManyArgs;

use strict;
use warnings;
use Readonly;

use File::Spec;
use List::Util qw(first);
use List::MoreUtils qw(uniq any);
use English qw(-no_match_vars);
use Carp;

use Perl::Critic::Utils qw{ :booleans :severities split_nodes_on_comma };
use base 'Perl::Critic::Policy';

our $VERSION = '1.081_002';

#-----------------------------------------------------------------------------

Readonly::Scalar my $DEFAULT_MAX_ARGUMENTS => 5;
Readonly::Scalar my $AT => q{@}; ##no critic(Interpolation)
Readonly::Scalar my $AT_ARG => q{@_}; ##no critic(Interpolation)

Readonly::Scalar my $DESC => q{Too many arguments};
Readonly::Scalar my $EXPL => [182];

#-----------------------------------------------------------------------------

sub supported_parameters { return qw(max_arguments) }
sub default_severity     { return $SEVERITY_MEDIUM         }
sub default_themes       { return qw( core pbp maintance ) }
sub applies_to           { return 'PPI::Statement::Sub'    }

#-----------------------------------------------------------------------------

sub initialize_if_enabled {
    my ($self, $config) = @_;

    #Set configuration if defined
    $self->{_max_arguments} =
            defined $config->{max_arguments}
        &&  $config->{max_arguments} =~ m/(\d+)/xms

            ? $1 : $DEFAULT_MAX_ARGUMENTS;

    return $TRUE;
}

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;

    # forward declaration?
    return if !$elem->block;

    my $num_args;
    if ($elem->prototype) {
       # subtract two for the "()" on the prototype 
       $num_args = -2 + length $elem->prototype;
    } else {
       $num_args = _count_args($elem->block->schildren);
    }

    if ($self->{_max_arguments} < $num_args) {
       return $self->violation( $DESC, $EXPL, $elem );
    }
    return;  # OK
}

sub _count_args {
    my @statements = @_;

    # look for these patterns:
    #    " ... = @_;"    => then examine previous variable list
    #    " ... = shift;" => counts as one arg, then look for more
   
    return 0 if !@statements;  # no statements

    my $statement = shift @statements;
    my @elements = $statement->schildren();
    my $operand = pop @elements;
    while ($operand && $operand->isa('PPI::Token::Structure') && q{;} eq $operand) {
       $operand = pop @elements;
    }
    return 0 if !$operand;

    #print "pulled off last, remaining: '@elements'\n";
    my $operator = pop @elements;
    return 0 if !$operator;
    return 0 if !$operator->isa('PPI::Token::Operator');
    return 0 if q{=} ne $operator;

    if ($operand->isa('PPI::Token::Magic') && $AT_ARG eq $operand) {
       return _count_list_elements(@elements);
    } elsif ($operand->isa('PPI::Token::Word') && 'shift' eq $operand) {
       return 1 + _count_args(@statements);
    }

    return 0;
}

sub _count_list_elements {
   my @elements = @_;

   my $list = pop @elements;
   return 0 if !$list;
   return 0 if !$list->isa('PPI::Structure::List');
   my @inner = $list->schildren;
   if (1 == @inner && $inner[0]->isa('PPI::Statement::Expression')) {
      @inner = $inner[0]->schildren;
   }
   return scalar split_nodes_on_comma(@inner);
}

1;

__END__

#-----------------------------------------------------------------------------

=pod

=for stopwords refactored

=head1 NAME

Perl::Critic::Policy::Subroutines::ProhibitManyArgs

=head1 DESCRIPTION

Subroutines that expect large numbers of arguments are hard to use
because programmers routinely have to look at documentation to
remember the order of those arguments.  Many arguments is often a sign
that a subroutine should be refactored or that an object should be
passed to the routine.

=head1 CONFIGURATION

By default, this policy allows up to 5 arguments without warning.  To
change this threshold, put entries in a F<.perlcriticrc> file like
this:

  [Subroutines::ProhibitManyArgs]
  max_arguments = 6

=head1 CAVEATS

PPI doesn't currently detect anonymous subroutines, so we don't check those.
This should just work when PPI gains that feature.

We don't check for C<@ARG>, the alias for C<@_> from English.pm.  That's
deprecated anyway.

=head1 CREDITS

Initial development of this policy was supported by a grant from the Perl Foundation.

=head1 AUTHOR

Chris Dolan <cdolan@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2007 Chris Dolan.  Many rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
