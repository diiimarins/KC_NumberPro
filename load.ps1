function SecureCredential {
       
    $UserName = "USTCAP65"
    [Byte[]] $key = (1..16)

    $Text = "76492d1116743f0423413b16050a5345MgB8AFcAWABOAGgAdQBXAGIAbQBRAGMATQBRAHcAUQBJAGMARQArAGUAWQBNAFEAPQA9AHwAYgAyAGMAYQAxADkAZQBjAGMANgBjADAAMwAwADUAMwAyADEANwA4ADQAMwBiADQANgAwADQAZgA4ADgANAA2ADkAMQBiADgAZQA0AGUAYgBhAGIAZgBhADkAYgBhADkAMAAzADAAOQAyADIAMwAzADEAMwBkAGUAMQBiAGYAYQA="
    $SecureText = ConvertTo-SecureString -Key $key -String $Text
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureText)
    $PlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    $SecPasswd = ConvertTo-SecureString $PlainText -AsPlainText -Force;
    $Credential = New-Object System.Management.Automation.PSCredential ($UserName, $SecPasswd);

    return $Credential;
}


# Module Credential
$Global:NPCredential = @{}
$Global:NPCredential.Valid = $true
$Global:NPCredential.Credential = SecureCredential


$force = $true

if($force -eq $true){
    # Remove Module 
    $Module = Get-Module KC.NumberPro
    if ($Module -notlike $null) {
        Remove-Module $Module -Force
    }

    # Import Module 
    $ScriptsPath = "$($PSScriptRoot)\KC.NumberPro\KC.NumberPro.psd1"
    Import-Module -Name $ScriptsPath -Force
}
else{
    # Import Module 
    $ScriptsPath = "$($PSScriptRoot)\KC.NumberPro\KC.NumberPro.psd1"
    Import-Module -Name $ScriptsPath -Force
    
}
