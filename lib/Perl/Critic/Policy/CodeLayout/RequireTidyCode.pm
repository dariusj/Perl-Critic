##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-1.06/lib/Perl/Critic/Policy/CodeLayout/RequireTidyCode.pm $
#     $Date: 2007-06-27 23:50:20 -0700 (Wed, 27 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1709 $
##############################################################################

package Perl::Critic::Policy::CodeLayout::RequireTidyCode;

use strict;
use warnings;
use English qw(-no_match_vars);
use Perl::Critic::Utils qw{ :characters :severities };
use base 'Perl::Critic::Policy';

our $VERSION = 1.06;

#-----------------------------------------------------------------------------

my $desc = q{Code is not tidy};
my $expl = [ 33 ];

#-----------------------------------------------------------------------------

sub supported_parameters { return qw( perltidyrc )      }
sub default_severity  { return $SEVERITY_LOWEST      }
sub default_themes    { return qw(core pbp cosmetic) }
sub applies_to        { return 'PPI::Document'       }

#-----------------------------------------------------------------------------

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    my (%config) = @_;

    #Set configuration if defined
    $self->{_perltidyrc} = $config{perltidyrc};
    if (defined $self->{_perltidyrc} && $self->{_perltidyrc} eq $EMPTY) {
        $self->{_perltidyrc} = \$EMPTY;
    }

    return $self;
}

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;

    # If Perl::Tidy is missing, silently pass this test
    eval { require Perl::Tidy; };
    return if $EVAL_ERROR;

    # Perl::Tidy seems to produce slightly different output, depending
    # on the trailing whitespace in the input.  As best I can tell,
    # Perl::Tidy will truncate any extra trailing newlines, and if the
    # input has no trailing newline, then it adds one.  But when you
    # re-run it through Perl::Tidy here, that final newline gets lost,
    # which causes the policy to insist that the code is not tidy.
    # This only occurs when Perl::Tidy is writing the output to a
    # scalar, but does not occur when writing to a file.  I may
    # investigate further, but for now, this seems to do the trick.

    my $source = $doc->serialize();
    $source =~ s{ \s+ \Z}{\n}mx;

    # Remove the shell fix code from the top of program, if applicable
    my $shebang_re = qr/\#![^\015\012]+[\015\012]+/xms;
    my $shell_re   = qr/eval [ ] 'exec [ ] [^\015\012]* [ ] \$0 [ ] \${1\+"\$@"}'
                        [ \t]*[\012\015]+ [ \t]*if[^\015\012]+[\015\012]+/xms;
    $source =~ s/\A ($shebang_re) $shell_re /$1/xms;

    my $dest    = $EMPTY;
    my $stderr  = $EMPTY;


    # Perl::Tidy gets confused if @ARGV has arguments from
    # another program.  Also, we need to override the
    # stdout and stderr redirects that the user may have
    # configured in their .perltidyrc file.
    local @ARGV = qw(-nst -nse);  ## no critic

    # Trap Perl::Tidy errors, just in case it dies
    eval {
        Perl::Tidy::perltidy(
            source      => \$source,
            destination => \$dest,
            stderr      => \$stderr,
            defined $self->{_perltidyrc} ? (perltidyrc => $self->{_perltidyrc}) : (),
       );
    };

    if ($stderr || $EVAL_ERROR) {

        # Looks like perltidy had problems
        return $self->violation( 'perltidy had errors!!', $expl, $elem );
    }

    if ( $source ne $dest ) {
        return $self->violation( $desc, $expl, $elem );
    }

    return;    #ok!
}

1;

#-----------------------------------------------------------------------------

__END__

=pod

=head1 NAME

Perl::Critic::Policy::CodeLayout::RequireTidyCode

=head1 DESCRIPTION

Conway does make specific recommendations for whitespace and
curly-braces in your code, but the most important thing is to adopt a
consistent layout, regardless of the specifics.  And the easiest way
to do that is to use L<Perl::Tidy>.  This policy will complain if
you're code hasn't been run through Perl::Tidy.

=head1 CONFIGURATION

This policy can be configured to tell Perl::Tidy to use a particular
F<perltidyrc> file or no configuration at all.  By default, Perl::Tidy is told
to look in its default location for configuration.  Perl::Critic can be told to
tell Perl::Tidy to use a specific configuration file by putting an entry in a
F<.perlcriticrc> file like this:

  [CodeLayout::RequireTidyCode]
  perltidyrc = /usr/share/perltidy.conf

As a special case, setting C<perltidyrc> to the empty string tells
Perl::Tidy not to load any configuration file at all and just use
Perl::Tidy's own default style.

  [CodeLayout::RequireTidyCode]
  perltidyrc =

=head1 NOTES

L<Perl::Tidy> is not included in the Perl::Critic distribution.  The
latest version of Perl::Tidy can be downloaded from CPAN.  If
Perl::Tidy is not installed, this policy is silently ignored.

=head1 SEE ALSO

L<Perl::Tidy>

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
