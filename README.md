# Azure Container Instances

Containers are now a mature solution providing an additional level of infrastructure abstraction. In many cases, containers can replace workloads traditionally powered by virtual machines.

We will look at [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/)

## Prerequisites

- [Get free Azure Subscription](https://azure.microsoft.com/en-us/free/)
- [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Install Docker Desktop](https://www.docker.com/products/docker-desktop)

## Overview

Azure Container Instances is a compute offering that bridges the gap between lightweight Azure Functions and more complex, but fully fledged Azure Kubernetes Service.

![Azure ACI Architecture](http://www.plantuml.com/plantuml/proxy?cache=yes&src=https://raw.githubusercontent.com/Piotr1215/dca-prep-kit/master/diagrams/azure-aci-architecture.puml&fmt=svg)
*Source: [https://docs.microsoft.com/en-us/azure/container-instances/container-instances-container-groups](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-container-groups)*

ACI is best suited for containerized workloads that can operate in isolation, simple apps, batch jobs including data science models, all kinds of tasks automation and integration scenarios.

- **Fast startup:** Launch containers in seconds.
- **Per second billing:** Incur costs only while the container is running.
- **Hypervisor-level security:** Isolate your application as completely as it would be in a VM.
- **Custom sizes:** Specify exact values for CPU cores and memory.
- **Persistent storage:** Mount Azure Files shares directly to a container to retrieve and persist state.
- **Linux and Windows:** Schedule both Windows and Linux containers using the same API.

## Differences between ACI and Azure Functions

![Azure ACI Architecture](http://www.plantuml.com/plantuml/proxy?cache=yes&src=https://raw.githubusercontent.com/Piotr1215/dca-prep-kit/master/diagrams/azure-aci-minmap.puml&fmt=svg)

## Examples

### Setup

We are going to deploy a sample web page. The idea is that with docker CLI and ACI we can rapidly prototype, test and deploy directly from docker command line!

> _Important node: this flow is only for testing purposes, in real code scenario you would have CI/CD pipeline deploying your app for you._

We are going to use bash with running docker daemon, but the same is of course possible with `powershell`.

> _Docker CLI contains now build-in integration with Azure Container Instances through a_ **_context_** _command. When using Azure CLI, you cat activate_ **_Azure Interactive_** _by typing_ `_az interactive_`_. This is an experimental feature of Azure CLI which gives you parameters completion and more!_

Now let’s deploy a test container!

### Deploy sample Web App

1. Run [ACI hello world image](https://hub.docker.com/r/microsoft/aci-helloworld) `az container create --resource-group RG-LEARNING-AZURE --name learning-azure --image mcr.microsoft.com/azuredocs/aci-helloworld --dns-name-label learning-aci --ports 80`
2. Great! Now show FDQN address and use browser to see container running: `az container show --resource-group RG-LEARNING-AZURE --name learning-azure --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" --out table` You should see “Welcome to Azure Container Instances!” as below.
3. Examine the container group in Azure
4. Cleanup resources

- Run `az container delete --resource-group RG-LEARNING-AZURE --name learning-azure` to delete the container
Running this command completely removes container group so there are no charges.

![](https://miro.medium.com/max/2298/1*8cz8mDNbxDofR59gv_VXug.png)

Success!

### Deploy sample Go API

#### Build docker container with Go API `docker build -t acrlearningazure.azurecr.io/go-api:v1.0 .`

> A note on building the image here. We are using *multi-stage builds* to make image size smaller as well as *distroless* base image for linux to lower potential attack surface.
> "Distroless" images contain only your application and its runtime dependencies. They do not contain package managers, shells or any other programs you would expect to find in a standard
> Linux distribution. For the purpose of class we are decorating the *Dockerfile* with commands outputing debug information while the image is being built. To do that, run the build command with `--progress=plain` flag, like so `docker build --progress=plain  -t acrlearningazure.azurecr.io/go-api:v1.0 .`. This will produce output from commands to stdout. Please read comments in the *Dockerfile* for more information.

#### Push the container to our registry `docker push acrlearningazure.azurecr.io/go-api:v1.0`

#### You might need to proved ACR username and password to start the container. Let's capture them into variables:

- `ACR_USERNAME=$(az acr credential show --resource-group RG-LEARNING-AZURE --name acrlearningazure --query username)` - linux
- `ACR_PASSWORD=$(az acr credential show --resource-group RG-LEARNING-AZURE --name acrlearningazure --query passwords[0].value)` - linux
- `$Env:ACR_USERNAME=$(az acr credential show --resource-group RG-LEARNING-AZURE --name acrlearningazure --query username)` - windows
- `$Env:ACR_PASSWORD=$(az acr credential show --resource-group RG-LEARNING-AZURE --name acrlearningazure --query passwords[0].value)` - windows

#### Run go api container

- `az container create --registry-username $ACR_USERNAME --registry-password $ACR_PASSWORD --resource-group RG-LEARNING-AZURE --name learning-azure-api --image acrlearningazure.azurecr.io/go-api:v1.0 --dns-name-label learning-aci-api --ports 8080` - linux
- `az container create --registry-username $Env:ACR_USERNAME --registry-password $Env:ACR_PASSWORD --resource-group RG-LEARNING-AZURE --name learning-azure-api --image acrlearningazure.azurecr.io/go-api:v1.0 --dns-name-label learning-aci-api --ports 8080` - windows


#### Now show FDQN address and use browser to see container running: `az container show --resource-group RG-LEARNING-AZURE --name learning-azure-api --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" --out table`

1. Obtain container IP and navigate to it appending `:8080/version` to call the API
2. Check contianer logs `az container logs --resource-group RG-LEARNING-AZURE --name learning-azure-api`
3. Cleanup resources

- Run `az container delete --resource-group RG-LEARNING-AZURE --name learning-azure-api` to delete the container
Running this command completely removes container group so there are no charges.

We’ve see how easy it is to deploy a container group directly to Azure Container Instances. This could be very useful for testing purposes and quick inner development loop.

There are a lot of great blogs and tutorials to check if you are interested to learn more.

- [Compose CLI ACI Integration Now Available](https://www.docker.com/blog/compose-cli-aci-integration-now-available/)
- [ACI pricing](https://azure.microsoft.com/en-gb/pricing/details/container-instances/)
- [Docker documentation](https://docs.docker.com/engine/context/aci-integration/)
- [Deploy minecraft](https://www.docker.com/blog/deploying-a-minecraft-docker-server-to-the-cloud/)
- [Compose Spec](https://www.compose-spec.io/)
- [VS Code integration](https://cloudblogs.microsoft.com/opensource/2020/07/22/vs-code-docker-extension-azure-containers-instances/)
- [Azure ACI Quickstart](https://docs.microsoft.com/en-us/azure/container-instances/quickstart-docker-cli)
- [Microsoft Learn](https://docs.microsoft.com/en-us/learn/modules/run-docker-with-azure-container-instances/)
- [Git repo as volume](https://docs.microsoft.com/en-gb/azure/container-instances/container-instances-volume-gitrepo)
- [Very cool demo with Mark Russinovich and Scott Hanselman on Azure Friday](https://www.youtube.com/watch?v=7G_oDLON7Us&ab_channel=MicrosoftAzure)
