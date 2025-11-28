class neo4j::install{
    package {['apt-transport-https']:
    ensure => 'installed',
    }

    Exec { path => ['/usr/bin','/bin'] }

    # Install Neo4j
    exec { 'neo add apt repository':
        command => 'echo "deb https://debian.neo4j.com stable 4.0" | sudo tee /etc/apt/sources.list.d/neo4j.list'
    }->
    exec { 'neo update apt':
        command => 'apt-get install -y neo4j'
    }->
    
    package { 'neo4j':
        ensure => present,
    }
}