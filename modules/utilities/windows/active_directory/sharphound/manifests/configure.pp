class sharphound::configure {

	file { 'C:/inetpub':
		ensure => directory,
	}

	file { 'C:/inetpub/wwwroot':
		ensure  => directory,
		require => File['C:/inetpub'],
	}

	file { 'C:/inetpub/wwwroot/sharphound':
		ensure  => directory,
		require => File['C:/inetpub/wwwroot'],
	}

	file { 'C:/run-sharphound.ps1':
		ensure  => file,
		content => template('sharphound/run-sharphound.ps1.erb'),
	}

	exec { 'register-sharphound-startup-task':
		provider => powershell,
		command  => '$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\run-sharphound.ps1"; $trigger = New-ScheduledTaskTrigger -AtStartup; $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable; Register-ScheduledTask -TaskName "RunSharpHound" -Action $action -Trigger $trigger -Settings $settings -User "SYSTEM" -RunLevel Highest -Force',
		unless   => 'if (Test-Path "C:\Tools\sharphound-complete.txt") { exit 0 } else { exit 1 }',
		require  => [File['C:/inetpub/wwwroot/sharphound'], File['C:/run-sharphound.ps1']],
	}
}
