param([io.fileinfo]$manifestFilePath)

# IncrementAndroidVersionCode
# Version 1.0
# 
# This script increments android version code.
# Place this in your the the folder containing the Properties folder.This is usually your Android project root.
# Alterntively can also provide a path to the AndroidManifest.xml


Write-Host ""
Write-Host "------- IncrementAndroidVersionCode.ps1 --------"

if($manifestFilePath -eq $null){

  Write-Host "No path to manifest file provided. Looking in current location..."
  $manifestFilePath = "$PSScriptRoot\Properties\AndroidManifest.xml"
}


$manifestFile=(Get-Item $manifestFilePath).FullName

if(-not $manifestFile){
    Write-Host "Could not find manifest file, provide a valid path or place this script correctly!"
    Write-Host "----------------- Script END --------------------"
    return
}

Write-Host "Using manifest file: " $manifestFile
[xml]$xml = gc $manifestFile

[string]$versionCode = [int]$xml.manifest.versionCode+1
$xml.manifest.versionCode = $versionCode
$xml.Save($manifestFilePath)
Write-Host "Sucessfully updated Android versionCode to: " $versionCode

Write-Host "----------------- Script END --------------------"