param (
	[Parameter(Mandatory = $false)][string]$m = '*'
)

	# If module is imported say that and do nothing
	if (Get-Module | Where-Object { $_.Name -eq $m }) {
		Write-Host "Module $m is already imported."
	} else {

		# If module is not imported, but available on disk then import
		if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $m }) {
			Import-Module $m -Verbose
		} else {

			# If module is not imported, not available on disk, but is in online gallery then install and import
			if (Find-Module -Name $m | Where-Object { $_.Name -eq $m }) {
				Install-Module -Name $m -Force -Verbose -Scope CurrentUser
				Import-Module $m -Verbose
			} else {

				# If the module is not imported, not available and not in the online gallery then abort
				Write-Host "Module $m not imported, not available and not in an online gallery, exiting."
				EXIT 1
			}
		}
	}


