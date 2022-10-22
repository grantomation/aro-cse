# Custom Script Extension - OpenShift tooling

This Custom Script Extensions (CSE) can be used when deploying Azure Windows 11 VMs to install tooling that is useful for interacting with Azure Red Hat OpenShift (ARO).

It can be referenced directly from github in an ARM template or bicep file.

## Installs the following

* OpenShift command line tool "oc"
* Azure cli 
* Chocolately package manager
    - Firefox
    - Visual Studio Code
    - Git
* Create an env file in the C:\ to make gathering credentials and logging in to ARO quicker

# **Pull Requests are welcome!**