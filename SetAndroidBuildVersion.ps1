param([io.fileinfo]$package, [string]$version, [string]$dir)

# SetAndroidBuildVersion
# Version 1.0
# 
# This script modifies android build version 

[Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath

[xml]$xml = gc $package
$parts = $xml.manifest.versionName.Split('.')
$parts[2] = $version;
$newVersion = [System.String]::Join(".", $parts);

$xml.manifest.versionName = $newVersion;
$xml.manifest.versionCode = $version;
$xml.Save($package);
