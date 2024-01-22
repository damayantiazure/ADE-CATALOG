# Azure Deployment Environment Demo

This repository contains some "curated" ```Bicep``` templates to demonstrate that platform engineering team 
can publish them into the catalog Azure Deployment Envrionment for developers to consume.

## Explanation

Each folder inside ```infrastructure-templates``` folder contains a ```Bicep``` file, and if they are meant
to be published as a catalog item, they are accompaied by a ```manifest.yaml``` file.

> Note: The bicep file in this repo **must** be named ```main.bicep``` because the workflow tries to compile them to ARM templates with the assumed name.

## How to use

The ```infrastructure-templates``` folder is the root folder for the catalog items. Each folder inside it is a catalog item.
Once they are commited to GitHub the workflow will detects if there are changes made into any Bicep files, if there are, it will compile them to ARM templates and publish them to the catalog.

## Consume as Developer

Once the templates are published to the catalog, developers can consume them by using the ```az devcenter``` or ```azd``` command.

### Using Azure CLI 

> Note: We are using ```--%``` to indicate that the rest of the command is a JSON string. This is needed because the parameters are a JSON string and we need to pass it as is to the command.

```powershell
    az devcenter dev environment create --dev-center-name  NebulaDevCenter --project-name SalesOrderManagement --catalog-name Catalog1  --environment-definition-name LogAnalyticsWorkspace --environment-name LARGP001 --environment-type Pre-Production --user-id 015f84bd-2d24-43d8-a03a-32349d1e2148 --% --parameters "{\"logAnalyticsName\":\"moiha2023\"}"
```

### Using Azure Developer CLI

### Pre-requisites

The following pre-requisites are needed to use the Azure Developer CLI:

- Install Azure Developer CLI
- Install Azure Developer CLI extension for Visual Studio Code

### Provision environment

You need to do the following in a terminal.

> NOTE: This is very important for azd to talk to Azure via the CLI login info: ```azd config set auth.useAzCliAuth "true"```

```powershell
    
    az login # Login to Azure    
    az account set --subscription <subscription-id> # Set the subscription    
    azd init # You might need to initialize the azd extension
    azd config set auth.useAzCliAuth "true" # Set the authentication to use Azure CLI

    # Create the environment
    azd provision  # this should prompt you to select the catalog item and the parameters

```


## How to contribute

Feel free to add more templates to this repository. The workflow will automatically detect the changes and publish them to the catalog.
