# offline-cache
This is a theoretical example of how to retrieve credentails if your system is offline and datacenter does not have PVWA access. 

sync-secrets.ps1 should be ran as a scheduled task to retrieve new credentials and to keep the csv file up to date with necessary object names for retrieval when offline. 

retrieve-secrets.ps1 can be ran by users to retrieve credentials when unable to access the PVWA. Addtional authentication methods and checks can be added to limit tampering instances. 

It's recommended that scripts be hashed to prevent tampering. 