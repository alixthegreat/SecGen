class kerberoasting::install {

    $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
    $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
    $strings_to_leak = $secgen_parameters['strings_to_leak']

    exec { 'install-iis':
		provider => powershell,
		command  => 'Install-WindowsFeature Web-Server,Web-WebServer,Web-Common-Http,Web-Default-Doc,Web-Static-Content,Web-Dir-Browsing,Web-Http-Errors,Web-Http-Logging,Web-Request-Monitor,Web-Stat-Compression,Web-Filtering,Web-Mgmt-Tools,Web-Mgmt-Console',
	}
    
    exec { 'install-ad':
        provider => powershell,
        command  => 'Install-WindowsFeature AD-Domain-Services -IncludeManagementTools',
        require => Exec['install-iis']
    }

    exec { 'install-ad-tools':
        provider => powershell,
        command  => 'Install-WindowsFeature RSAT-AD-PowerShell',
        require  => Exec['install-ad'],
    }

    # Install forest - use NoRebootOnCompletion and defer reboot
    exec { 'install-forest':
        provider => powershell,
        command  => 'try { Install-ADDSForest -DomainName "lab.local" -DomainNetbiosName "LAB" -InstallDns -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) -Force -NoRebootOnCompletion -Confirm:$false -ErrorAction Stop; "forest-installed" | Out-File C:\forest-installed.txt; exit 0 } catch { $_ | Out-String | Out-File C:\ad-promo-error.txt -Append; exit 1 }',
        unless   => 'if (Test-Path C:\forest-installed.txt) { exit 0 } else { exit 1 }',
        require  => Exec['install-ad-tools'],
        timeout  => 1800,
    }

    # Register a scheduled task to reboot at next startup (runs at SYSTEM boot, not user login)
    exec { 'register-dc-reboot':
        provider => powershell,
        command  => '$action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 30 /c \"DC promotion reboot\""; $trigger = New-ScheduledTaskTrigger -AtStartup; $settings = New-ScheduledTaskSettingsSet; Register-ScheduledTask -TaskName "DCPromotionReboot" -Action $action -Trigger $trigger -Settings $settings -User "SYSTEM" -RunLevel Highest -Force',
        unless   => 'if ((Test-Path C:\forest-reboot-marker.txt) -or (Get-Service NTDS -ErrorAction SilentlyContinue)) { exit 0 } else { exit 1 }',
        require  => Exec['install-forest'],
    }

}