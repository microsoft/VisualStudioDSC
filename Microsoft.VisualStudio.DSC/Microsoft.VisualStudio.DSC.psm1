# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#Requires -RunAsAdministrator

using namespace System.Collections.Generic
using namespace System.Diagnostics

[DSCResource()]
class VSComponents
{
    [DscProperty(Key)]
    [string]$productId

    [DscProperty(Key)]
    [string]$channelId

    [DscProperty()]
    [string[]]$components

    [DscProperty()]
    [string]$vsConfigFile

    [DscProperty()]
    [bool]$includeRecommended = $false

    [DscProperty()]
    [bool]$includeOptional = $false

    [DscProperty(NotConfigurable)]
    [string[]]$installedComponents

    [VSComponents] Get()
    {
        $this.installedComponents = Get-VsComponents -ProductId $this.productId -ChannelId $this.channelId

        return @{
            productId = $this.productId
            channelId = $this.channelId
            components = $this.components
            vsConfigFile = $this.vsConfigFile
            includeRecommended = $this.includeRecommended
            includeOptional = $this.includeOptional
            installedComponents = $this.installedComponents
        }
    }

    [bool] Test()
    {
        if(-not $this.components -and -not $this.vsConfigFile)
        {
            throw "No components specified to be added. Specify either an Installation Configuration (VSConfig) file, individual required components, or both."
        }

        $this.Get()
        $requestedComponents = $this.components

        if ($this.vsConfigFile)
        {
            if(-not (Test-Path $this.vsConfigFile))
            {
                throw "Provided Installation Configuration file does not exist at $($this.vsConfigFile)"
            }

            $requestedComponents += Get-Content $this.vsConfigFile | Out-String | ConvertFrom-Json | Select-Object -ExpandProperty components
        }

        foreach ($component in $requestedComponents)
        {
            if ($this.installedComponents -notcontains $component)
            {
                return $false
            }
        }  

        return $true
    }

    [void] Set()
    {
        if ($this.Test())
        {
            return
        }

        Add-VsComponents -ProductId $this.productId -ChannelId $this.channelId -VsConfigPath $this.vsConfigFile -Components $this.components -IncludeRecommended $this.includeRecommended -IncludeOptional $this.includeOptional
    }
}

<#
.SYNOPSIS
    Returns a collection of components identifiers installed in the Visual Studio instance identified by the provided Product ID and Channel ID.

.PARAMETER ProductId
    The product identifier of the instance you are working with. EG: 'Microsoft.VisualStudio.Product.Community'

.PARAMETER ChannelId
    The channel identifier of the instance you are working with. EG: 'VisualStudio.17.Release'

.LINK
    https://learn.microsoft.com/en-us/visualstudio/install/workload-and-component-ids

.LINK
    https://learn.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples#using---channelId
#>
function Get-VsComponents
{
    param
    (
        [Parameter(Mandatory)]
        [string]$ProductId,

        [Parameter(Mandatory)]
        [string]$ChannelId
    )

    $result = Invoke-VsWhere -Arguments "-products $ProductId -include packages -format json -all -prerelease" | ConvertFrom-Json | Where-Object { $_.channelId -eq $ChannelId }
    return $result.packages | Where-Object { $_.type -eq "Component" -or $_.type -eq "Workload" } | Select-Object -ExpandProperty id 
}

<#
.SYNOPSIS
    Adds components and workloads identified by the provided component list & Installation Configuration (VSConfig) file into the specified instance

.PARAMETER ProductId
    The product identifier of the instance you are working with. EG: 'Microsoft.VisualStudio.Product.Community'

.PARAMETER ChannelId
    The channel identifier of the instance you are working with. EG: 'VisualStudio.17.Release'

.PARAMETER Components
    Collection of component identifiers you wish to update the provided instance with.

.PARAMETER VsConfigPath
    Path to the Installation Configuration (VSConfig) file you wish to update the provided instance with.

.PARAMETER IncludeRecommended
    For the provided required components, also add recommended components into the specified instance

.PARAMETER IncludeOptional
    For the provided required components, also add optional components into the specified instance

.LINK
    https://learn.microsoft.com/en-us/visualstudio/install/workload-and-component-ids

.LINK
    https://learn.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples#using---channelId

.LINK
    https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio#install-update-modify-repair-uninstall-and-export-commands-and-command-line-parameters

.LINK
    https://devblogs.microsoft.com/setup/configure-visual-studio-across-your-organization-with-vsconfig/
