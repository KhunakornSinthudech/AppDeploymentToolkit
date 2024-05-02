# Vars
[string]$Application = "$(& git branch --show-current)"
#Import and update Evergreen Module uncomment below module to update or import

# . '.vscode\ModuleImportAndUpdate\UpdateModule.ps1' -NameFilter "*Evergreen*" -ErrorAction SilentlyContinue
# . '.vscode\ModuleImportAndUpdate\ImportModule.ps1' -m "Evergreen"
# . '.vscode\ModuleImportAndUpdate\UpdateModule.ps1' -NameFilter '*MSI*' -ErrorAction SilentlyContinue
# . '.vscode\ModuleImportAndUpdate\ImportModule.ps1' -m 'MSI'

# TODO set the search option if the app
$EvergreenApp = Get-EvergreenApp  -Name $Application | Where-Object { $_.Architecture -eq 'x64' -and $_.Type -eq 'msi' }
# $EvergreenAppInvoke = Invoke-EvergreenApp  -Name $Application | Where-Object { $_.Architecture -eq 'x64' -and $_.Type -eq 'msi' }
$EvergreenVersion = $EvergreenApp.version


# TODO get local data of current file
$path = 'Toolkit\Files\'
$installerFilterName = "$Application.msi"
$FileName = (Get-ChildItem -Path $path | Where-Object { $_.Name -like $installerFilterName }).Name
$filePath = "$path\$FileName"
if (!($localVersion = (Get-MSIProperty productversion -Path $filePath -ErrorAction SilentlyContinue).Value)) { $localVersion = 0 }

if ($EvergreenVersion -gt $localVersion ){
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $WebClient = New-Object System.Net.WebClient
    # TODO clean up local files
	Remove-Item "$path\$Application.msi"  -ErrorAction SilentlyContinue
        try
        {
            Write-Output "Downloading new version"
            $WebClient.DownloadFile($EvergreenApp.URI, "$path\$Application.msi")
        }
        catch
        {
            #Pass the exception as an inner exception
            throw [System.Net.WebException]::new("Download error $($EvergreenApp.URI).", $_.Exception)
        }
	if (-not ($EvergreenApp.Md5.ToUpper() -eq $(Get-FileHash "$path\$Application.msi" -Algorithm "Md5").Hash.ToUpper()))
        {
            throw [System.IO.ErrorEventArgs]::new('Hash mismatch')
        }
        else {
            # Set-Content $path\version.txt $EvergreenVersion
            explorer $path}
    }
else { Write-Output "$Application is up to date" }


