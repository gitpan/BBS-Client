use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    AUTHOR          => 'Cornelius Lin (cornelius.howl@gmail.com)',
    ABSTRACT        => 'BBS Client',
    dist            => {
        COMPRESS    => 'gzip',
        SUFFIX      => '.gz',
    },
    NAME              => 'BBS::Client',
    VERSION_FROM      => 'lib/BBS/Client.pm', # finds $VERSION
    PREREQ_PM         => { 
				Encode => 0 ,
				Time::HiRes => 0 ,
				Net::Telnet => 0 ,
				Text::Iconv => 0 ,
				Lingua::ZH::Wrap => 0 ,
                Switch  => 0,
                Encode => 0,
                POSIX => 0,
		}, 
    EXE_FILES       => [ <script/*> ],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/BBS/Client.pm', # retrieve abstract from module
       AUTHOR         => 'Cornelius <cornelius.howl@gmail.com>') : ()),
);
