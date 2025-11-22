class sharphound::install{
  package { ['sharphound']:
    ensure => 'installed',
  }
}
