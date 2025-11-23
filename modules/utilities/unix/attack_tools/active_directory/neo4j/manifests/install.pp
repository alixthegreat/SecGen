class neo4j::install{
    package {['apt-transport-https','sudo','tee','wget']:
    ensure => 'installed',
    }

    Exec { path => ['/usr/bin'] }

    # Install Neo4j
    exec { 'neo add gpg key':
        command => 'sudo wget -O - 'https://debian.neo4j.com/neotechnology.gpg.key' | sudo apt-key add -'

    }->
    exec { 'neo add apt repository':
        command => 'echo "deb https://debian.neo4j.com stable 4.0" | sudo tee /etc/apt/sources.list.d/neo4j.list'
    }->
    exec { 'neo update apt':
        command => 'apt-get install neo4j'
    }->
    exec { 'neo stop':
        command => 'systemctl stop neo4j'
    }->

    exec { 'neo start':
        command => 'sudo neo4j console'
    }
    
    package { 'neo4j':
        ensure => present,
    }
}