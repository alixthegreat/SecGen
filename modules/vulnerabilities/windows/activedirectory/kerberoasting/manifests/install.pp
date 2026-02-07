class kerberoasting::install {
	exec { 'rename-computer-dc01':
		provider => powershell,
		command  => 'Rename-Computer -NewName DC01 -Force',
	}
}