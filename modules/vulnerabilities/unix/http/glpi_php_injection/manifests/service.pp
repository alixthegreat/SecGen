class glpi_php_injection::service {
file { '/etc/systemd/system/mariadb.service':
    content => template('glpi_php_injection/mariadb.service.erb'),
    owner   => 'root',
    mode    => '0777',
  }

  service { 'mariadb':
    ensure => 'running',
    enable => 'true',
  }
}