param([string]$releaseName="", [string]$environment)

# UpdateNuspecSuffixVersion
# Version 1.2
# 
# This scripts takes a nuspec file and suffixes a either beta or rc folowed by buildnr


Write-Host ""
Write-Host "------- UpdateNuspecSuffixVersion.ps1  --------"

$tempStamp = "-temporary-nuspec"
$scriptExecDir =$PSScriptRoot
Write-Host "PSScriptRoot: " $PSScriptRoot
Write-Host "scriptExecDir: " $scriptExecDir
#Remove temporary all nuspecs
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


$fullFilename = (Get-Item $scriptExecDir\*.nuspec).FullName
$semiVer = $releaseName.Split("{-}")[1]

Write-Host "Tryig to Update version in " $fullFilename
$xml = [xml](Get-Content $fullFilename)

$version = $xml.package.metadata.version
$orgVersion = $version

if ($environment.CompareTo("QA") -eq 0) {
     $version = $version + "-rc" + $semiVer
}

if ($environment.CompareTo("DEV") -eq 0) {
     $version = $version + "-beta" + $semiVer
}

$xml.package.metadata.version = $version

$xml.Save($fullFilename)
Write-Host "Version updated from " $orgVersion " to " $xml.package.metadata.version

Write-Host "------- powershell script execution end --------"