#>
function Add-VsComponents
{
    param
    (
        [Parameter(Mandatory)]
        [string]$ProductId,

        [Parameter(Mandatory)]
        [string]$ChannelId,
        
        [Parameter()]
        [string[]]$Components,

        [Parameter()]
        [string]$VsConfigPath,

        [Parameter()]
        [bool]$IncludeRecommended,
        
        [Parameter()]
        [bool]$IncludeOptional
    )
    
    $installerArgs = "modify --productId $ProductId --channelId $ChannelId --quiet --norestart --noupdateinstaller"

    if(-not $Components -and -not $VsConfigPath)
    {
        throw "No components specified to be added. Specify either an Installation Configuration (VSConfig) file, individual required components, or both."
    }

    if($VsConfigPath)
    {
        if(-not (Test-Path $VsConfigPath))
        {
            throw "Provided Installation Configuration file does not exist at $VsConfigPath"
        }

        $installerArgs += " --config `"$VsConfigPath`""
    }

    if($Components)
    {
        $installerArgs += " --add " + ($Components -join ' --add ');
    }

    if($IncludeRecommended)
    {
        $installerArgs += " --includeRecommended"
    }

    
    if($IncludeOptional)
    {
        $installerArgs += " --includeOptional"
    }

    Invoke-VsInstaller -Arguments $installerArgs
}

<#
.SYNOPSIS
    Invokes Visual Studio Installer, if it exists, with the provided arguments.

.DESCRIPTION
    Invokes Visual Studio Installer with the provided arguments.
    If this script is not run as an administrator, without the installer present, or with the installer process running, this script will fail.
    The invocation is considered successful if return codes of 0 (success), 3010 (reboot required) or 862968 (reboot recommended) are returned.

.PARAMETER Arguments
    Arguments to pass onwards to Visual Studio Installer.

.LINK
    https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio
#>
function Invoke-VsInstaller
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Arguments
    )

    Assert-IsAdministrator
    Assert-VsInstallerPresent
    Assert-VsInstallerProcessNotRunning

    $installer = Start-Process -FilePath (Get-VsInstallerPath) -ArgumentList $Arguments -PassThru
    $installer.WaitForExit();

    # See script block description for error code explanation
    $validErrorCodes = 0,3010,862968;
    if($installer.ExitCode -NotIn $validErrorCodes)
    {
        throw "Visual Studio Installer failed with error code $($installer.ExitCode) using arguments: $Arguments"
    }
}

<#
.SYNOPSIS
    Invokes Visual Studio Locator, if it exists, with the provided arguments.

.DESCRIPTION
    Invokes Visual Studio Locator (vswhere.exe) with the provided arguments.
    If this script is run without the locator present, it will fail.

.PARAMETER Arguments
    Arguments to pass onwards to Visual Studio Locator.

.LINK
    https://learn.microsoft.com/en-us/visualstudio/install/tools-for-managing-visual-studio-instances#using-vswhereexe
#>
function Invoke-VsWhere
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Arguments
    )

    Assert-VsWherePresent

    return Invoke-Expression -Command "&'$(Get-VsWherePath)' $Arguments"
}

<#
.SYNOPSIS
    Throws an exception if not running elevated.
#>
function Assert-IsAdministrator
{
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        throw "This resource must be run as an Administrator."
    }
}

<#
.SYNOPSIS
    Returns the default path of Visual Studio Installer.
#>
function Get-VsInstallerPath
{
    return Join-Path -Path "${env:ProgramFiles(x86)}" -ChildPath "Microsoft Visual Studio\Installer\setup.exe"
}

<#
.SYNOPSIS
    Returns the default path of Visual Studio Locator (vswhere.exe).
#>
function Get-VsWherePath
{
    return Join-Path -Path "${env:ProgramFiles(x86)}" -ChildPath "Microsoft Visual Studio\Installer\vswhere.exe"
}

<#
.SYNOPSIS
    Throws an exception if Visual Studio Installer is not present in the default location.
#>
function Assert-VsInstallerPresent
{
    if(-not (Test-Path (Get-VsInstallerPath)))
    {
        throw "Visual Studio Installer not found."
    }
}

<#
.SYNOPSIS
    Throws an exception if Visual Studio Locator (vswhere.exe) is not present in the default location.
#>
function Assert-VsWherePresent
{
    if(-not (Test-Path (Get-VsWherePath)))
    {
        throw "Visual Studio Locator not found."
    }
}

<#
.SYNOPSIS
    Throws an exception if Visual Studio Installer is currently running.
#>
function Assert-VsInstallerProcessNotRunning
{
    if (Get-Process | Where-Object { $_.Path -eq (Get-VsInstallerPath) })
    {
        throw "Visual Studio Installer is running. Close the installer and try again."
    }
}