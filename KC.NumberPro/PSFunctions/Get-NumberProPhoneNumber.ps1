Function Get-NumberProPhoneNumber {

    Param(
        [Parameter(Position=0)][int64]$PhoneNumber,
        [Parameter(ValueFromPipelineByPropertyName=$true)]$LineURI,
        $Credential
    )

    if (!$Credential){
        $Credential = (RequestNPCredential).Credential
    }

    $Output = New-Object –TypeName PSObject

    if ($LineURI -ne $null){
        $Output | Add-Member -type NoteProperty   -name "LineURI"         -value $LineURI
        $PhoneNumber = (Convert-KCLineURI $LineURI).Number
    }

    $Output | Add-Member -type NoteProperty   -name "PhoneNumber"         -value $PhoneNumber

    if ($PhoneNumber -notlike $null){

        if($Global:NPModuleSettings.ShowProgress -eq $true){
            Write-Progress -Activity "NumberPro - Get-NumberProPhoneNumber" -Status "Checking Number '$($PhoneNumber)'..." -Id "500" -PercentComplete 0
        }

        # Get All Ranges
        $PNRanges = Get-NumberProRange -Credential $Credential

        If ($PNRanges.Valid -ne $false){

            # Search on Each Ranga
            Foreach ($Range in $PNRanges){

                [int64]$RangeStart  = $Range.RangeStart -replace "[^0-9]"
                [int64]$RangeEnd  = $Range.RangeEnd -replace "[^0-9]"

                if ($PhoneNumber -le $RangeEnd -and $PhoneNumber -ge $RangeStart){

                    $Found = $True
                    $SiteInfo = $Range

                    $Used = Test-NPNumberUsed $PhoneNumber -Credential $Credential
                    If ($Used.Used -eq $true){
                        $InUse = $True
                    }
                    Else{
                        $InUse = $False
                    }

                    $ReservedTest = Get-NumberProReservation -PhoneNumber $PhoneNumber -Credential $Credential
                    If ($ReservedTest.Reserved -eq $true){
                        $Reserved = $True
                    }
                    Else{
                        $Reserved = $False
                    }

                }
            }
            if ($Found -eq $True){
                $Output | Add-Member -type NoteProperty   -name "RangeName"     -value $SiteInfo.RangeName
                $Output | Add-Member -type NoteProperty   -name "Description"   -value $SiteInfo.Description
                $Output | Add-Member -type NoteProperty   -name "SiteCode"      -value $SiteInfo.SiteCode
                $Output | Add-Member -type NoteProperty   -name "RangeStart"    -value $SiteInfo.RangeStart
                $Output | Add-Member -type NoteProperty   -name "RangeEnd"      -value $SiteInfo.RangeEnd
                $Output | Add-Member -type NoteProperty   -name "Used"          -value $InUse
                $Output | Add-Member -type NoteProperty   -name "Reserved"      -value $Reserved
                $Output | Add-Member -type NoteProperty   -name "Valid"         -value $True
            }
            Else{
                $Output | Add-Member -type NoteProperty   -name "Valid"         -value $False
            }

        }
        Else{
            
            $Output | Add-Member -type NoteProperty   -name "Valid"         -value $False
            $Output | Add-Member -type NoteProperty   -name "ErrorMsg"      -value $PNRanges.ErrorMsg

        }

    }
    Else{
        $Output | Add-Member -type NoteProperty   -name "Valid"         -value $False
    }

    if($Global:NPModuleSettings.ShowProgress -eq $true){
        Write-Progress -Activity "NumberPro - Get-NumberProPhoneNumber" -Status "Checking Number '$($PhoneNumber)'..." -Id "500" -Completed
    }

    Return $Output

}

function Test-NPNumberUsed {

    Param(
        $PhoneNumber,
        $Credential
    )

    if (!$credential){
        $Credential = (RequestNPCredential).Credential
    }

    $Output = New-Object –TypeName PSObject
    $Output | Add-Member -type NoteProperty   -name "PhoneNumber"         -value $PhoneNumber

    $URL = "http://ustwaw675:8080/2n/System/5/PhoneNumber/%2B" + $PhoneNumber + "?format=json"

    $Result = RestGET -ApiRoute $URL -Credential $Credential

    if ($Result.Valid -eq $true){
        $Output | Add-Member -type NoteProperty   -name "Used"             -value $True
        $Output | Add-Member -type NoteProperty   -name "Response"         -value $Result.Response
    }
    Else{
        $Output | Add-Member -type NoteProperty   -name "Used"             -value $False
        $Output | Add-Member -type NoteProperty   -name "Response"         -value $Result.Response
    }

    Return $Output
    
}