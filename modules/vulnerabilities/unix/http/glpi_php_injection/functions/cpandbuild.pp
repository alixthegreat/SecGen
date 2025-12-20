function glpi_php_injection::cpandbuild(Array $collection, String $filename) {
  $collection.each |String $item| {
    file { "/tmp/${item}":
      ensure => file,
      source => "puppet:///modules/glpi_php_injection/${item}",
    }
  }
  exec { "rebuild-${filename}":
    cwd     => '/tmp/',
    command => "/bin/cat ${filename}.parta* >${filename}",
  }
}