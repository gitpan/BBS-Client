#!/usr/bin/perl
use warnings;
use strict;
use utf8;
#use lib '/home/src/perl/_modules/BBS-Client/lib/';
#use lib '../lib/';

BEGIN {
	unshift @INC , '../lib/';
}

use BBS::Client;

my $o;
$o = BBS::Client->new( {
		host => 'bs2.to',
		sys =>  'bs2' ,  # system type ( ptt , maple )
		});

print "user:";
#my $user = <STDIN>;
my $user = 'kornelius';
print "pass:";
my $pass = <STDIN>;
chomp ($user,$pass);

print "login...";
if( $o->login($user,$pass) ) {
	print "done\n";

	print "enter board...";
	$o->enter_board("P_kornelius");
	print "done\n";
	print "listening...\n";
	$o->enter_userlist();
	$o->listen_userlist();
} else {
	print "failed..\n";
}
