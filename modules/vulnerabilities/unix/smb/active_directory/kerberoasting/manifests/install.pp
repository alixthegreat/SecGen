class kerberoasting::install {
	package {['samba-ad-dc','krb5-user']:
    ensure => 'installed',
    }

	Exec { path => ['/usr/bin','/bin'] }

	exec { 'disable smb services':
        command => 'sudo systemctl disable --now smbd nmbd winbind; sudo systemctl mask smbd nmbd winbind'
    }->
    exec { 'update hostname':
        command => 'sudo hostnamectl set-hostname adserver'
    }->
	exec { 'add hostname to etc/hosts':
        command => 'sudo sed -i "s/^127\.0\.0\.1\s\+desktop$/127.0.0.1       desktop adserver/" /etc/hosts'
    }->
	exec { 'backup smb config':
        command => 'sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.old'
    }->
	exec { 'provision samba ad':
        command => 'samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=ad.example.org --domain=DC --adminpass="c0mPL3xe_P455woRd"'
    }->
	exec { 'start samba ad':
        command => 'sudo systemctl start samba-ad-dc'
    }	
}