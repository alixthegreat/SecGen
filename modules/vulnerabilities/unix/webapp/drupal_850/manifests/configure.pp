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

# TODO Automate the following: 
# - Remove all files from /var/lib/mysql/*
# - Initialise mysql instance
# - Drop old database (if present) and create new drupal database
# - Create mysql user 'drupaluser' with password 'drupalpass' and grant all privileges on drupal database ?
# - Enable REST module for second exploit
