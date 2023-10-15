# Visual Studio Desired State Configuration (DSC) Resource Provider

DSC resources to simplify state management of installed Visual Studio instances.

## VSComponents Resource

The `VSComponents` resource is used to modify a pre-existing Visual Studio instance in order to add additional [components](https://learn.microsoft.com/visualstudio/install/workload-and-component-ids). It is meant to accompany the [`winget configure`](https://learn.microsoft.com/windows/package-manager/winget/configure) command. 

You currently need administrator permissions to use this resource to install or modify Visual Studio. Furthermore, Visual Studio must be closed in order to update or add components to it. 

Refer to [Use winget to install or modify Visual Studio](https://learn.microsoft.com/visualstudio/install/use-command-line-parameters-to-install-visual-studio?#use-winget-to-install-or-modify-visual-studio) for additional information. 

### Parameters

At least `VSConfigFile` or `Components` must be specified. You can also specify both simultaneously.

**Parameter**|**Attribute**|**DataType**|**Description**|**Allowed Values**
:-----|:-----|:-----|:-----|:-----
`ProductId`|Key|String|The product identifier of the instance you are working with. EG: `Microsoft.VisualStudio.Product.Community`|See [workload and component ids](https://learn.microsoft.com/visualstudio/install/workload-and-component-ids)
`ChannelId`|Key|String|The channel identifier of the instance you are working with. EG: `VisualStudio.17.Release`|See [channel identifiers](https://learn.microsoft.com/visualstudio/install/command-line-parameter-examples#using---channeluri)
`Components`|Optional|StringArray[]|Collection of component identifiers you wish to update the provided instance with.|See [workload and component ids](https://learn.microsoft.com/visualstudio/install/workload-and-component-ids)
`VSConfigFile`|Optional|String|Path to the [Installation Configuration (VSConfig) file](https://learn.microsoft.com/visualstudio/install/import-export-installation-configurations) you wish to update the provided instance with.|Valid file path to a .vsconfig file
`IncludeRecommended`|Optional|Boolean|For the provided required components, also add recommended components into the specified instance|True/False
`IncludeOptional`|Optional|Boolean|For the provided required components, also add optional components into the specified instance|True/False
`InstalledComponents`|NotConfigurable|StringArray[]|A collection of components installed in the Visual Studio instance identified by the provided Product ID and Channel ID.|N/A


## Installation

To use this resource provider, you must first install it as a PowerShell module. Installation instructions and options can be found on the PowerShell Gallery [here](https://www.powershellgallery.com/packages/Microsoft.VisualStudio.DSC).

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
