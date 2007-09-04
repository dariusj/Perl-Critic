#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/Perl-Critic-1.073/t/13_bundled_policies.t $
#     $Date: 2007-09-02 20:07:03 -0500 (Sun, 02 Sep 2007) $
#   $Author: clonezone $
# $Revision: 1854 $
##############################################################################

use strict;
use warnings;

use Test::More (tests => 1);

use Perl::Critic::UserProfile;
use Perl::Critic::PolicyFactory (-test => 1);

# common P::C testing tools
use Perl::Critic::TestUtils qw(bundled_policy_names);
Perl::Critic::TestUtils::block_perlcriticrc();

#-----------------------------------------------------------------------------

my $profile = Perl::Critic::UserProfile->new();
my $factory = Perl::Critic::PolicyFactory->new( -profile => $profile );
my @found_policies = sort map { ref $_ } $factory->create_all_policies();
my $test_label = 'successfully loaded policies matches MANIFEST';
is_deeply( \@found_policies, [bundled_policy_names()], $test_label );

#-----------------------------------------------------------------------------

# ensure we run true if this test is loaded by
# t/13_bundled_policies.t_without_optional_dependencies.t
1;

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
