# SimpleFIN Authentication

#### Create a setup token

![image](https://github.com/user-attachments/assets/f6463317-9427-4e45-bc50-c7bcf76587de)

![image](https://github.com/user-attachments/assets/ee0a9c28-a217-4c3a-bf04-2d5626166749)

You have now completed STEP 1 of https://beta-bridge.simplefin.org/info/developers

#### Open PowerShell and execute:

```powershell
#save your base64 setup token to a variable
$setupToken = "<INSERT YOUR SETUP TOKEN BASE64 HERE>"

#convert from base64
$claimURL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($setupToken))

#invoke an HTTP POST to display the scheme://username:password@uri
Invoke-RestMethod -Uri $claimURL -Method Post
```

#### Example Screenshot

![image](https://github.com/user-attachments/assets/383cbe97-1a3e-4ef8-8b69-e67a167335b3)

Returned/underlined are your username and password that should be plugged into the simplefin_to_maybe config:

![image](https://github.com/user-attachments/assets/34b4189c-1606-4f5c-878b-6a82aac79ff5)

You have now completed STEP 2 of https://beta-bridge.simplefin.org/info/developers
