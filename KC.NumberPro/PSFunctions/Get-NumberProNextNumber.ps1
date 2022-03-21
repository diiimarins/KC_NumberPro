function Get-NumberProNextNumber { 

    param(
        [parameter(ValueFromPipelineByPropertyName=$True,Mandatory=$true)]$RangeName,
        $Limit,
        [switch]$Reserve,
        $ReservationDescription,
        $ReservatioDuration,
        $Credential
    ) 

    # Input
    $InputParameters = New-Object -TypeName psobject -Property $PSBoundParameters

    If($InputParameters.Credential -like $null){
        $Credential = (RequestNPCredential).Credential
    }

    $Output = New-Object –TypeName PSObject
    $Output | Add-Member -type NoteProperty   -name "RangeName"         -value $RangeName

    if ($InputParameters.RangeName -notlike $null){

        if($Global:NPModuleSettings.ShowProgress -eq $true){
            Write-Progress -Activity "NumberPro - Get-NumberProNextNumber" -Status "Checking if range: '$RangeName' exist in NumberPro" -Id "999" -PercentComplete 0
        }

        $RangeTest = Get-NumberProRange -RangeName $RangeName -Credential $Credential

        if ($RangeTest.Valid -eq $true){
            
            $Output | Add-Member -type NoteProperty   -name "RangeFound"         -value $True
          
            $EncodedRangeName = [System.Uri]::EscapeUriString("RangeName eq `"" + $RangeName + "`"");
            $APIUrl = "http://ustwaw675:8080/2n/System/5/UnusedPhoneNumber?filter=" + $EncodedRangeName + "&format=json"

            if($Global:NPModuleSettings.ShowProgress -eq $true){
                Write-Progress -Activity "NumberPro - Get-NumberProNextNumber" -Status "Getting next available Number..." -Id "999" -PercentComplete 50
            }

            $NextAvailableNumber = RestGET -ApiRoute $APIUrl -Credential $Credential

            If ($NextAvailableNumber.Valid -eq $True){

                if ($NextAvailableNumber.Response -notlike $null){

                    if ($Limit -like $null){
                        $PhoneNumber = ($NextAvailableNumber.Response).PhoneNumber | Sort-object | select-object -first 1
                        $PhoneNumber = $PhoneNumber -replace '\D',''

                        if ($Reserve.IsPresent -eq $True){

                            if ($ReservationDescription -like $null){
                                $ReservationDescription = "Reserved by '$($env:UserName)' using command 'Get-NumberProNextNumber'"
                            }

                            if ($ReservatioDuration -like $null){
                                $ReservationParameters = @{
                                    PhoneNumber = $PhoneNumber;
                                    Description = $ReservationDescription;
                                    Credential = $Credential
                                }
                            }
                            else{
                                $ReservationParameters = @{
                                    PhoneNumber = $PhoneNumber;
                                    Description = $ReservationDescription;
                                    Duration = $ReservatioDuration
                                    Credential = $Credential
                                }
                            }

                            $Reservation = New-NumberProReservation @ReservationParameters
                            $Output | Add-Member -type NoteProperty   -name "Reservation"         -value $Reservation

                        }
                    }
                    else{
                        $PhoneNumber = ($NextAvailableNumber.Response).PhoneNumber | Sort-object | select-object -first $Limit
                    }
                    
                    $PhoneNumber = $PhoneNumber -replace '\D',''
                    $Output | Add-Member -type NoteProperty   -name "PhoneNumber"         -value $PhoneNumber
                    $Output | Add-Member -type NoteProperty   -name "AvailableNumber"         -value $True
                }
                Else{
                    $Output | Add-Member -type NoteProperty   -name "AvailableNumber"         -value $False
                    $Output | Add-Member -type NoteProperty   -name "Valid"         -value $False
                    $Output | Add-Member -type NoteProperty   -name "ErrorMsg"         -value "No Available Numbers"
                }
            }
            else{
                 $Output | Add-Member -type NoteProperty   -name "Valid"         -value $False
                 $Output | Add-Member -type NoteProperty   -name "ErrorMsg"         -value $NextAvailableNumber.ErrorMsg
            }
        }
        Else{
            $Output | Add-Member -type NoteProperty   -name "Valid"         -value $False
            $Output | Add-Member -type NoteProperty   -name "ErrorMsg"        -value $RangeTest.ErrorMsg
        }
    }
    Else{
        $Output | Add-Member -type NoteProperty   -name "Valid"         -value $False
        $Output | Add-Member -type NoteProperty   -name "ErrorMsg"        -value "Input is Null"
    }

    if($Global:NPModuleSettings.ShowProgress -eq $true){
        Write-Progress -Activity "NumberPro - Get-NumberProNextNumber" -Status "Getting next available number at: '$RangeName'" -Id "999" -Completed
    }


    Return $Output

}


