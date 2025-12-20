# Class: glpi_php_injection::install
# Install process for GLPI
# https://github.com/glpi-project/glpi/releases/ - v9.5.8 is used here
class glpi_php_injection::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  
  ensure_packages(['php',
  'php-curl',
  'php-gd',
  'php-intl',
  'php-mysql',
  'php-mbstring',
  'php-xml',
  'php-ldap',
  'php-apcu',
  'php-xmlrpc',
  'php-zip',
  'php-bz2'], { ensure => 'installed'})

  $mariadb = 'mariadb-10.4.34.tar.gz'
  $longmaria = 'mariadb-10.4.34-linux-systemd-x86_64'
  $mariapart = ["${mariadb}.partaa",
  "${mariadb}.partab",
  "${mariadb}.partac",
  "${mariadb}.partad",
  "${mariadb}.partae",
  "${mariadb}.partaf",
  "${mariadb}.partag",
  "${mariadb}.partah",
  "${mariadb}.partai",
  "${mariadb}.partaj",
  "${mariadb}.partak",
  "${mariadb}.partal",
  "${mariadb}.partam",
  "${mariadb}.partan",
  "${mariadb}.partao",
  "${mariadb}.partap",
  "${mariadb}.partaq",
  "${mariadb}.partar",
  "${mariadb}.partas",
  "${mariadb}.partat",
  "${mariadb}.partau",
  "${mariadb}.partav",]

  $pkgtobuild = [[$mariapart, $mariadb]]
  $pkgtobuild.each |Array $pkg| {
    glpi_php_injection::cpandbuild($pkg[0], $pkg[1])
  }

  exec {'unpack-maria':
    cwd     => '/tmp',
    command => "tar -xf ${mariadb}",
    creates => '/tmp/${longmaria}'
  }
  -> exec { 'move-maria':
    cwd     => '/tmp',
    command => "mv ${longmaria}/ /usr/local/maria",
    creates => '/usr/local/maria',
  }
  -> exec { 'maria-install-db':
    command => '/usr/local/maria/scripts/mariadb-install-db --basedir=/usr/local/maria --datadir=/var/lib/mysql',
    creates => '/var/lib/mysql', #system db dir
    }

  $releasename = 'glpi-9.5.8.tgz'

  file { "/tmp/${releasename}":
    ensure => file,
    source => "puppet:///modules/glpi_php_injection/${releasename}",
  }
  -> exec { 'extract-glpi':
    cwd     => '/tmp',
    command => "tar -xf ${releasename}",
    creates => '/tmp/glpi'
  }
  -> exec { 'move-glpi':
    cwd     => '/tmp',
    command => 'mv glpi/ /var/www/html',
    creates => '/var/www/html/glpi/',
  }
  -> exec { 'chmod-glpi':
    command => 'chmod 755 -R /var/www/html/glpi/',
  }
  -> exec { 'chown-glpi':
    command => 'chown www-data:www-data -R /var/www/html/glpi/',
  }

}
