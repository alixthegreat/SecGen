class impacket::install{
    package {['apt-transport-https','pip','python3-pip','python3.12-venv']:
    ensure => 'installed',
    }

    Exec { path => ['/usr/bin','/bin'] }

    exec { 'clone impacket':
        command => 'sudo git clone https://github.com/fortra/impacket /opt/impacket',
        creates => '/opt/impacket',
    }->
    file { '/opt/impacket/venv':
        ensure => directory,
    }->
    exec { 'install venv':
        command => 'pip install --break-system-packages virtualenv',
        provider => shell,
    }->
    exec { 'create venv':
        command => 'sudo python3 -m venv /opt/impacket/venv',
        provider => shell,
    }->
    exec { 'activate venv and install packages':
        command => '/bin/bash -c "source /opt/impacket/venv/bin/activate && pip install ."',
        provider => shell,
        cwd => '/opt/impacket',
        require => Exec['create venv']
    }   
}