param([string]$buildNr,[io.fileinfo]$manifestFilePath)

# AddBuildNrToAndroidVersionName
# Version 1.1
# 
# This script modifies or appends android versionName with a given build nr.

Write-Host ""
Write-Host "------- IncrementAndroidVersionCode.ps1 --------"

if($manifestFilePath -eq $null){

  Write-Host "No path to manifest file provided. Looking in current location..."
  $manifestFilePath = "$PSScriptRoot\Properties\AndroidManifest.xml"
}


$manifestFile=(Get-Item $manifestFilePath).FullName


[xml]$xml = gc $manifestFile
$parts = $xml.manifest.versionName.Split('.')

$nrOfParts = $parts.Count

if($nrOfParts -lt 3){
    Write-Host "Error: Your Android version name does not follow MAJOR.MINOR.POINT convention: To few parts"
    Write-Host "----------------- Script END --------------------"
    return
}
elseif($nrOfParts -eq 3){
    $newVersion = [System.String]::Concat($xml.manifest.versionName,".",$buildNr)
}
elseif($nrOfParts -gt 3){
    $parts[$nrOfParts-1] = $buildNr;
    $newVersion = [System.String]::Join(".",$parts)
}

$xml.manifest.versionName = $newVersion
$xml.Save($manifestFile)
Write-Host "Sucessfully updated Android versionName to: " $newVersion
Write-Host "----------------- Script END --------------------"