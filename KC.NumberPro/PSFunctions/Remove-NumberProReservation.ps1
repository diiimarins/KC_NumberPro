function Remove-NumberProReservation {
    
    param(
        [Parameter(Mandatory)][string]$PhoneNumber,
        $Credential
    ) 

    if (!$credential){
        $Credential = (RequestNPCredential).Credential
    }

    $Output = New-Object -TypeName PSObject
    $Output | Add-Member -type NoteProperty   -name "PhoneNumber"    -value $PhoneNumber

    $ReservationTest = Get-NumberProReservation -PhoneNumber $PhoneNumber
    if ($ReservationTest.Reserved -eq $true){
        $ErrorMsg = $null
        Try {
            $URL = "http://ustwaw675:8080/2n/System/5/ReservedPhoneNumber/%2B" + $PhoneNumber + "?format=json"
            $Invoke = Invoke-RestMethod -Uri $URL -Method Delete -DisableKeepAlive -TimeoutSec 600 -Credential $Credential -AllowUnencryptedAuthentication
        }
        Catch {
            $ErrorMsg = $_.Exception.Message
        }

        If ($ErrorMsg -like $Null){
            $Output | Add-Member -type NoteProperty   -name "Removed"       -value $True
        }
        else{
            $Output | Add-Member -type NoteProperty   -name "Removed"       -value $False
            $Output | Add-Member -type NoteProperty   -name "ErrorMessage"  -value $ErrorMsg
        }

    }
    else{
        $Output | Add-Member -type NoteProperty   -name "Removed"    -value $False
        $Output | Add-Member -type NoteProperty   -name "ErrorMessage"    -value "Phone Number isnt reserved"
    }

    Return $Output
}