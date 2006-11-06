#!perl

##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.21/t/20_policies_errorhandling.t $
#    $Date: 2006-11-05 18:01:38 -0800 (Sun, 05 Nov 2006) $
#   $Author: thaljef $
# $Revision: 809 $
##################################################################

use strict;
use warnings;
use Test::More tests => 5;

# common P::C testing tools
use Perl::Critic::TestUtils qw(pcritique);
Perl::Critic::TestUtils::block_perlcriticrc();

my $code ;
my $policy;

#----------------------------------------------------------------

$code = <<'END_PERL';
die 'A horrible death' if $condtion;

if ($condition) {
   die 'A horrible death';
}

open my $fh, '<', $path or
  die "Can't open file $path";
END_PERL

$policy = 'ErrorHandling::RequireCarping';
is( pcritique($policy, \$code), 3, 'die' );

#----------------------------------------------------------------

$code = <<'END_PERL';
warn 'A horrible death' if $condtion;

if ($condition) {
   warn 'A horrible death';
}

open my $fh, '<', $path or
  warn "Can't open file $path";
END_PERL

$policy = 'ErrorHandling::RequireCarping';
is( pcritique($policy, \$code), 3, 'warn' );

#----------------------------------------------------------------

$code = <<'END_PERL';
carp 'A horrible death' if $condtion;

if ($condition) {
   carp 'A horrible death';
}

open my $fh, '<', $path or
  carp "Can't open file $path";
END_PERL

$policy = 'ErrorHandling::RequireCarping';
is( pcritique($policy, \$code), 0, 'carp' );

#----------------------------------------------------------------

$code = <<'END_PERL';
die 'A horrible death';
END_PERL

$policy = 'ErrorHandling::RequireCarping';
is( pcritique($policy, \$code), 1, 'croak' );

#----------------------------------------------------------------

$code = <<'END_PERL';
die "A horrible death\n";
END_PERL

TODO: {
    local $TODO = q{Shouldn't complain if the message ends with \n};
$policy = 'ErrorHandling::RequireCarping';
is( pcritique($policy, \$code), 0, 'croak' );
}

#----------------------------------------------------------------
