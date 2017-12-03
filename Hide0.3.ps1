<#
	Hide0.3.ps1																		  
	Created by:		Doncho Georgiev //DXC.technology								  
					doncho@dxc.com												
	First release:	24.10.2017
	Version:		0.1
	Input:			!!! TBD !!!
	Output:			HideScript.log 

    Version history:
                    0.1  - Initial release
                    0.11 - Added enhanced logging to faciliate troubleshooting            06.11.2017 Doncho Georgiev //DXC.technology
                    0.2  - Added function to hide folders containing hidden items only    09.11.2017 Doncho Georgiev //DXC.technology
                    0.3  - Changed the algorithm from hiding specific files, to hiding    04.12.2017 Doncho Georgiev //DXC.technology
                           all files but the ones specified in exclusion list
#>


$initialErrorHandling = $ErrorActionPreference
$ErrorActionPreference = "Stop" 
$logFile = "HideScript.log"
$filesToHide = @()
$initialLocation = Get-Location
$logFileFQDN = $initialLocation.Path + "\" + $logFile
$logFile = $logFileFQDN
$hSetOfFolders = New-Object 'System.Collections.Generic.HashSet[string]'


#	I had the intention to use regular expressions to split the nw share from the folder
#	just recording the regex for eventual future reference 
#   $fsRegEx = "^(\\)(\\[A-Za-z0-9-_]+){2,}(\\?)$"



# Declaring two temporary arrays to store sample data for development
# Shares
$sharesList = @(
                   "\\fileserver1\share1",
                   "\\fileserver1\share3",
                   "\\fileserver1\share2" 
                )

# Files to be excluded
$exclusionList = @(
                       "\\fileserver1\share1\dir1\donothideme.txt",
                       "\\fileserver1\share2\donothidefolder\visiblefile.txt"
                   )



#region Functions

Function Write-Log 
{
		Param ([string]$Message)
		Add-content $Logfile -value("{0} {1}" -f $(Get-Date).ToString(), $Message) 
}

Function Stop-ScriptExecution
{
    $ErrorActionPreference = $initialErrorHandling
    Set-Location $initialLocation
    Exit
}

Function Hide-SomeFolders
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $path
    )

    Try
    {
        $folderObject = Get-Item $path -Force

        if(!(Get-ChildItem $folderObject))
        {
            $folderObject.Attributes = "Hidden"
            Write-Log ("{0} was set to hidden." -f $folderObject.FullName)
        }
        Else
        {
            Write-Log ("{0} was NOT set to hidden." -f $folderObject.FullName)
        }

        if($folderObject.FullName -ne $folderObject.Root.FullName)
        {
            Hide-SomeFolders -path $folderObject.Parent.FullName
        }
    }
    Catch
    {
        Write-Log ("An error occured while processing {0}." -f $path)
        Write-Log ("`t>>> {0}." -f $_.Exception.Message)
    }

}


#endregion

Write-Log -Message "Script started"

Try
{
	$creds = Get-Credential
    Write-Log "Credentials provided"
}
Catch
{
	Write-Log "Critical error occured. Unable to retrieve credentials. Script will now exit"
	Stop-ScriptExecution
}

#TODO: Refactor the input section once it is clear what files will be provided
<#
Try
{
	$filesToHide = Import-Csv input.csv
	Write-Log "CSV file successfully imported"
}
Catch
{
	Write-Log "CSV file import failed. Script will now exit."
	Stop-ScriptExecution
}
#>


Write-Log "Start sort"
[array]::Sort($sharesList)
Write-Log "End sort"


foreach($share in $sharesList)
{
    $allDirectories = @()
    $allFiles = @()
    Try
    {
        if(Test-Path $share)
        {
            Write-Log ("{0} is accessible." -f $share)
            $allDirectories = @(Get-ChildItem $share -Recurse |?{ $_.PSIsContainer })
            $allFiles = Get-ChildItem $share -File -Recurse
        }
        else
        {
            Write-Log ("{0} is not accessible." -f $share)
            Write-Log ("Trying to access {0}." -f $share)
            if(Test-Path temp:)
            {
                Remove-PSDrive temp
            }
            New-PSDrive -Name temp -PSProvider FileSystem -Root $share -Credential $creds |Out-Null
            if(Test-Path $share)
            {
                $allDirectories = @(Get-ChildItem -Recurse $share |?{ $_.PSIsContainer })
                $allFiles = Get-ChildItem $share -File -Recurse
            }
            Else
            {
                Write-Log("{0} could not be reached." -f $share)
                continue
            }

        }
    }
    Catch
    {
        Write-Log ("An error occured while processing {0}." -f $share)
        Write-Log ("`t>>> {0}." -f $_.Exception.Message)
        Write-Log ("`t>>> {0} accessible? : {1}" -f $share, $(Test-Path $share).ToString().ToUpper())
    }
    
    Write-Log -Message ("Starting file processing")
    foreach($file in $allFiles)
    {
        
        if(!($exclusionList -contains $file.FullName))
        {
            Try
            {
                $tempFileObject = Get-Item $file.FullName
                $tempFileObject.Attributes = "Hidden"
                Write-Log -Message ("{0} was set to hidden" -f $file.FullName)
            }
            Catch
            {
                Write-Log -Message ("Error! {0} was not set to hidden" -f $file.FullName)
                Write-Log ("`t>>> {0}." -f $_.Exception.Message)
            }
            Finally
            {
                $tempFileObject = $null
            }
        }
        Else
        {
            Write-Log -Message ("{0} was NOT set to hidden (exclusion list)" -f $file.FullName)
        }

    }
    Write-Log -Message ("Completed file processing")

    Write-Log -Message ("Starting folder processing")
    for($i = $allDirectories.Count-1; $i -ge 0; $i--)
    {


        Try
        {
            $folderToHideOrNotToHide = Get-ChildItem $allDirectories.Item($i).FullName

            if(!($folderToHideOrNotToHide))
            {
                $allDirectories.Item($i).Attributes = "Hidden"
                Write-Log -Message ("{0} was set to hidden" -f $allDirectories.Item($i).FullName)
            }
        }
        Catch
        {
                Write-Log -Message ("Error! {0} was not set to hidden" -f $allDirectories.FullName)
                Write-Log ("`t>>> {0}." -f $_.Exception.Message)
        }
    }
 
}


Write-Log "Folder processing completed"
$ErrorActionPreference = $initialErrorHandling
Set-Location $initialLocation
Write-Log -Message ("Script ended`r`n")