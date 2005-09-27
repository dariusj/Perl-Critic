package Perl::Critic::Policy::Modules::ProhibitUnpackagedCode;

use strict;
use warnings;
use Carp;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.08_02';
$VERSION = eval $VERSION; ## pc:skip

#----------------------------------------------------------------------------

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    #Set configuration
    $self->{_exempt_scripts} = delete $args{exempt_scripts} || 0;

    #Sanity check for bad configuration.  We deleted all the args
    #that we know about, so there shouldn't be anything left.
    if(%args) {	
	my $msg = 'Unsupported arguments to ' . __PACKAGE__ . '->new(): ';
	$msg .= join $COMMA, keys %args;
	croak $msg;
    }

    return $self;
}

sub violations {
    my ($self, $doc) = @_;

    # You can configure this policy to exclude scripts
    return if $self->{_exempt_scripts} && _is_script($doc);

    my $expl = q{Violates encapsulation};
    my $desc = q{Unpackaged code};
    my $match = $doc->find_first( sub { $_[1]->significant() } ) || return;
    return if $match->isa('PPI::Statement::Package');
    return Perl::Critic::Violation->new( $desc, $expl, $match->location() );
}

sub _is_script {
    my $doc = shift;
    my $first_comment = $doc->find_first('PPI::Token::Comment') || return;
    $first_comment->location()->[0] == 1 || return;
    return $first_comment =~ m{ \A \#\! }x;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Modules::ProhibitUnpackagedCode

=head1 DESCRIPTION

Conway doesn't specifically mention this, but I've come across it in
my own work.  In general, the first statement of any Perl module or
library should be a C<package> statement.  Otherwise, all the code
that comes before the C<package> statement is getting executed in the
caller's package, and you have no idea who that is.  Good
encapsulation and common decency require your module to keep its
innards to itself.

As for scripts, most people understand that the default package is
C<main>, but it doesn't hurt to be explicit about it either.  But if
you insist on omitting C<package main;> from your scripts, you can
configure this policy to overlook any file that looks like a script,
which is determined by looking for a shebang line at the top of the
file.  To activate this behavior, add the following to your
F<.perlcriticrc> file

  [Modules::ProhibitUnpackagedCode]
  exempt_scripts = 1

There are some valid reasons for not having a C<package> statement at
all.  But make sure you understand them before assuming that you
should do it too.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
