# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module Microsoft.VisualStudio.DSC

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

<#
.Synopsis
   Pester tests related to the Microsoft.VisualStudio.DSC PowerShell module.
#>

BeforeAll {
    Install-Module -Name PSDesiredStateConfiguration -Force -SkipPublisherCheck
    # Import-Module Microsoft.VisualStudio.DSC

    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Microsoft.VisualStudio.DSC\Microsoft.VisualStudio.DSC.psd1'
    Import-Module $modulePath -Force
}

Describe 'List available DSC resources' {
    It 'Should list all available DSC resources' {
        $expectedDSCResources = 'VSComponents'
        $availableDSCResources = (Get-DscResource -Module Microsoft.VisualStudio.DSC).Name
        $availableDSCResources.count | Should -Be 1
        $availableDSCResources | Where-Object { $expectedDSCResources -notcontains $_ } | Should -BeNullOrEmpty
    }

    # TODO: add more tests
}