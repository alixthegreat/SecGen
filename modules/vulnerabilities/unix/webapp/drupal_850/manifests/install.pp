class drupal_850::install {
    Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin']}

    ensure_packages(['php7.2-gd','php7.2-xml','php7.2-mysql','libapache2-mod-php7.2'])
    
    $archive = 'drupal-8.5.0.tar.gz'

    file {"/usr/local/src/$archive":
        ensure => file,
        source => "puppet:///modules/drupal_850/$archive",
    } ->

    exec { 'unpack-drupal':
        cwd => '/usr/local/src',
        command => "tar -xzf $archive -C /var/www",
    } ->
    exec { 'chown-drupal':
        command => "chown www-data. /var/www/drupal-8.5.0 -R",
    }
}
