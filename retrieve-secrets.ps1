#variables
$pvwa_address = "" #your PVWA VIP/IP Address. do not include https, ex: your.company.com
$csv_full_path = "" #full path to CSV file create in sync-secrets.ps1
$app_id = "" #your app id
$secrets_safe_name = "" #name of safe secrets will be retrieved from

#run a test to see if the user can go to the web portal before returning credentials
$pvwa_status = Test-NetConnection $pvwa_address -Port 443

#if users can access PVWA, do not allow them to retrieve credentials via script, exit early
if ($true -eq $pvwa_status.TcpTestSucceeded)
{
    Write-Host "PVWA is up, use web portal for privileged credentials access. Press any key to continue."
    Pause
    exit
}

#declare array to store credentials
$credentials_array = @()

#for each item retrieved, create a row with password properties and add to the array
Import-Csv $csv_full_path | ForEach-Object{
    $results = cmd /c 'C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe'GetPassword /p AppDescs.AppID=$app_id /p Query="Safe=$($secrets_safe_name);Object=$($_.name)" /p RequiredProps=UserName,Address /o PassProps.UserName,PassProps.Address,Password
    $credential = $results.split(",")
    $row = New-Object psobject
    $row | Add-Member -NotePropertyName Username -NotePropertyValue $credential[0]
    $row | Add-Member -NotePropertyName Address -NotePropertyValue $credential[1]
    $row |Add-Member -NotePropertyName Password -NotePropertyValue $credential[2]
    $credentials_array += $row
}

#write the credentials to the console
$credentials_array | ForEach-Object { [PSCustomObject] $_ } | Format-Table
Pause