class sharphound::install {

	file { 'C:/Tools':
		ensure => directory,
	}

	file { 'C:/Tools/SharpHound.exe':
		ensure  => file,
		source  => 'puppet:///modules/sharphound/SharpHound.exe',
		require => File['C:/Tools'],
	}
}
