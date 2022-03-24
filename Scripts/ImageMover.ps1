$InformationPreference = 'Continue'

function Get-ContainerImage {
    param (
        [string] $SourceImageName

    )
    
    Write-Information "Pulling image from [$SourceImageName]"
    
    docker pull $SourceImageName
    
}

function Push-ContainerImageToACR {
    param (
        [string] $DestinationRegistry,
        [string] $SourceImageName,
        [string] $DestinationImageName,
        [string] $Tag
    )

    $destinationLocation = "{0}/{1}:{2}" -f $DestinationRegistry, $DestinationImageName, $Tag
    Write-Information "DestinationLocation: $destinationLocation"

    docker tag $SourceImageName $destinationLocation
    docker push $destinationLocation

}

function ExtractImageParams {
    param (
        [string] $FullImageName
    )

    $registryImagePath = $FullImageName.Substring($FullImageName.IndexOf('/') + 1, $FullImageName.IndexOf(':') - $FullImageName.IndexOf('/') - 1)
    $tag = $FullImageName.Substring($FullImageName.IndexOf(':') + 1, $FullImageName.Length - $FullImageName.IndexOf(':') - 1 )

    $newImageParams = New-Object PSObject -Property @{
        registryImagePath = $registryImagePath
        tag               = $tag
    }
    return $newImageParams
}




$imageMigration = ConvertFrom-Json -InputObject (Get-Content .\imageMigration.json -Raw)

$sourceImages = $imageMigration.sourceImages
$destinationRegistry = $imageMigration.destinationRegistry

foreach ($sourceImage in $sourceImages) {

    $newImageParams = ExtractImageParams -FullImageName $($sourceImage.sourceImageName)
    Get-ContainerImage -SourceImageName $sourceImage.sourceImageName
    Push-ContainerImageToACR -DestinationRegistry $destinationRegistry -SourceImageName $sourceImage.sourceImageName -DestinationImageName $newImageParams.registryImagePath -tag $newImageParams.tag

}


