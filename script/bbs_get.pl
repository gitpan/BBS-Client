#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use BBS::Client;


my $o;
$o = BBS::Client->new( {
		host => 'bs2.to',
		sys =>  'bs2' ,  # system type ( ptt , maple )
		});

print "user:";
my $user = <STDIN>;
print "pass:";
my $pass = <STDIN>;
print "board:";
my $board = <STDIN>;
print "start:";
my $start = <STDIN>;
print "end:";
my $end = <STDIN>;
chomp ($user,$pass,$board,$start,$end);

print "login...";
if( $o->login($user,$pass) ) {
	print "done\n";
	print "enter board...";
	$o->enter_board($board);
	print "done\n";
	$o->fetch_articles( $start , $end );
} else {
	print "failed..\n";
}
