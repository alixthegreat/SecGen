class impacket::install{
    package {['apt-transport-https']:
    ensure => 'installed',
    }
}