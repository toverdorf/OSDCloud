function step-validate-isdriverpackready {
    [CmdletBinding()]
    param (
        [System.String]
        $DriverPackName = $global:OSDCloudWorkflowInvoke.DriverPackName,

        [System.String]
        $DriverPackGuid = $global:OSDCloudWorkflowInvoke.DriverPackObject.Guid,

        $DriverPackObject = $global:OSDCloudWorkflowInvoke.DriverPackObject
    )
    #=================================================
    # Start the step
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Debug -Message $Message; Write-Verbose -Message $Message

    # Get the configuration of the step
    $Step = $global:OSDCloudWorkflowCurrentStep
    #=================================================
    # Is DriverPackName set to None?
    if ($DriverPackName -eq 'None') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPackName is set to None. OK."
        return
    }
    #=================================================
    # Is DriverPackName set to Microsoft Update Catalog?
    if ($DriverPackName -eq 'Microsoft Update Catalog') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPackName is set to Microsoft Update Catalog. OK."
        return
    }
    #=================================================
    # Is there a DriverPack Object?
    if (-not ($DriverPackObject)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPackObject is not set. OK."
        return
    }
    #=================================================
    # Is there a DriverPack Guid?
    if (-not ($DriverPackGuid)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPackObject.GUID is not set. OK."
        return
    }
    #=================================================
    # Is there a URL?
    if (-not $($DriverPackObject.Url)) {
        Write-Warning "[$(Get-Date -format G)] DriverPackObject does not have a Url to validate."
        Write-Warning 'Press Ctrl+C to cancel OSDCloud'
        Start-Sleep -Seconds 86400
        exit
    }
    #=================================================
    # Is it reachable online?
    try {
        $WebRequest = Invoke-WebRequest -Uri $DriverPackObject.Url -UseBasicParsing -Method Head
        if ($WebRequest.StatusCode -eq 200) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPack URL returned a 200 status code. OK."
            return
        }
    }
    catch {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPack URL is not reachable."
    }
    #=================================================
    # Does the file exist on a Drive?
    $FileName = Split-Path $DriverPackObject.Url -Leaf
    $MatchingFiles = @()
    $MatchingFiles = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Get-ChildItem "$($_.Name):\OSDCloud\DriverPacks\" -Include "$FileName" -File -Recurse -Force -ErrorAction Ignore
    }
    
    if ($MatchingFiles) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPack is available offline. OK."
        return
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPack is not available offline."
    }
    #=================================================
    # DriverPack does not exist
    Write-Warning "[$(Get-Date -format G)] Unable to validate if the OperatingSystem is reachable online or offline."
    Write-Warning "[$(Get-Date -format G)] OSDCloud will continue without a DriverPack. Clearing variables."
    $global:OSDCloudWorkflowInit.DriverPackObject
    $global:OSDCloudWorkflowInit.DriverPackObject = $null
    $global:OSDCloudWorkflowInit.DriverPackName = 'None'
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] Continue $WorkflowName in 5 seconds..."
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Press CTRL+C to cancel"
    Start-Sleep -Seconds 5
    #endregion
    #=================================================
    # End the function
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    Write-Verbose -Message $Message; Write-Debug -Message $Message
    #=================================================
}