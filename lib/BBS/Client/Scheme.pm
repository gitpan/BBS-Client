package BBS::Client::Scheme;
use strict;
use utf8;
our $esc = chr(27);

# -----------------------
# Bs2
# -----------------------
our %bs2_scheme = (
	'userid' 			=> qr/您的帳號/,
	'passwd' 			=> qr/您的密碼/,
	'press_any_key' 	=> qr/請按.*?任意鍵.*?繼續/,
	'repeat_login' 		=> qr/您想踢掉其他重複的 login.*?嗎？/,
	'hotboards' 		=> qr/熱門看板排行榜/,
	'main_menu' 		=> qr/主功能表/,
	'wrong_userid' 		=> qr/錯誤的使用者代號/,
	'wrong_passwd' 		=> qr/密碼輸入錯誤/,

# Articles
	'article_ask_label' => qr/發表文章於.*?看板/,
	'article_list' 		=> qr/\[1\;33\;46m\s*文章列表/,
	'article_no_content'=> qr/此文章無內容/,
	'article_posted'	=> qr/順利貼出文章/,
	'browse_bar' 		=> qr/瀏覽 P\.(\d+)/,
	'browse_bar_finish' => qr/文章選讀/,

# Userlist
	'userlist_bar' 			=> qr{46m 網友列表},
	'userlist_board_friend' => qr{\d+\s+$esc\[36m(.+?)\s+(.+?)\s+?},
);

our %bs2_cmd_scheme = (
	'next_page' => ' ',
	'search_board' => 's',
	'quit' => 'q',

# Articles
	'article_post' => "\x10",
	'article_menu' => "\x18",
	'article_save' => "S\n",

# Userlist 
	'userlist_show' =>  "\025\t4\n"  ,

);

# -----------------------
# Sayya
# -----------------------
our %sayya_scheme = (
	'userid' 				=> qr/請輸入代號/,
	'passwd' 				=> qr/請輸入密碼/,
	'press_any_key' 		=> qr/請按任意鍵繼續/,
	'repeat_login' 			=> qr/您想刪除其他重複的 login \(Y\/N\)嗎/,
	'hotboards' 			=> qr/熱門看板排行榜/,
	'main_menu' 			=> qr/主功能表/,
	'wrong_userid' 			=> qr/錯誤的使用者代號/,
	'wrong_passwd' 			=> qr/密碼輸入錯誤/,
	'article_list' 			=> qr/看板《.*?》/,
	'article_no_content' 	=> qr/此文章無內容/,
	'browse_bar' 			=> qr/瀏覽 P\.(\d+.*?\d+\%).*/,
	'browse_bar_finish' 	=> qr/文章選讀.*/,
	'edit_menu' 			=> qr/存檔選項/,
	'posted'				=> qr/順利貼出文章/,
	'editing'				=> qr/編輯文章/,
);

our %sayya_cmd_scheme = (
	'next_page' => ' ',
	'search_board' => "s\n",
	'quit' => 'q',
);

# ---------------
# ptt
# ---------------
our %ptt_scheme = (
	'userid' => qr/請輸入代號/,
	'passwd' => qr/請輸入您的密碼/,
	'press_any_key' => qr/請按.*?任意鍵.*?繼續/,
	'repeat_login' => qr/您想刪除其他重複的 login.*?嗎？/,
	'hotboards' => qr/熱門看板排行榜/,
	'main_menu' => qr/主功能表/,
	'wrong_userid' => qr/錯誤的使用者代號/,
	'wrong_passwd' => qr/密碼輸入錯誤/,
	'article_list' => qr/文章選讀/,
	'article_no_content' => qr/此文章無內容/,
	'browse_bar' => qr/.*瀏覽 第 (\d+\/\d+) 頁.*?\(\s{1,2}\d{1,2}\%\).*/,
	'browse_bar2' => qr/.*瀏覽 第 \d+\/\d+ 頁.*?此頁有控制碼.*/,
	'browse_bar_finish' => qr/.*瀏覽 第 \d+\/\d+ 頁 \(100\%\).*/,
);

our %ptt_cmd_scheme = (
	'next_page' => ' ',
	'search_board' => 's',
	'quit' => 'q',
);



1;

