#set your PVWA address
$pvwa_address = "1.1.1.1"

$csv_full_path = "C:\tmp\objectids.csv"
#run a test to see if the user can go to the web portal before returning credentials
$pvwa_status = Test-NetConnection $pvwa_address -Port 443

#if users can access PVWA, do not allow them to retrieve credentials via script, exit early
if ($true -eq $pvwa_status.TcpTestSucceeded)
{
    Write-Host "PVWA is up, use web portal for privileged credentials access. Exiting."
    exit
}

#declare array to store credentials
$credentials_array = @()

#for each item retrieved, create a row with password properties and add to the array
Import-Csv $csv_full_path | ForEach-Object{
    $results = & 'C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe'GetPassword /p AppDescs.AppID=offline1 /p Query="Safe=ship1;Folder=Root;Object=$($_.name)" /p RequiredProps=UserName,Address /o PassProps.UserName,PassProps.Address,Password
    $credential = $results.Split(",")
    $row = New-Object psobject
    $row | Add-Member -NotePropertyName Username -NotePropertyValue $credential[0]
    $row | Add-Member -NotePropertyName Address -NotePropertyValue $credential[1]
    $row |Add-Member -NotePropertyName Password -NotePropertyValue $credential[2]
    $credentials_array += $row
}

#write the credentials to the console
$credentials_array

