class drupal_850::configure {

  Exec { path => ['/bin', '/usr/bin','/sbin','/usr/sbin']}
  
  exec {'disable-php5':
    command => 'a2dismod php5 php5.6 2>/dev/null || true', #ignore output
  } ->

  exec {'enable-php7.2':
    command => 'a2enmod php7.2',
  } ->

  exec {'restart-apache':
    command => 'systemctl restart apache2',
  }
}

# TODO: Configure database and automate drupal setup.
