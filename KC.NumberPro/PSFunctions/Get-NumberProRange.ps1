function Get-NumberProRange {

    Param(
        #[Parameter)][string]$Search,
        [parameter(Position=0,ValueFromPipelineByPropertyName=$True)]$RangeName,
        $Credential
    )

    # Input
    $InputParameters = New-Object -TypeName psobject -Property $PSBoundParameters

    If($InputParameters.Credential -like $null){
        $Credential = (RequestNPCredential).Credential
    }

    $Output = @()

    $ApiRoute = "http://ustwaw675:8080/2n/System/3/NumberRange?columns=visible&format=json"

    if ($InputParameters.RangeName -notlike $null){
        $ApiRoute = $ApiRoute + '&filter=Name%20eq%20' + '"' + $RangeName + '"'
        if($Global:NPModuleSettings.ShowProgress -eq $true){
            Write-Progress -Activity "NumberPro - Get-NumberProRange" -Status "Searching Phone Range..." -Id "1000" -PercentComplete 0
        }
    }
    Else{
        if($Global:NPModuleSettings.ShowProgress -eq $true){
            Write-Progress -Activity "NumberPro - Get-NumberProRange" -Status "Getting Phone Ranges..." -Id "1000" -PercentComplete 0
        }
    }

    $Json = RestGET -ApiRoute $ApiRoute -Credential $Credential

    if ($Json.Valid -eq $true){

        if ($Json.Response -notlike $null){

            $Counter = 1
            $TotalRecords = ($Json.Response).Count

            $Table = $Json.Response | Sort-Object Name
    
            ForEach ($RecordLine in $Table){
                
                if($Global:NPModuleSettings.ShowProgress -eq $true){
                    Write-Progress -Activity "NumberPro - Get-NumberProRange" -Status "Importing '$($RecordLine.Name)'" -Id "1000" -PercentComplete (($Counter / $TotalRecords) * 100)
                }
                
                $QueryRow = New-Object –TypeName PSObject	
                $QueryRow | Add-Member -type NoteProperty   -name "RangeName"    -value $RecordLine.Name
                $QueryRow | Add-Member -type NoteProperty   -name "Description"  -value $RecordLine.Description
                $QueryRow | Add-Member -type NoteProperty   -name "SiteCode"     -value $RecordLine.UserDefined1
                $QueryRow | Add-Member -type NoteProperty   -name "RangeStart"   -value $RecordLine.RangeStart
                $QueryRow | Add-Member -type NoteProperty   -name "RangeEnd"     -value $RecordLine.RangeEnd
                $QueryRow | Add-Member -type NoteProperty   -name "Valid"        -value $True 
                $Output += $QueryRow
                
                $Counter ++
            }

        }
        Else{
            $QueryRow = New-Object –TypeName PSObject	
            $QueryRow | Add-Member -type NoteProperty   -name "RangeName"        -value $InputParameters.RangeName
            $QueryRow | Add-Member -type NoteProperty   -name "Valid"            -value $False
            $QueryRow | Add-Member -type NoteProperty   -name "ErrorMsg"         -value "Range Not Found"
            $Output += $QueryRow
        }
    }
    Else{
        $QueryRow = New-Object –TypeName PSObject	
        $QueryRow | Add-Member -type NoteProperty   -name "RangeName"        -value $InputParameters.RangeName
        $QueryRow | Add-Member -type NoteProperty   -name "Valid"            -value $False
        $QueryRow | Add-Member -type NoteProperty   -name "ErrorMsg"         -value $Json.ErrorMessage
        $Output += $QueryRow
    }


    if($Global:NPModuleSettings.ShowProgress -eq $true){
        Write-Progress -Activity "NumberPro - Get-NumberProRange" -Status "Getting Phone Ranges..." -Id "1000" -Completed
    }

    Return $Output
    
}