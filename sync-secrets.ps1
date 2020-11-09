#set your variables
$pvwa_uri = "" #address of your pvwa. ex: https://your.company.com
$csv_folder_path = "" #path of folder where the CSV will be stored
$csv_file_name = "" #name of file ex: objectids.csv
$csv_full_path = $csv_folder_path + "\" + $csv_file_name
$app_id = "" #appid must be configured in CyberArk
$api_user_safe_name = "" #safe where user that will connect to API is stored
$api_user_object_name = "" #object name of API user
$api_user_username = "" #username of API user
$sync_safe_name = "" #name of safe to sync

#test to see if your csv exists. If not, create it
if (!(Test-Path $csv_full_path))
{
    New-Item -Path $csv_folder_path -Name $csv_file_name -ItemType File
}

#import your csv for evaluation
$csv = Import-Csv -Path $csv_full_path

#get API user password
$api_password = cmd /c 'C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe'GetPassword /p AppDescs.AppID=$app_id /p "Query=Safe=$api_user_safe_name;Object=$api_user_object_name" /o password | ConvertTo-SecureString -AsPlainText -Force
$api_credential = New-Object System.Management.Automation.PSCredential ($api_user_username, $api_password)
#start new session
New-PASSession -Credential $api_credential -BaseURI $pvwa_uri -type LDAP

#get all accounts in the first safe
$accounts = Get-PASAccount -filter "SafeName eq $($sync_safe_name)"

#loop through all accounts in the safe. If it's already in the csv, nothing to do, if not, retrieve the cred for storage
# in the Credential Provider & add the object name to the list of objects in the vault to retrieve during an outage 
foreach($account in $accounts){
    if($account.name -notin $csv.name)
    {
        cmd /c 'C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe'GetPassword /p AppDescs.AppID=$app_id /p "Query=Safe=$sync_safe_name;Object=$($account.name)"
        $account | Select-Object -Property name | Export-Csv -Path $csv_full_path -Append
    }
}