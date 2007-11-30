package BBS::Client;
use 5.008008;
use strict;
use warnings;
use utf8;
require Exporter;
our @ISA = qw(Exporter);

use Switch 'Perl6';
use Encode;
use Time::HiRes qw(usleep);
use Net::Telnet;
use BBS::Client::Scheme;
use POSIX qw(strftime);

use constant BUF_DELAY => 1*10**5;
use constant BUF_TIMEOUT => 10;

our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw( );

our $VERSION = '0.03';

my $esc = chr(27);


$|=1;
binmode STDOUT , ":utf8";

sub new 
{
	my ($class,$ego) = @_;
	bless $ego , $class;
	$ego->scheme();
	$ego->init();
	return $ego;
}


sub scheme {
	my $ego = shift;
	# my $scheme_name = shift || 'bs2';
	given( $ego->{sys} ) {
		when 'bs2' {
			$ego->{prompt} = \%BBS::Client::Scheme::bs2_scheme; 
			$ego->{cmd} = \%BBS::Client::Scheme::bs2_cmd_scheme; 
		}
		when 'ptt' {
			$ego->{prompt} = \%BBS::Client::Scheme::ptt_scheme; 
			$ego->{cmd} = \%BBS::Client::Scheme::ptt_cmd_scheme;
		}
		when 'sayya' {
			$ego->{prompt} = \%BBS::Client::Scheme::sayya_scheme; 
			$ego->{cmd} = \%BBS::Client::Scheme::sayya_cmd_scheme; 
		}
		default {
			$ego->{prompt} = \%BBS::Client::Scheme::bs2_scheme; 
			$ego->{cmd} = \%BBS::Client::Scheme::bs2_cmd_scheme; 
		}
	}
}

# private method declaration
sub sendkey 
{
	my ($ego,$key) = @_;
	$ego->{t}->put( $key );
}


