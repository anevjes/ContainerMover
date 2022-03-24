[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SourceRegistry,

    [Parameter()]
    [string]
    $DestinationRegistry,
        
    [Parameter()]
    [string]
    $ParameterName
)
Install-Module powershell-yaml -Force
Import-Module powershell-yaml -Force

.\Scripts\Helper.ps1

function Login-Acr {
    param (
        [string] $RegistryName,
        [object] $Credential 
    )
    az login -
    az acr login --name myregistry
    
}

function Get-ContainerImage {
    param (
        [string] $SourceRegistry,
        [string] $WorkingDirPath,
        [string] $imageName
    )

    docker pull
    
}


function Parse-HelmChart {
    param (
        [string] $InputPath,
        [string] $OutputPath
    )
    #Scenarios:
    #Deployments and pod specs to inspect for images: 
    #Hardcoded image name in helm tmeplate file
    #docker tag
    #podman

    $helmContents = Get-Content -Path $InputPath -Raw
    Write-Host "Parsing [$InputPath]"
    $obj = ConvertFrom-Yaml $helmContents -AllDocuments
    $obj

}

function Update-HelmCharts {
    param (
        [string] $ChartUrl,
        [string] $ChartName,
        [string] $OutputDir
    )

    $outputDirFull = $("$OutputDir\$ChartName")
    if ((Test-Path -Path $outputDirFull) -eq $False) {

        New-Item -ItemType Directory -Path $outputDirFull
    }

    cd $outputDirFull

    helm.exe repo add helmrepo $ChartUrl
    helm.exe pull $("helmrepo/$ChartName") 

    $tgz = Get-ChildItem $outputDirFull -File

    if ((Test-Path -Path $("$outputDirFull\temp")) -eq $False) {

        New-Item -ItemType Directory -Path $("$outputDirFull\temp")
    }

    tar -xvzf $($tgz.FullName) -C $("$outputDirFull\temp")
    
    $templatesDir = Get-ChildItem $("$outputDirFull\temp") -recurse | Where-Object { $_.PSIsContainer -eq $true -and $_.Name -imatch "templates" }
    $templates = $null

    foreach ($td in $templatesDir) {
        $templates += Get-ChildItem $td.FullName | Where-Object {$_.Extension -eq '.yaml'}
    }

    foreach ($template in $templates) {
        Parse-HelmChart -InputPath $template.FullName -OutputPath 'ddd'
    }

}




#Tests:
# Update-HelmCharts -ChartUrl 'https://charts.bitnami.com/bitnami' -ChartName 'redis' -OutputDir "C:\repos\anevjes\ContainerRegistry\test"
