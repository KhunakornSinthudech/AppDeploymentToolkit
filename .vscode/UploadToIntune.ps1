# Vars
. ".vscode\Global.ps1"

Install-Module -Name "IntuneWin32App" -force
Get-installedModule -Name IntuneWin32App
# Retrieve auth token required for accessing Microsoft Graph
# Delegated authentication is currently supported only, app-based authentication is on the todo-list
Connect-MSIntuneGraph -TenantID '2ca58655-3ad3-4836-b3fa-fd15586561a5' -Verbose



    $IntuneWinFile = "$Desktop\$Application.intunewin"
    $AppIconFile = "Toolkit\Icon\$Application.png"
    $IntuneWinMetaData = Get-IntuneWin32AppMetaData -FilePath $IntuneWinFile
    $Publisher = $IntuneWinMetaData.ApplicationInfo.msiinfo.MsiPublisher
    # Create custom display name like 'Name' and 'Version'
    $DisplayName = "$Application Demo Khunakorn"
    Write-Output -InputObject "Constructed display name for Win32 app: $($DisplayName)"

    # Create requirement rule for all platforms and Windows 10 20H2
    $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "All" -MinimumSupportedWindowsRelease "W10_20H2"

    #TODO configure detection rule
    # # Create PowerShell script detection rule
    # $DetectionScriptFile = "Toolkit\Detection\Detection.ps1"
    # $DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $DetectionScriptFile -EnforceSignatureCheck $false -RunAs32Bit $false
    # Create MSI detection rule

    $DetectionRule = New-IntuneWin32AppDetectionRuleMSI -ProductCode $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductCode

    # Convert image file to icon
    $Icon = New-IntuneWin32AppIcon -FilePath $AppIconFile

    # Add new EXE Win32 app
    $InstallCommandLine = "Deploy-Application.exe"
    $UninstallCommandLine = "Deploy-Application.exe Uninstall"
    $AppReference = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description "7Zip is the best file zipper ever!" -AppVersion $IntuneWinMetaData.ApplicationInfo.msiinfo.MsiProductVersion   -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon -Verbose

    #Write-Output -InputObject "Starting to create Win32 app in Intune"
    #$Win32App = Add-IntuneWin32App @Win32AppArguments

    Write-Output -InputObject "Successfully created new Win32 app with name: $($DisplayName)"
    Add-IntuneWin32AppAssignmentAllUsers -ID $AppReference.id -Intent "available" -Notification "showAll" -Verbose
    Write-Output -InputObject "$($DisplayName) Available to all users"
