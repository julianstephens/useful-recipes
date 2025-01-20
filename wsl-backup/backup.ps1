# Backup WSL2 virtual disks using native functions and compress them using 7zip
## Will Presley, 2020
## willpresley.com

#### http://mats.gardstad.se/matscodemix/2009/02/05/calling-7-zip-from-powershell/
# Alias for 7-zip
if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) { throw "$env:ProgramFiles\7-Zip\7z.exe needed" }
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
#### Alternative native PS 7-zip: https://www.sans.org/blog/powershell-7-zip-module-versus-compress-archive-with-encryption/

################### Variables ###################
$wslDistName = "Ubuntu"
$currentDate = (Get-Date).ToString('yyyy-MM-dd')
$backupDirectory = ""
$backupName = "wsl_ubuntu"
$backupLimitDays = 90

$ftp_user = ""
$ftp_pwd = ""
$ftp_host = ""
$ftp_port = 21
$ftp_path = ""

$fileName = -join ("$backupName", "_", "$currentDate", ".tar")
$filePath = -join ("$backupDirectory", "\", "$fileName")

$ftpUrl = -join ("ftp://", "$ftp_user", ":", "$ftp_pwd", "@", "$ftp_host", ":", "$ftp_port", "/", "$ftp_path", "/", "$fileName", ".7z")

################ End of Variables ###############

if (!(Test-Path "$filePath.7z")) {
    ## Run the export to get the .tar file
    Write-Host -Object "Generating backup..."
    wsl --export "$wslDistName" "$filePath"

    ## Let's compress it using 7zip and max compression, and use -sdel to delete the original file after successful compression
    Write-Host -Object "Compressing backup..."
    sz a -t7z -mx=9 -sdel "$filePath.7z" "$filePath"
}

## Upload backup via FTP
$webclient = New-Object -TypeName System.Net.WebClient
$uri = New-Object -TypeName System.Uri -ArgumentList $ftpUrl
Write-Host -Object "Uploading $filePath.7z..."
try {
    $rawResponse = $webclient.UploadFile($uri, "$filePath.7z")
    $res = $webclient.Encoding.GetString($rawResponse)
    Write-Host $res
}
catch [System.Net.WebException] {
    $Request = $_.Exception
    Write-host "Exception caught: $Request"
    $crapMessage = ($_.Exception.Message).ToString().Trim()
    Write-Output $crapMessage$
}
catch {
    Write-Host "An error occurred that could not be resolved."
}

## Clean backup dir
$limit = (Get-Date).AddDays(-$backupLimitDays)
Get-ChildItem -Path $backupDirectory -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

