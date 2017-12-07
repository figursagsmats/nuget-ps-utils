
Param(
  [string]$configuration
)

# MakeLocalNugetPackage
# Version 1.2
#
# This script makes temporary a local copy of the nuspec-file, modifies it, and then creates a alpha-version of the
# package into a local folder. Thus, this folder must be added as a nuget-feed in your nuget.config
# 
# nuget cli is needed for this script to work

Write-Host ""
Write-Host "------- MakeLocalNugetPackage.ps1 --------"

if($configuration -eq "Debug"){
    Write-Host "Configuration is debug, not creating any local alpha version of package"
    Write-Host "----------------- Script END --------------------"
    return
}elseif($configuration -eq "Release"){
    Write-Host "Configuration is Release, trying to creating a local alpha version of package"
}else{
    Write-Host "Configuration is neither release or debug, something is very wrong. Exiting script execution..."
    Write-Host "----------------- Script END --------------------"
    return
}

#CONSTANTS
$scriptExecDir =$PSScriptRoot
$tempStamp = "-temporary-nuspec"
$tempPackageDir = $scriptExecDir +"\temp-package-source"
$suffix  ="-alpha"

#Create folder if not exits
If(!(test-path $tempPackageDir))
{
    New-Item -ItemType Directory -Force -Path $tempPackageDir
}

#Remove old temporarys

$potentialNuspecFiles = (Get-Item $scriptExecDir\*.nuspec).FullName
$nrOfNuspecFiles = $potentialNuspecFiles.Count

if($nrOfNuspecFiles -gt 1){
    for ($i = 0; $i -lt $nrOfNuspecFiles ; $i++) {
        
        $file = $potentialNuspecFiles[$i]

        if($file.Contains($tempStamp)){

            Remove-Item $file
            Write-Host "Removed old temporary nuspec-copy: " $file
        }
    }
}
# Now, this will give the right nuspec-file
$fullFilename = (Get-Item $scriptExecDir\*.nuspec).FullName

Write-Host "Remaining nuspec-file: " $fullFilename

# Make a temporary copy of the nuspec-file inorder to not pollute the original
$insertPos = $fullFilename.IndexOf(".nuspec")
$fullFileNameCopy = $fullFilename.Insert($insertPos,$tempStamp)
Copy-Item $fullFilename -Destination $fullFileNameCopy
Write-Host "Made a new temporary nuspec-copy: " $fullFileNameCopy


# Now its time to publish a local nuget packge to a local source.
# This package is intended for debugging and will be suffixed accordingly
$xml = [xml](Get-Content $fullFileNameCopy)
$version = $xml.package.metadata.version
$originalVersion = $version


$potentialNupkgFiles = (Get-Item $tempPackageDir\*.nupkg).FullName
$nrOfNupkgFiles = $potentialNupkgFiles.Count
$lastestLocalDebugVersion = 0;

$myArray = @()

if($nrOfNupkgFiles -lt 2){

    $potentialNupkgFiles = @($potentialNupkgFiles)
}

for ($i = 0; $i -lt $nrOfNupkgFiles ; $i++) {
        
    $file = $potentialNupkgFiles[$i]
    if($file.Contains($xml.package.metadata.id) -and $file.Contains($suffix)){

        $startIndex = $file.LastIndexOf($suffix)+$suffix.Length
        $endIndex = $file.IndexOf('.',$startIndex)
        if($endIndex-$startIndex -gt 0){

            $subString = $file.Substring($startIndex,$endIndex-$startIndex)

        }
        [int]$tempVer = $null

        if([int32]::TryParse($subString , [ref]$tempVer )){
            if($tempVer -gt $lastestLocalDebugVersion){                   
                $lastestLocalDebugVersion = $tempVer
            }
        }
    }
}


Write-Host "found latest local debug version to be:" $lastestLocalDebugVersion
$lastestLocalDebugVersion = $lastestLocalDebugVersion+1
$version = $version + $suffix+$lastestLocalDebugVersion
$xml.package.metadata.version = $version
$xml.Save($fullFileNameCopy)


Write-Host "Updated version in temporary copy from " $originalVersion " to " $xml.package.metadata.version

nuget.exe pack $fullFileNameCopy -outputDirectory $tempPackageDir
Write-Host "----------------- Script END --------------------"
Write-Host ""



