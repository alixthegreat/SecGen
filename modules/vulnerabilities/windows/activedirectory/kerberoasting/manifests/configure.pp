class kerberoasting::configure {

    $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
    $strings_to_leak = $secgen_parameters['strings_to_leak']
    $mssql_password = $strings_to_leak[0]
    $iis_password = $strings_to_leak[1]
    $student_password = $strings_to_leak[2]
	$leak_username = 'student1'

    # Write the AD configuration script to disk.
    # This runs post-reboot via RunOnce once ADWS is available.
    file { 'C:/ad-config.ps1':
        ensure  => file,
        content => template('kerberoasting/ad-config.ps1.erb'),
    }

    # Register a scheduled task to run AD config at startup (runs as SYSTEM at boot, not login)
    exec { 'register-ad-config-task':
        provider => powershell,
        command  => '$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\ad-config.ps1"; $trigger = New-ScheduledTaskTrigger -AtStartup; $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable; Register-ScheduledTask -TaskName "ADConfig" -Action $action -Trigger $trigger -Settings $settings -User "SYSTEM" -RunLevel Highest -Force',
        unless   => 'if (Test-Path C:\\ad-config-complete.txt) { exit 0 } else { exit 1 }',
        require  => File['C:/ad-config.ps1'],
    }

    file { 'C:/Shares':
		ensure => directory,
	}

	file { 'C:/Shares/Public':
		ensure  => directory,
		require => File['C:/Shares'],
	}

	file { 'C:/Shares/Public/creds.txt':
		ensure  => file,
		content => template('kerberoasting/leaked-creds.txt.erb'),
		require => File['C:/Shares/Public'],
	}

	file { 'C:/configure-public-smb.ps1':
		ensure  => file,
		content => template('kerberoasting/configure-public-smb.ps1.erb'),
		require => File['C:/Shares/Public'],
	}

	exec { 'configure-public-smb-anonymous-access':
		provider => powershell,
		command  => '& "C:\\configure-public-smb.ps1"',
		require  => File['C:/configure-public-smb.ps1'],
	}

	exec { 'create-public-share':
		provider => powershell,
		command  => 'if (-not (Get-SmbShare -Name "Public" -ErrorAction SilentlyContinue)) { New-SmbShare -Name "Public" -Path "C:\\Shares\\Public" -ReadAccess "Everyone" | Out-Null }',
		unless   => 'if (Get-SmbShare -Name "Public" -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }',
		require  => Exec['configure-public-smb-anonymous-access'],
	}

	file { 'C:/inetpub/wwwroot/index.html':
		ensure  => file,
		content => template('kerberoasting/index.html.erb'),
		require => Exec['create-public-share'],
	}

}
