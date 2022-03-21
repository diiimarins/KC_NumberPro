function New-NumberProReservation { 
    
    param(
        [Parameter(Mandatory)][string]$PhoneNumber,
        [Parameter(Mandatory)][string]$Description,
        [string]$Duration,
        $Credential
    ) 

    # Input
    $InputParameters = New-Object -TypeName psobject -Property $PSBoundParameters

    If($InputParameters.Credential -like $null){
        $Credential = (RequestNPCredential).Credential
    }

    $Output = New-Object –TypeName PSObject
    $Output | Add-Member -type NoteProperty   -name "PhoneNumber"    -value $PhoneNumber

    $PhoneNumberTest = Get-NumberProPhoneNumber -PhoneNumber $PhoneNumber
    if ($PhoneNumberTest.Valid -eq $true){

        if($Global:NPModuleSettings.ShowProgress -eq $true){
            Write-Progress -Activity "NumberPro - New-NumberProReservation" -Status "Reserving Number '$($PhoneNumber)'..." -Id "300" -PercentComplete 0
        }

        $PhoneNumber = "+" + $PhoneNumber
        if($Duration -like $null){
            $Duration = "10"
            $NumberToReserve = @{
                "Duration" = $Duration; 
                "PhoneNumber" = $PhoneNumber;
                "Description" = $Description; 
                "Reason" = "Reserved";
                "NeverExpires" = "No";
            }
        }
        else{
            if ($Duration -eq "0"){
                $NumberToReserve = @{
                    "PhoneNumber" = $PhoneNumber;
                    "Description" = $Description; 
                    "Reason" = "Reserved";
                    "NeverExpires" = "Yes";
                }
            }
            else{
                $NumberToReserve = @{
                    "Duration" = $Duration; 
                    "PhoneNumber" = $PhoneNumber;
                    "Description" = $Description; 
                    "Reason" = "Reserved";
                    "NeverExpires" = "No";
                }
            }
        }

        $ErrorMsg = $Null
        Try{
            $APIUrl = "http://ustwaw675:8080/2n/System/5/ReservedPhoneNumber"
            $ResponseData = (Invoke-RestMethod -Uri $APIUrl -Credential $Credential -Method Post -Body (ConvertTo-Json $NumberToReserve) -ContentType "application/json" -DisableKeepAlive -TimeoutSec "600");
        }
        Catch{
            $ErrorMsg =  $_.Exception.Message
        }

        if($ErrorMsg -like $null){
            $Output | Add-Member -type NoteProperty   -name "Reserved"            -value $True
            $Output | Add-Member -type NoteProperty   -name "Description"         -value $Description

            if ($Duration -like "0"){
                $Output | Add-Member -type NoteProperty   -name "NeverExpires"        -value $True
            }
            else{
                $Output | Add-Member -type NoteProperty   -name "Duration"            -value $Duration
            }

            $Output | Add-Member -type NoteProperty   -name "ResponseData"         -value $ResponseData

        }
        Else{
            $Output | Add-Member -type NoteProperty   -name "Reserved"            -value $False
            $Output | Add-Member -type NoteProperty   -name "ErrorMessage"        -value $ErrorMsg
        }

        if($Global:NPModuleSettings.ShowProgress -eq $true){
            Write-Progress -Activity "NumberPro - New-NumberProReservation" -Status "Reserving Number '$($PhoneNumber)'..." -Id "300" -Completed
        }
    }
    else{
        $Output | Add-Member -type NoteProperty   -name "Reserved"            -value $False
        $Output | Add-Member -type NoteProperty   -name "ErrorMessage"        -value "The phone number $($PhoneNumber) is not between ranges in NumberPro"
    }

    Return $Output

}
