#!/usr/bin/perl
#
# Trigger a Wordpress database upgrade. Only invoke from ubos-manifest.json.
#
# Watch out for quotes etc. Perl and PHP use the same way of naming variables.
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

if( 'upgrade' eq $operation ) {
    my $dir      = $config->getResolve( 'appconfig.apache2.dir' );
    my $hostname = $config->getResolve( 'site.hostname' );

    if( '*' eq $hostname ) {
        $hostname = 'localhost'; # best we can do
    }

    my $cmd  = "cd $dir/wp-admin ;";
    $cmd    .= ' HTTP_HOST='     . $hostname;
    $cmd    .= ' REQUEST_URI='   . $config->getResolve( 'appconfig.context' );
    $cmd    .= ' APPCONFIG_DIR=' . $dir;
    $cmd    .= ' php';
    $cmd    .= ' -d "open_basedir=\'/ubos/http/:/tmp/:/ubos/tmp/:/usr/share/pear/:/ubos/share/wordpress/wordpress/\'"';
        # use default open_basedir and append Wordpress

    my $php = <<PHP;
<?php
\$_SERVER['SERVER_PROTOCOL'] = 'HTTP/1.1';
\$_SERVER['PHP_SELF']        = 'wp-admin/install.php';

\$_GET['step'] = 1;

require_once( 'upgrade.php' );
PHP

    my $out = '';
    my $err = '';

    # pipe PHP in from stdin
    trace( 'About to execute PHP', $php );

    if( UBOS::Utils::myexec( $cmd, $php, \$out, \$err ) != 0 ) {
        error( 'Upgrading Wordpress failed:', $err );
    }
}

1;
