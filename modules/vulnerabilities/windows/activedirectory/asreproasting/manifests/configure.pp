class asreproasting::configure {

    $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
    $strings_to_leak = $secgen_parameters['strings_to_leak']
    $svc_password = $strings_to_leak[0]
    $user_password = $strings_to_leak[1]
    $student_password = $strings_to_leak[2]
    $asrep_user1_flag = $strings_to_leak[3]
    $asrep_svc_flag = $strings_to_leak[4]
    $asrep_user1_pass_flag = $strings_to_leak[5]
    $asrep_svc_pass_flag = $strings_to_leak[6]


    file { 'C:/ad-config.ps1':
        ensure  => file,
        content => template('asreproasting/ad-config.ps1.erb'),
    }

    # Register a scheduled task to run AD config at startup (runs as SYSTEM at boot, not login)
    exec { 'register-ad-config-task':
        provider => powershell,
        command  => '$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\ad-config.ps1"; $trigger = New-ScheduledTaskTrigger -AtStartup; $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable; Register-ScheduledTask -TaskName "ADConfig" -Action $action -Trigger $trigger -Settings $settings -User "SYSTEM" -RunLevel Highest -Force',
        unless   => 'if (Test-Path C:\\ad-config-complete.txt) { exit 0 } else { exit 1 }',
        require  => File['C:/ad-config.ps1'],
    }

    file { 'C:/inetpub/wwwroot/index.html':
		ensure  => file,
		content => template('asreproasting/index.html.erb'),
	}
}