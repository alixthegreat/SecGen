class kerberoasting::configure {

    $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
    $strings_to_leak = $secgen_parameters['strings_to_leak']
    $mssql_password = $strings_to_leak[0]
    $student_password = $strings_to_leak[1]

    # Write the AD configuration script to disk.
    # This runs post-reboot via RunOnce once ADWS is available.
    file { 'C:/ad-config.ps1':
        ensure  => file,
        content => template('kerberoasting/ad-config.ps1.erb'),
    }

    # Register RunOnce to execute the script after the DC promotion reboot
    exec { 'register-ad-runonce':
        provider => powershell,
        command  => 'Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunOnce" -Name "ADConfig" -Value "powershell.exe -ExecutionPolicy Bypass -File C:\\ad-config.ps1"',
        unless   => 'if (Test-Path C:\\ad-config-complete.txt) { exit 0 } else { exit 1 }',
        require  => File['C:/ad-config.ps1'],
    }

}
