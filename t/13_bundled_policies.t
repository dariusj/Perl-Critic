#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/13_bundled_policies.t $
#     $Date: 2008-03-16 17:40:45 -0500 (Sun, 16 Mar 2008) $
#   $Author: clonezone $
# $Revision: 2187 $
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
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
