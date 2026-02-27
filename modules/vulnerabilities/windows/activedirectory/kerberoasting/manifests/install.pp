class kerberoasting::install {

    $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
    $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
    $strings_to_leak = $secgen_parameters['strings_to_leak']

    exec { 'install-ad':
        provider => powershell,
        command  => 'Install-WindowsFeature AD-Domain-Services -IncludeManagementTools',
    }

    exec { 'install-ad-tools':
        provider => powershell,
        command  => 'Install-WindowsFeature RSAT-AD-PowerShell',
        require  => Exec['install-ad'],
    }

    # Install forest - reboot separately to complete promotion
    exec { 'install-forest':
        provider => powershell,
        command  => 'try { Install-ADDSForest -DomainName "lab.local" -DomainNetbiosName "LAB" -InstallDns -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) -Force -NoRebootOnCompletion -Confirm:$false -ErrorAction Stop; exit 0 } catch { $_ | Out-String | Out-File C:\ad-promo-error.txt -Append; exit 1 }',
        require  => Exec['install-ad-tools'],
        timeout  => 1800,
    }

    exec { 'reboot-after-forest':
        provider => powershell,
        command  => 'shutdown /r /t 10 /c "DC promotion complete"',
        require  => Exec['install-forest'],
    }

}