sub dump_buffer 
{
	my ($ego,$tmp) = @_;
	$tmp =~ s/\r//g;
	$tmp =~ s/$esc\[/\*\[/g;
	print "\n=============================\n";
	print decode('big5',$tmp);
	print "\n=============================\n";
}


# filter the escaped key
sub dump
{
	my $ego = shift;
	my $tmp = $ego->{t}->get();
	$tmp =~ s/\r//g;
	$tmp =~ s/$esc\[/\*\[/g;
	print decode('big5',$tmp);
}


sub getscreen 
{
	my $ego = shift;
	usleep( BUF_DELAY );
	my $str = $ego->{t}->get( Timeout => BUF_TIMEOUT );
	print $str = decode('Big5',$str);
	return $str;
}

sub init
{
	my $ego = shift;
	$ego->{t} = Net::Telnet->new(
		Port => 23,
		Timeout => 30,
		Errmode => \&error
	);
	$ego->{t}->open( $ego->{host} );
}

sub prepare_dir
{
	my $ego = shift;
	mkdir( $ENV{HOME} . "/BBS" );
	mkdir( $ENV{HOME} . "/BBS/$ego->{host}/") unless(-d "./$ego->{host}");
	mkdir( $ENV{HOME} . "/BBS/$ego->{host}/$ego->{board}") unless(-d "./$ego->{host}/$ego->{board}");
}

sub fetch_article_content {
	my $ego = shift;
	my $buf = '';
	my $out = '';
	my ($p,$l) = (1,1);
	my $esc_jump_ptn = qr{$esc\[(\d+);1H};

	my $buf2='';
	my $last_endline = 0;
	my $do_cut = 0;
	while( my $str = $ego->{t}->get() ) {
		$buf2 .= $str;
		my $buf_de = decode('Big5',$buf2);

		if( $buf_de =~ $ego->{prompt}{browse_bar} ) {
			print "($1)\r";
			$ego->sendkey( $ego->{cmd}{next_page} );
			$buf .= $buf2;
			$buf2 ='';
		} elsif( $buf_de =~ $ego->{prompt}{browse_bar_finish} ) {
			$buf .= $buf2;
			$buf2 ='';
			$buf = decode('Big5',$buf);
			last;
		} elsif( $buf_de =~ $ego->{prompt}{article_no_content} ) {
			print "no content        \n";
			$ego->sendkey(" j\n");
			return ' ';
		}
	} 

	my @lines = split( /\n/ ,$buf);
	for my $index ( 0 .. $#lines ) 
	{
		my $line = $lines[ $index ];
		# find control char
		while ( $line =~ $esc_jump_ptn ) {
			my $blankline = '';
			for( $l+1 .. $1 ) { $blankline .= "\n" }
			$l = $1;
			$line =~ s/$esc_jump_ptn/$blankline/;
		}

		if ( $line eq '' ) {
			--$l;
		} else {
			$line =~ s/$ego->{prompt}{'browse_bar'}//g;
			$line =~ s/$ego->{prompt}{'browse_bar_finish'}//g;
			++$l;
			$out .= $line . "\n";
		}
	}
	$out =~ s/($esc\[K
	|\r
	|$esc\[(\d*?;?)*m
	|^$esc\[;H$esc\[2J
	)//gx;
	return $out;
}


# public method declaration
sub login 
{
	my ($ego,$user,$pass) = @_;

	$ego->{user} = $user;
	$ego->{pass} = $pass;

	my $buf = '';
	while( my $str = $ego->{t}->get() ) {
		my $buf_de = decode('Big5' , $buf .= $str );

		if ( $buf_de =~ $ego->{prompt}{userid} ) {
			print "enter id\n";
			$ego->sendkey( $user."\n");
			$buf = '';
		} 
		elsif( $buf_de =~ $ego->{prompt}{passwd} ) {
			print "enter password\n";
			$ego->sendkey( $pass."\n");
			$buf = '';
		} 
		elsif(  $buf_de =~ $ego->{prompt}{repeat_login}  ) {
			print "skip killing other login\n";
			$ego->sendkey( "n\n" );
			$buf = '';
		} 
		elsif( $buf_de =~ $ego->{prompt}{press_any_key} ) {
			print "pass\n";
			$ego->sendkey( $ego->{cmd}{quit} );
			$buf = '';
		} 
		elsif( $buf_de =~ $ego->{prompt}{hotboards} ) {
			print "pass\n";
			$ego->sendkey( $ego->{cmd}{quit});
			$buf = '';
		} 
		elsif( $buf_de =~ $ego->{prompt}{guestbook} ) {
			print "pass\n";
			$ego->sendkey( $ego->{cmd}{quit});
			$buf = '';
		}
		elsif( $buf_de =~ $ego->{prompt}{main_menu} ) {
			print "get main menu\n";
			$buf = '';
			return 1;
		} 
		elsif( $buf_de =~ $ego->{prompt}{wrong_userid} ) {
			print "wrong userid\n";
			$buf = '';
			return 0;
		} 
		elsif( $buf_de =~ $ego->{prompt}{wrong_passwd} ) {
			print "wrong password\n";
			$buf = '';
			return 0;
		} 
		elsif( $buf_de =~ $ego->{prompt}{incomplete_article} ) {
			$ego->sendkey("q\r"); # forget it
			$buf = '';
		} 
	}
}

sub enter_board 
{
	my $ego = shift;
	my $board = shift;
	$ego->{board}=$board;
	$ego->sendkey( $ego->{cmd}{search_board} . $board . "\n");
	my $buf = '';
	while( my $str = $ego->{t}->get() ) {
		$buf .= $str;
		my $buf_de = decode('big5' , $buf );

		if( $buf_de =~ $ego->{prompt}{article_list} )  {
			return 1;
		} 
		elsif ( $buf_de =~ $ego->{prompt}{press_any_key} ) {
			$ego->sendkey( $ego->{cmd}{quit} );
			$buf = '';
		} 
		elsif ( $buf_de =~ $ego->{prompt}{browse_bar} ) {
			$ego->sendkey( $ego->{cmd}{quit} );
			$buf = '';
		}
	}
}

sub query_id 
{
	my ($ego,$id)=@_;
	$ego->sendkey("T\rQ\r");
	$ego->sendkey("$id\r");

}


sub fetch_articles 
{
	my ( $ego , $start , $end ) = @_;
	$ego->prepare_dir();
	$ego->sendkey( "$start\n\n" );
	for my $index ( $start .. $end ) {

		print "      fetching item $index...\r";
		my $c = $ego->fetch_article_content();
		$ego->sendkey( $ego->{cmd}{next_page} ); 

		open FH , sprintf("> ./%s/%s/%d.txt" , $ego->{host} , $ego->{board} , $index );
		binmode FH , ":utf8";
		print FH $c;
		close FH;
		print "item $index saved.            \n";

	}
	print "done. :)\n";
	$ego->sendkey( $ego->{cmd}{quit} );
}

sub offline 
{
	my $ego = shift;
	$ego->{t}->close();
}


# 
# User list
sub enter_userlist
{
	my $ego = shift;
	$ego->sendkey( $ego->{cmd}->{userlist_show} );  # <Ctrl-U> <Tab> <4> <Enter>
}


sub read_screen
{
	my ( $ego , $pattern ) = @_; 		# pattern to stop read
	my $buf = '';
	while( my $str = $ego->{t}->get() ) { 		# fetch screen
		$buf .= $str;
		my $buf_de = decode('Big5',$buf );
		return $buf_de if( $buf_de =~ m{$pattern} );
	}
}

sub userlist_write_log 
{
	my $ego = shift;
	my $action = shift;
	my %user = @_;
	my $log_filename = $ENV{HOME} . "/$ego->{host}/$ego->{board}.log";
	open FH , ">>" , $log_filename ;
	binmode FH , ":utf8";
	print FH "$action : $user{ID} - $user{NICK} \n";
	close FH;
}

sub listen_userlist 
{
	my $ego = shift;
	my %all_ids;
	my %cur_ids;
	my %last_ids;
	my $timestamp;
	my $level = 0;
	my %pad_ids;

	while(1) 
	{
		# send update key
		usleep( BUF_DELAY );
		$ego->sendkey("s");
		my $screen = $ego->read_screen( $ego->{prompt}{userlist_bar} );

		# add id to current id list 
		while( $screen =~ m{$ego->{prompt}{userlist_board_friend}}g )
		{ 
			my ( $gid , $gnick )=( $1, $2);
			if ( ! exists( $all_ids{$gid} )
					and $gid ne $ego->{user} )
			{
				$all_ids{$gid} = 1 ;
				$ego->userlist_write_log( 
					'new guest' , 
					( 'ID' => $gid , 'NICK' => $gnick )
				);

				print "new guest found \@ $ego->{board} : "
				. "$gid ( $gnick ) \n";
			}
			$cur_ids{$gid} = 1 
			if( $gid ne $ego->{user} );
		} 

		# update timestamp at first time	
		$timestamp = time() if ( ! $timestamp );
		if( time() - $timestamp > 2 )	# update current id list to last id list ( every 2 sec )
		{
			$timestamp = time();
			my $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;

			# compare with last id list
			foreach my $id ( keys %cur_ids )  # find new join visitors and existed visitors
			{ 
				unless( $last_ids{ $id } ) {
					# new join
					$pad_ids{ $id } = $level;
					print "   |" x $pad_ids{$id} ;
					print "  $id enter at $now_string  " 
					. $all_ids{$id} . " times. \n";
					$all_ids{$id}++;
					$level++;
				}
			}

			foreach my $id ( keys %last_ids ) 
			{
				unless ( $cur_ids{ $id } ) { 
					print "   |" x $pad_ids{$id} ;
					print "- $id leave at: $now_string \n";
					$level--;
				}
			}

			# update last id list
			%last_ids = %cur_ids;
			foreach my $h ( keys %cur_ids ) { delete $cur_ids{$h}; }

		}
	}
}

sub wait_for
{
	my ($ego,$pattern)=@_;
	my $buf = '';
	while( my $str = $ego->{t}->get() ) {
		$buf .= $str;
		my $buf2 = decode('Big5',$buf);

		return 1 
		if( $buf2 =~ m{$pattern} );
	}
}

sub conv_utf8_to_big5
{
	my ($ego,$c) = @_;

	# check if content is utf8 encoding
	if( utf8::is_utf8( $c ) ) {
		# convert encoding from utf8 to big5
		# because BBS sytem use big5 encoding
		my $enc = Text::Iconv->new("utf8", "big5");
		my $content_big5 = $enc->convert( $c );
		return if( $enc->retval );
		return $content_big5;
	} else {
		return $c;
	}
}


sub post_article
{
	my ($ego,$title,$content) = @_;

	# send post command	
	$ego->sendkey(  $ego->{cmd}{article_post} );

	# make sure that we are going to post text
	return unless ( $ego->wait_for( $ego->{prompt}{article_ask_label} ) );

	# skip label
	$ego->sendkey("\n");

	# send title
	usleep( 2 * 10 ** 5 );
	$ego->sendkey( $title . "\n" );

	# signature
	$ego->sendkey("\n");
	usleep( 2 * 10 ** 5 );
	$ego->sendkey($content);

	usleep( 5 * 10 ** 5 );
	$ego->sendkey(  $ego->{cmd}{article_menu} );

	usleep( 2 * 10 ** 5 );
	$ego->sendkey(  $ego->{cmd}{article_save} );

	usleep( 2 * 10 ** 5 );
	$ego->sendkey( $ego->{cmd}{next_page} );

	1;
}

sub error 
{
	#print "error\n";
	#exit;
}

1;
__END__


=head1 NAME

BBS::Client - A Client Module For BBS Systems

=head1 SYNOPSIS

	use BBS::Client;
	my $o = BBS::Client->new( {
			host => 'bs2.to',
			sys =>  'bs2' ,  # system type ( ptt or maple )
			});

	if( $o->login($user,$pass) ) {

		$o->enter_board($board);
		$o->fetch_articles( $start , $end );

	} else {

		print "failed..\n";

	}

=head1 DESCRIPTION

To connect with BBS systems to backup articles , I wrote this
module , which is implemented with Net::Telnet.  You can fetch
articles from BBS Systems , such like ptt.cc , ptt2.cc and bs2.to

This module works on different BBS Systems by given specific scheme
to emit corresponding behaviors. You can also add your scheme to 
this module. ( BBS::Client::Scheme )

=head1 SEE ALSO

Net::Telnet

=head1 AUTHOR

Cornelius, E<lt>cornelius.howl@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Cornelius

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.
