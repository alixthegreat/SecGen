class kerberoasting::install {

	# Provision a Samba domain controller using the sambaAD implementation.
	# These declarations are intentionally namespaced and contained within
	# this class so they can be applied as part of the kerberoasting module
	# without relying on top-level resource statements elsewhere.

	class { 'samba::params':
		sernetpkgs => false,
	}

	class { '::samba::classic':
		domain              => 'DC',
		realm               => 'dc.kakwa.fr',
		smbname             => 'SMB',
		join_domain         => false,
		sambaloglevel       => 3,
		logtosyslog         => true,
		manage_winbind      => false,
		sambaclassloglevel  => {
			'smb'     => 2,
			'idmap'   => 10,
			'winbind' => 10,
		},
		globaloptions       => {
			'server string'      => 'Domain Controler',
			'winbind cache time' => 10,
		},
		globalabsentoptions => [
			'idmap_ldb:use rfc2307',
		],
	}

	::samba::idmap { 'Domain DC':
		domain      => 'DC',
		idrangemin  => 10000,
		idrangemax  => 19999,
		backend     => 'ad',
		schema_mode => 'rfc2307',
	}

	::samba::idmap { 'Domain *':
		domain     => '*',
		idrangemin => 100000,
		idrangemax => 199999,
		backend    => 'tdb',
	}

	::samba::share { 'Test Share':
		path    => '/srv/test/',
		options => {
			'comment'   => 'My test share that I want',
			'browsable' => 'Yes',
			'read only' => 'No',
		},
	}

}