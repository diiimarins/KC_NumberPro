function Get-NumberProReservation {

    Param(
        [Parameter(Mandatory=$true)]$PhoneNumber,
        $Credential,
        [switch]$ShowAllResponse
    )

    if (!$credential){
        $Credential = (RequestNPCredential).Credential
    }

    $Output = New-Object -TypeName PSObject
    $Output | Add-Member -type NoteProperty   -name "PhoneNumber"           -value $PhoneNumber

    $URL = "http://ustwaw675:8080/2n/System/5/ReservedPhoneNumber/%2B" + $PhoneNumber + "?format=json"

    $Result = RestGET -ApiRoute $URL -Credential ($Credential)

    if ($Result.Valid -eq $true){
        $Output | Add-Member -type NoteProperty   -name "Reserved"          -value $True
        
        $Output | Add-Member -type NoteProperty   -name "Reason"            -value ($Result.Response).Reason 
        $Output | Add-Member -type NoteProperty   -name "Description"       -value ($Result.Response).Description 
        $Output | Add-Member -type NoteProperty   -name "NeverExpires"      -value ($Result.Response).NeverExpires
        $Output | Add-Member -type NoteProperty   -name "Duration"          -value ($Result.Response).Duration

        if ($ShowAllResponse.IsPresent -eq $true){
            $Output | Add-Member -type NoteProperty   -name "Response"          -value $Result.Response
        }

    }
    Else{
        $Output | Add-Member -type NoteProperty   -name "Reserved"          -value $False
        $Output | Add-Member -type NoteProperty   -name "ErrorMessage"      -value $Result.ErrorMessage
    }

    Return $Output

}
