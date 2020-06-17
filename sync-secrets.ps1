#set your variables
$pvwa_uri = "https://pvwa.yourcompany.com"
$csv_folder_path = "C:\tmp"
$csv_file_name = "objectids.csv"
$csv_full_path = $csv_folder_path + "\" + $csv_file_name

#test to see if your csv exists. If not, create it
if (!(Test-Path $csv_full_path))
{
    New-Item -Path $csv_folder_path -Name $csv_file_name -ItemType File
}

#import your csv for evaluation
$csv = Import-Csv -Path $csv_full_path

#get API user password
$api_password = & 'C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe'GetPassword /p AppDescs.AppID=offline1 /p Query="Safe=ship1;Folder=Root;Object=ship1_sync" /o Password | ConvertTo-SecureString -AsPlainText -Force
$api_credential = New-Object System.Management.Automation.PSCredential ("ship1_sync", $api_password)

#start new session
New-PASSession -Credential $api_credential -BaseURI $pvwa_uri

#get all accounts in the first safe
$accounts = Get-PASAccount -filter "SafeName eq ship1"

#loop through all accounts in the safe. If it's already in the csv, nothing to do, if not, retrieve the cred for storage
# in the Credential Provider & add the object name to the list of objects in the vault to retrieve during an outage 
foreach($account in $accounts){
    if($account.name -notin $csv.name)
    {
        & 'C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe'GetPassword /p AppDescs.AppID=offline1 /p Query="Safe=ship1;Folder=Root;Object=$($account.name)"
        $account | Select-Object -Property name, username | Export-Csv -Path $csv_full_path -Append
    }
}

Close-PASSession