# Prepare the migration file
Update the imageMigration.json file

```json {
    "sourceImages":[
        {
            "sourceImageName":"mcr.microsoft.com/appsvc/middleware:stage0"
        }
    ],
    "destinationRegistry":"arianacr001.azurecr.io"
}
```


# Login and Setup a connection to the correct Az subscription / acr instance:

```
az login --use-device-code

az account set --subscription <yourSubscription>

az acr login -n <acrName>
```

# Run the ImageMover powershell script

```
.\ImageMover.ps1
```