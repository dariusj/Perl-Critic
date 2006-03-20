#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Violation.pm $
#     $Date: 2006-03-06 22:57:42 -0800 (Mon, 06 Mar 2006) $
#   $Author: thaljef $
# $Revision: 315 $
########################################################################

package Perl::Critic::Violation;

use strict;
use warnings;
use Carp;
use IO::String;
use Pod::PlainText;
use Perl::Critic::Utils;
use String::Format qw(stringf);
use English qw(-no_match_vars);
use overload q{""} => 'to_string';
use UNIVERSAL qw(isa);

our $VERSION = '0.14_02';
$VERSION = eval $VERSION;    ## no critic

#Class variables...
our $FORMAT = "%m at line %l, column %c. %e.\n"; #Default stringy format
my %DIAGNOSTICS = ();  #Cache of diagnositc messages

#----------------------------------------------------------------------------

sub import {

    my $caller = caller;
    return if exists $DIAGNOSTICS{$caller};

    if ( my $file = _mod2file($caller) ) {
	if ( my $diags = _get_diagnostics($file) ) {
	       $DIAGNOSTICS{$caller} = $diags;
	       return; #ok!
	   }
    }

    #If we get here, then we couldn't get diagnostics
    my $no_diags = "    No diagnostics available\n";
    $DIAGNOSTICS{$caller} = $no_diags;

    return; #ok!
}

#----------------------------------------------------------------------------

sub new {
    my ( $class, $desc, $expl, $elem, $sev ) = @_;

    #Check arguments to help out developers who might
    #be creating new Perl::Critic::Policy modules.

    if ( @_ != 5 ) {
        my $msg = 'Wrong number of args to Violation->new()';
        croak $msg;
    }

    if ( ! isa( $_[3], 'PPI::Element' ) ) {
        my $msg = '3rd arg to Violation->new() must be a PPI::Element';
        croak $msg;
    }

    #Create object
    my $self = bless {}, $class;
    $self->{_description} = $desc;
    $self->{_explanation} = $expl;
    $self->{_severity}    = $sev;
    $self->{_policy}      = caller;
    $self->{_location}    = $elem->location() || [0,0];

    my $stmnt = $elem->statement() || $elem;
    $self->{_source}      = $stmnt->content()  || $EMPTY;


    return $self;
}

#--------------------------

sub sort_by_location {
    ref $_[0] || shift; #Can call as object or class method
    #TODO: What if $a or $b are not Violation objects?
    return sort {   (($a->location->[0] || 0) <=> ($b->location->[0] || 0))
                 || (($a->location->[1] || 0) <=> ($b->location->[1] || 0)) } @_
}

#---------------------------

sub sort_by_severity {
    ref $_[0] || shift; #Can call as object or class method
    #TODO: What if $a or $b are not Violation objects?
    return sort { ($a->severity() || 0) <=> ($b->severity() || 0) } @_;
}

#---------------------------

sub location {
    my $self = shift;
    return $self->{_location};
}

#---------------------------

sub diagnostics {
    my $self = shift;
    my $pol = $self->policy();
    return $DIAGNOSTICS{$pol};
}

#---------------------------

sub description {
    my $self = shift;
    return $self->{_description};
}

#---------------------------

sub explanation {
    my $self = shift;
    my $expl = $self->{_explanation};
    if( ref $expl eq 'ARRAY' ) {
	my $page = @{$expl} > 1 ? 'pages' : 'page';
	$page .= $SPACE . join $COMMA, @{$expl};
	$expl = "See $page of PBP";
    }
    return $expl;
}

#---------------------------

sub severity {
    my $self = shift;
    return $self->{_severity};
}

#---------------------------

sub policy {
    my $self = shift;
    return $self->{_policy};
}

#---------------------------

sub source {
     my $self = shift;
     my $source = $self->{_source};
     #Return the first line of code only.
     $source =~ m{\A ( [^\n]* ) }mx;
     return $1;
}

#---------------------------

sub to_string {
    my $self = shift;
    my %fspec = (
         'l' => $self->location->[0], 'c' => $self->location->[1],
         'm' => $self->description(), 'e' => $self->explanation(),
         'p' => $self->policy(),      'd' => $self->diagnostics(),
         's' => $self->severity(),    'r' => $self->source(),
    );
    return stringf($FORMAT, %fspec);
}

#---------------------------

sub _mod2file {
    my $module = shift;
    $module  =~ s{::}{/}mxg;
    $module .= '.pm';
    return $INC{$module} || $EMPTY;
}

#---------------------------

sub _get_diagnostics {

    my $file = shift;

    # Extract POD into a string
    my $pod_string = $EMPTY;
    my $handle     = IO::String->new( \$pod_string);
    my $parser     = Pod::PlainText->new();
    $parser->select('DESCRIPTION');
    $parser->parse_from_file($file, $handle);

    # Remove header from documentation string.
    $pod_string =~ s{ \A \s* DESCRIPTION \s* \n}{}mx;
    return $pod_string;
}

