class bloodhound::install{
    package {['apt-transport-https','unzip','wget','sudo','chmod']:
    ensure => 'installed',
    }

    Exec { path => ['/opt'] }

    # Install bloodhound
    exec { 'blood download':
        command => 'sudo wget https://github.com/SpecterOps/BloodHound-Legacy/releases/download/v4.3.1/BloodHound-linux-x64.zip'
    }->
    exec { 'blood unarchive':
        command => 'sudo unzip BloodHound-linux-x64; sudo mv BloodHound-linux-x64 bloodhound' 
    }->
    exec { 'blood executable':
        command => 'chmod +x ./bloodhound/BloodHound'
    }
}   