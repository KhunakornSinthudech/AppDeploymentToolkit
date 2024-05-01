#Import and update Evergreen Module

. '.vscode\ModuleImportAndUpdate\UpdateModule.ps1' -NameFilter "*Evergreen*" -ErrorAction SilentlyContinue
. '.vscode\ModuleImportAndUpdate\ImportModule.ps1' -m "Evergreen"
. '.vscode\ModuleImportAndUpdate\UpdateModule.ps1' -NameFilter '*MSI*' -ErrorAction SilentlyContinue
. '.vscode\ModuleImportAndUpdate\ImportModule.ps1' -m 'MSI'

# TODO set the search option if the app
$EvergreenApp = Get-EvergreenApp  -Name '7Zip' | Where-Object { $_.Architecture -eq 'x64' -and $_.Type -eq 'msi' }
$EvergreenAppInvoke = Invoke-EvergreenApp  -Name '7Zip' | Where-Object { $_.Architecture -eq 'x64' -and $_.Type -eq 'msi' }
$EvergreenVersion = $EvergreenApp.version


# TODO get local data of current file
$path = 'Toolkit\Files\'
$installerFilterName = '*.msi'
$FileName = (Get-ChildItem -Path $path | Where-Object { $_.Name -like $installerFilterName }).Name
$filePath = "$path\$FileName"
if (!($localVersion = (Get-MSIProperty productversion -Path $filePath -ErrorAction SilentlyContinue).Value)) { $localVersion = 0 }

if ($EvergreenVersion -gt $localVersion ){
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $WebClient = New-Object System.Net.WebClient
	Remove-Item "$path\*.msi"
        try
        {
            $WebClient.DownloadFile($EvergreenApp.URI, "$path\7zip.msi")
        }
        catch
        {
            #Pass the exception as an inner exception
            throw [System.Net.WebException]::new("Download error $($EvergreenApp.URI).", $_.Exception)
        }
	if (-not ($EvergreenApp.Md5.ToUpper-eq $(Get-FileHash "$path\7zip.msi" -Algorithm Md5).Hash.ToUpper))
        {
            throw [System.Activities.VersionMismatchException]::new('Hash mismatch')
        }
    }



