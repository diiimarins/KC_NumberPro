function RestGET {

    param(
        [string]$ApiRoute,
        $Credential
    ) 
 
    $ResponseData = New-Object –TypeName PSObject
    
    if (!$credential){
        $credential = (RequestNPCredential).Credential
    }

    if($Global:NPModuleSettings.ShowProgress -eq $true){
        Write-Progress -Activity "Invoke-RestMethod" -Status "Execution: '$ApiRoute'" -Id "100" -PercentComplete 0
    }

    $ErrorMsg = $null
    Try {
        $Invoke = Invoke-RestMethod -Uri $ApiRoute -Method Get -DisableKeepAlive -TimeoutSec 600 -Credential $Credential
    }
    Catch {
        $ErrorMsg = $_.Exception.Message
    }
 
    If ($ErrorMsg -like $Null){
        $ResponseData | Add-Member -type NoteProperty   -name "Response"  -value $Invoke
        $ResponseData | Add-Member -type NoteProperty   -name "Valid"  -value $True
    }
    Else{
        $ResponseData | Add-Member -type NoteProperty   -name "ErrorMessage"  -value $ErrorMsg
        $ResponseData | Add-Member -type NoteProperty   -name "Valid"  -value $False        
    }

    if($Global:NPModuleSettings.ShowProgress -eq $true){
        Write-Progress -Activity "Invoke-RestMethod" -Status "Execution: '$ApiRoute'" -Id "100" -Completed
    }

    Return $ResponseData
    
}


Function RequestNPCredential {

    $Output = New-Object -TypeName PSObject

    If (($Global:NPCredential).Valid -eq $true){
        $Credential = $Global:NPCredential.Credential
        $Output | Add-Member -type NoteProperty   -name "Credential"    -value $Credential
    }
    Else{

        if ($env:UserName -like "*s"){
            $Credential = Get-Credential -Message "Please inform your UserID (do not inform S-IDs or 'kcus\')"
        }
        else{
            $Credential = Get-Credential -Message "Please inform your password" -UserName $env:UserName
        }
        $Output | Add-Member -type NoteProperty   -name "Credential"    -value $Credential
        
    }
    
    $ErrorMsg = $null
    Try {
        $Invoke = Invoke-RestMethod -Uri "http://ustwaw675:8080/2n" -Method Get -DisableKeepAlive -TimeoutSec 600 -Credential $Credential 
    }
    Catch {
        $ErrorMsg = $_.Exception.Message
    }
 
    If ($ErrorMsg -like $Null){
        $Output | Add-Member -type NoteProperty   -name "RestGetTest"    -value $Invoke
        $Output | Add-Member -type NoteProperty   -name "Valid"    -value $true
        New-Variable -Name NPCredential -Value $Output -Scope Global -Force
    }
    Else{
        $Output | Add-Member -type NoteProperty   -name "RestGetTest"    -value $ErrorMsg
        $Output | Add-Member -type NoteProperty   -name "Valid"    -value $False
        New-Variable -Name NPCredential -Value $Output -Scope Global -Force
    }

    Return $Output

}