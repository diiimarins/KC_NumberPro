# Set Module Path
New-Variable -Name NPModulePath -Value $PSScriptRoot -Scope Global -Force

# Set Module Seetings
$ModuleSettings = @{
	"ShowProgress" = $false
}
New-Variable -Name NPModuleSettings -Value $ModuleSettings -Scope Global -Force


# Load Scripts
$ScriptsPath = $NPModulePath + "\PSFunctions\"
$ScriptFiles = Get-ChildItem -Path $ScriptsPath -Recurse -Filter "*.ps1"

Foreach ($File in $ScriptFiles){
	$ScriptFile = $File.FullName

	if($Global:NPModuleSettings.ShowProgress -eq $true){
		Write-Progress "Loading ps1 file: '$($File.Name)'"
	}
	. $ScriptFile
}

#region Export Module Members
$ExportModule = @{
    Function = @(
		'Get-NumberProNextNumber',
		'Get-NumberProPhoneNumber',
		'Get-NumberProRange',
		'New-NumberProReservation',
		'Get-NumberProReservation',
		'Remove-NumberProReservation'
	)
}

Export-ModuleMember @ExportModule