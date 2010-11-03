<?php

DEFINE('MAIL_DIR', '/home/nexor/public_html/tmp' );

$stdin_str = file_get_contents('php://stdin');
while( TRUE ) {
	$var = date('Y-m-d_H-m-s');
	$f = MAIL_DIR . '/sendmail-' . $var . '.eml';
	if(!file_exists($f)) {
		break;
  }
}
$stdin_str = 'From admin@localhost ' . date('Y-m-d H-m-s') . "\n" . $stdin_str;
file_put_contents($f, $stdin_str);
