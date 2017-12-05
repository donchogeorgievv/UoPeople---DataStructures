$initialErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"
$logFile = "SimpleSapScript.log"
$createRegistryActionResult = $null
$controlValue = "SAP GUI for Windows 7.50"
$regPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SAPGUI"

Function Write-Log 
{
		Param ([string]$Message)
		Add-content $Logfile -value("{0} {1}" -f $(Get-Date).ToString(), $Message) 
}

Write-Log "Script started"

#SAP stuff

Try
{
    if(Test-Path Registry::$regPath)
    {
        $SAPProperties = Get-ItemProperty -Path Registry::$regPath 
    }
    else
    {
        throw "Registry path was not found" 
    }
    
    if($SAPProperties.DisplayName.Contains($controlValue))
    {
        Write-Log "SAP version 7.50 detected"
        reg add "HKEY_CURRENT_USER\Software\SAP\SAPLogon\Options" /v PathConfigFilesLocal /t REG_EXPAND_SZ /d %оnedrivefb%\Settings\SAP /f
        reg add "HKEY_CURRENT_USER\Software\SAP\SAPLogon\Options" /v CoreLandscapeFileOnServer /t REG_SZ /d %оnedrivefb%\Settings\SAP\SAPUILandscapeGlobal.xml /f
        Write-Log "Registry values have been added successfully"

    }
    else
    {
        Write-Log "7.50 not present (case with SAP 7.30 installed)"
        [Environment]::SetEnvironmentVariable("SAPLOGON_INI_FILE", "%оnedrivefb%\Settings\SAP")
        [Environment]::SetEnvironmentVariable("SettingsFolder", "%оnedrivefb%\Settings")
    }


}
Catch
{
        Write-Log ("An error occured while processing {0}." -f $regPath)
        Write-Log ("`t>>> {0}." -f $_.Exception.Message)   
}

#Office@work stuff
Try
{
    if(Test-Path $env:ProgramData\FD_Datwyler\ODfB_Config\properties.opr)
    {
        if(!(Test-Path $env:APPDATA\officeatwork))
        {
            Write-Log "%appdata%\officeatwork does not exist"
            New-Item $env:APPDATA\officeatwork -ItemType directory
            Write-Log "%appdata%\officeatwork created"
        }

        Copy-Item $env:ProgramData\FD_Datwyler\ODfB_Config\properties.opr -destination $env:APPDATA\officeatwork -Force
        Write-Log "properties.opr was copied to %appdata%\officeatwork"
    }

    esle
    {
        throw "properties.opr could not be found"
    }
}
Catch
{
     Write-Log "There was an error while copying file"
     Write-Log ("`t>>> {0}." -f $_.Exception.Message)   
}

$ErrorActionPreference = $initialErrorActionPreference

Write-Log "SCript completed1r`r`n"