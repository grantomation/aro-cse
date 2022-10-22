param (
    [string]$clusterRG,
    [string]$clusterName
)

# Create the directory for OpenShift CLI tool
New-Item -ItemType Directory c:\OC

# Change to that directory
cd c:\OC

# Download the latest openshift windows cli
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-windows.zip -OutFile C:\OC\oc.zip

# Set the path permanently
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$oldpath;c:\OC"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath

# Extract the archive
Expand-Archive -Force -Path c:\OC\oc.zip -DestinationPath c:\OC

# Download and Install Azure CLI
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# Install Chocolately
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Chocolately packages
choco install firefox -y
choco install vscode -y
choco install git -y

# Create a powershell env file so that once the AZ CLI is logged in then it is easy to log in to OpenShift
echo @"
# To source this file in powershell please run '. C:\env.ps1'
    `$CLUSTER = "$clusterName"
    `$RESOURCEGROUP = "$clusterRG"
    `$CLUSTER = `$(az resource list -g `$RESOURCEGROUP --query "[?type == 'Microsoft.RedHatOpenShift/OpenShiftClusters'].name" -o tsv)
    `$KUBE_PWD = `$(az aro list-credentials -n `$CLUSTER -g `$RESOURCEGROUP --query kubeadminPassword -o tsv)
    `$API_ENDPOINT = `$(az aro show -n `$CLUSTER -g `$RESOURCEGROUP --query apiserverProfile.url -o tsv)
    `$CONSOLE = `$(az aro show -n `$CLUSTER -g `$RESOURCEGROUP --query consoleProfile.url -o tsv)

function aro_password()
{
   echo `$KUBE_PWD

}

function aro_details()
{
    echo `$CONSOLE
    echo `$KUBE_PWD
}

function aro_login ()
{
    oc login -u kubeadmin -p `$KUBE_PWD `$API_ENDPOINT
}
"@ > c:\env.ps1

# Create a bash env file so that once the AZ CLI is logged in then it is easy to log in to OpenShift
echo @"
#!/usr/bin/bash
# To source this file from bash please 'source /c/env.sh'
    CLUSTER="$clusterName"
    RESOURCEGROUP="$clusterRG"
    KUBE_PWD=$(az aro list-credentials -n `$CLUSTER -g `$RESOURCEGROUP --query kubeadminPassword -o tsv)
    API_ENDPOINT=$(az aro show -n `$CLUSTER -g `$RESOURCEGROUP --query apiserverProfile.url -o tsv)
    CONSOLE=$(az aro show -n `$CLUSTER -g `$RESOURCEGROUP --query consoleProfile.url -o tsv)

function aro_password()
{
   echo `$KUBE_PWD

}

function aro_details()
{
    echo `$CONSOLE
    echo `$KUBE_PWD
}

function aro_login ()
{
    oc login -u kubeadmin -p `$KUBE_PWD `$API_ENDPOINT
}
"@ > c:\env.sh

