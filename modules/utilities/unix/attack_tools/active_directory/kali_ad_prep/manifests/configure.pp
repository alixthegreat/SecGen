class kali_ad_prep::configure{
    file { '/usr/share/wordlists/ad-compliant.lst':
		ensure  => file,
		content => template('kali_ad_prep/ad-compliant.lst'),
	}
}