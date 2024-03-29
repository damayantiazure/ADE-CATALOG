param (
    [string]$IndexDocument = 'index.html',
    [string]$ErrorDocument404Path = '404.html',
    [string]$storageAccountName = '',
    [validateset('Enabled', 'Disabled')]
    [string]$StaticWebsiteState = 'Enabled'
)

function Get-StaticWebSiteState
{
    param (
        [string]$storageAccountName
    )
    try
    {
        $t = Get-AzAccessToken -ResourceTypeName Storage -ErrorAction Stop
        $splat = @{
            Uri     = "https://$storageAccountName.blob.core.windows.net/?restype=service&comp=properties"
            Method  = 'GET'
            Headers = @{
                Authorization  = "$($t.Type) $($t.Token)"
                'x-ms-date'    = [datetime]::UtcNow.ToString('R')
                'x-ms-version' = '2019-12-12'
                ContentType    = 'application/xml'
                ErrorAction    = 'Stop'
                Verbose        = $true
            }
        }
        Write-Host "Requesting current static website state [$storageAccountName]"
        [xml]$current = (Invoke-RestMethod @splat) -replace '.+<?xml', '<?xml' # remove BOM

        $StateLookup = @{
            'true'  = 'Enabled'
            'false' = 'Disabled'
        }
        return $StateLookup[$current.StorageServiceProperties.StaticWebsite.Enabled]
    }
    Catch
    {
        Write-Error "Error getting current static website state: $_"
        return
    }
}

$currentStaticWebsiteState = Get-StaticWebSiteState -storageAccountName $storageAccountName

if ($currentStaticWebsiteState -eq $StaticWebsiteState)
{
    $SkipSet = '1'
    $finalStaticWebsiteState = $currentStaticWebsiteState
    Write-Host "Static website state is already [$StaticWebsiteState]"
}
else 
{
    $SkipSet = '0'
    try
    {
        Write-Host "Settings Static website state to [$StaticWebsiteState]"
        $ctx = New-AzStorageContext -StorageAccountName $storageAccountName -ErrorAction Stop
        switch ($StaticWebsiteState)
        {
            'Enabled'
            {
                Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $IndexDocument -ErrorDocument404Path $ErrorDocument404Path
            }
            'Disabled'
            {
                Disable-AzStorageStaticWebsite -Context $ctx
            }
        }
        $finalStaticWebsiteState = Get-StaticWebSiteState -storageAccountName $storageAccountName
        Write-Host "Static website state is now [$finalStaticWebsiteState]"
    }
    Catch
    {
        Write-Error "Error setting static website state to [$StaticWebsiteState]: $_"
        return
    }
}

# $ctx = New-AzStorageContext -StorageAccountName $storageAccountName -ErrorAction Stop
# $webContainer = Get-AzStorageContainer -Name '$web' -Context $ctx -ErrorAction Stop
# $indexContent = '<html><head><title>Hello World</title></head><body><h1>Hello World</h1><p>This is your static web app, please deploy your code to get started.</p></body></html>'
# $indexContent | Set-AzStorageBlobContent -Container $webContainer -Blob $IndexDocument -Context $ctx -Properties @{'ContentType'='text/html'} -ErrorAction Stop
# $notFoundContent = '<html><head><title>404 Not Found</title></head><body><h1>404 Not Found</h1></body></html>'
# $notFoundContent | Set-AzStorageBlobContent -Container $webContainer -Blob $ErrorDocument404Path -Context $ctx -Properties @{'ContentType'='text/html'} -ErrorAction Stop



$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['SkipSet'] = $SkipSet
$DeploymentScriptOutputs['StaticWebsiteState'] = $finalStaticWebsiteState