1;

#----------------------------------------------------------------------------

__END__

=head1 NAME

Perl::Critic::Violation - Represents policy violations

=head1 SYNOPSIS

  use PPI;
  use Perl::Critic::Violation;

  my $elem = $doc->child(0);      #$doc is a PPI::Document object
  my $desc = 'Offending code';    #Describe the violation
  my $expl = [1,45,67];           #Page numbers from PBP
  my $sev  = 5;                   #Severity level of this violation

  my $vio  = Perl::Critic::Violation->new($desc, $expl, $node, $sev);

=head1 DESCRIPTION

Perl::Critic::Violation is the generic representation of an individual
Policy violation.  Its primary purpose is to provide an abstraction
layer so that clients of L<Perl::Critic> don't have to know anything
about L<PPI>.  The C<violations> method of all L<Perl::Critic::Policy>
subclasses must return a list of these Perl::Critic::Violation
objects.

=head1 CONSTRUCTOR

=over 8

=item C<new( $description, $explanation, $element, $severity )>

Returns a reference to a new C<Perl::Critic::Violation> object. The
arguments are a description of the violation (as string), an
explanation for the policy (as string) or a series of page numbers in
PBP (as an ARRAY ref), a reference to the L<PPI> element that caused
the violation, and the severity of the violation (as an integer).

=back

=head1 METHODS

=over 8

=item C<description()>

Returns a brief description of the policy that has been violated as a string.

=item C<explanation()>

Returns an explanation of the policy as a string or as reference to
an array of page numbers in PBP.

=item C<location()>

Returns a two-element list containing the line and column number where
this Violation occurred.

=item C<severity()>

Returns the severity of this Violation as an integer ranging from 1 to
5, where 5 is the "most" severe.

=item C<sort_by_severity( @violation_objects )>

If you need to sort Violations by severity, use this handy routine:

   @sorted = Perl::Critic::Violation::sort_by_severity(@violations);

=item C<sort_by_location( @violation_objects )>

If you need to sort Violations by location, use this handy routine:

   @sorted = Perl::Critic::Violation::sort_by_location(@violations);

=item C<diagnostics()>

Returns a formatted string containing a full discussion of the
motivation for and details of the Policy module that created this
Violation.  This information is automatically extracted from the
C<DESCRIPTION> section of the Policy module's POD.

=item C<policy()>

Returns the name of the L<Perl::Critic::Policy> that created this
Violation.

=item C<source()>

Returns the string of source code that caused this exception.  If the
code spans multiple lines (e.g. multi-line statements, subroutines or
other blocks), then only the first line will be returned.

=item C<to_string()>

Returns a string representation of this violation.  The content of the
string depends on the current value of the C<$FORMAT> package
variable.  See L<"OVERLOADS"> for the details.

=back

=head1 FIELDS

=over 8

=item C<$Perl::Critic::Violation::FORMAT>

Sets the format for all Violation objects when they are evaluated in
string context.  The default is C<'%d at line %l, column %c. %e'>.
See L<"OVERLOADS"> for formatting options.  If you want to change
C<$FORMAT>, you should probably localize it first.

=back

=head1 OVERLOADS

Perl::Critic::Violation overloads the C<""> operator to produce neat
little messages when evaluated in string context.  The format depends
on the current value of the C<$FORMAT> package variable.

Formats are a combination of literal and escape characters similar to
the way C<sprintf> works.  If you want to know the specific formatting
capabilities, look at L<String::Format>. Valid escape characters are:

  Escape    Meaning
  -------   -----------------------------------------------------------------
  %m        Brief description of the violation
  %f        Name of the file where the violation occurred.
  %l        Line number where the violation occurred
  %c        Column number where the violation occurred
  %e        Explanation of violation or page numbers in PBP
  %d        Full diagnostic discussion of the violation
  %r        The string of source code that caused the violation
  %p        Name of the Policy module that created the violation
  %s        The severity level of the violation

Here are some examples:

  $Perl::Critic::Violation::FORMAT = "%m at line %l, column %c.\n";
  #looks like "Mixed case variable name at line 6, column 23."

  $Perl::Critic::Violation::FORMAT = "%m near '%r'\n";
  #looks like "Mixed case variable name near 'my $theGreatAnswer = 42;'"

  $Perl::Critic::Violation::FORMAT = "%l:%c:%p\n";
  #looks like "6:23:NamingConventions::ProhibitMixedCaseVars"

  $Perl::Critic::Violation::FORMAT = "%m at line %l. %e. \n%d\n";
  #looks like "Mixed case variable name at line 6.  See page 44 of PBP.
                    Conway's recommended naming convention is to use lower-case words
                    separated by underscores.  Well-recognized acronyms can be in ALL
                    CAPS, but must be separated by underscores from other parts of the
                    name."

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2006 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
