class bloodhound::install{
    package {['apt-transport-https']:
    ensure => 'installed',
    }

    Exec { path => ['/bin','/usr/bin'] }

    # Install bloodhound
    exec { 'blood download':
        command => 'wget https://github.com/SpecterOps/BloodHound-Legacy/releases/download/v4.3.1/BloodHound-linux-x64.zip',
        cwd => '/tmp'
    }->
    exec { 'blood unarchive':
        command => 'sudo unzip BloodHound-linux-x64.zip; sudo mv BloodHound-linux-x64 /opt/bloodhound',
        cwd => '/tmp'
    }
}   