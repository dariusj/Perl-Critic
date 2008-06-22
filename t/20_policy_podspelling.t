#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/20_policy_podspelling.t $
#     $Date: 2008-06-21 19:57:54 -0700 (Sat, 21 Jun 2008) $
#   $Author: clonezone $
# $Revision: 2464 $
##############################################################################

use 5.006001;
use strict;
use warnings;
use Test::More tests => 4;

# common P::C testing tools
use Perl::Critic::TestUtils qw(pcritique);
Perl::Critic::TestUtils::block_perlcriticrc();

my $code;
my $policy = 'Documentation::PodSpelling';
my %config;
my $can_podspell =
        eval {require Pod::Spell}
    &&  can_determine_spell_command()
    &&  can_run_spell_command();

sub can_determine_spell_command {
    my $policy = Perl::Critic::Policy::Documentation::PodSpelling->new();
    $policy->initialize_if_enabled();

    return $policy->_get_spell_command_line();
}

sub can_run_spell_command {
    my $policy = Perl::Critic::Policy::Documentation::PodSpelling->new();
    $policy->initialize_if_enabled();

    return $policy->_run_spell_command( <<'END_TEST_CODE' );
=pod

=head1 Test The Spell Command

=cut
END_TEST_CODE
}

sub can_podspell {
    return $can_podspell && ! Perl::Critic::Policy::Documentation::PodSpelling->got_sigpipe();
}

#-----------------------------------------------------------------------------
SKIP: {

$code = <<'END_PERL';
=head1 Silly

=cut
END_PERL

if ( eval { pcritique($policy, \$code, \%config) } ) {
   skip 'Test environment is not English', 4
}

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
=head1 arglbargl

=cut
END_PERL

is(
    eval { pcritique($policy, \$code, \%config) },
    can_podspell() ? 1 : undef,
    'Mispelled header',
);

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
=head1 Test

arglbargl

=cut
END_PERL

is(
    eval { pcritique($policy, \$code, \%config) },
    can_podspell() ? 1 : undef,
    'Mispelled body',
);

#-----------------------------------------------------------------------------


$code = <<'END_PERL';
=for stopwords arglbargl

=head1 Test

arglbargl

=cut
END_PERL

is(
    eval { pcritique($policy, \$code, \%config) },
    can_podspell() ? 0 : undef,
    'local stopwords',
);

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
=head1 Test

arglbargl

=cut
END_PERL

{
    local $config{stop_words} = 'foo arglbargl bar';
    is(
        eval { pcritique($policy, \$code, \%config) },
        can_podspell() ? 0 : undef ,
        'global stopwords',
    );
}

} # end skip

#-----------------------------------------------------------------------------

# ensure we run true if this test is loaded by
# t/20_policy_podspelling.t_without_optional_dependencies.t
1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
