# Visual Studio Desired State Configuration (DSC) Resource Provider

DSC resources to simplify state management of installed Visual Studio instances.

## AddVSComponents Resource

The `AddVSComponents` resource is used to modify a pre-existing Visual Studio instance state with additional components.

### Parameters

At least `VSConfigFile` or `Components` must be specified. You can also specify both simultaneously.

**Parameter**|**Attribute**|**DataType**|**Description**|**Allowed Values**
:-----|:-----|:-----|:-----|:-----
`ProductId`|Key|String|The product identifier of the instance you are working with. EG: `Microsoft.VisualStudio.Product.Community`|See [workload and component ids](https://learn.microsoft.com/en-us/visualstudio/install/workload-and-component-ids)
`ChannelId`|Key|String|The channel identifier of the instance you are working with. EG: `VisualStudio.17.Release`|See [channel identifiers](https://learn.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples#using---channelId)
`Components`|Optional|StringArray[]|Collection of component identifiers you wish to update the provided instance with.|See [workload and component ids](https://learn.microsoft.com/en-us/visualstudio/install/workload-and-component-ids)
`VSConfigFile`|Optional|String|Path to the [Installation Configuration (VSConfig) file](https://devblogs.microsoft.com/setup/configure-visual-studio-across-your-organization-with-vsconfig/) you wish to update the provided instance with.|Valid file path to a .vsconfig file
`IncludeRecommended`|Optional|Boolean|For the provided required components, also add recommended components into the specified instance|True/False
`IncludeOptional`|Optional|Boolean|For the provided required components, also add optional components into the specified instance|True/False
`InstalledComponents`|NotConfigurable|StringArray[]|A collection of components installed in the Visual Studio instance identified by the provided Product ID and Channel ID.|N/A


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
