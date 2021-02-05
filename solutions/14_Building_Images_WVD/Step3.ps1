## Step 3 : Create the Shared Image Gallery 

```powerShell
$sigGalleryName= "SIG"
$imageDefName ="Win10ms-20H2"
$imageDefName2 ="Win10msO365-20H2"
$imageResourceGroup="AIB-RG"
$location="westus2"

# create SIG
New-AzGallery -GalleryName $sigGalleryName -ResourceGroupName $imageResourceGroup  -Location $location

# create gallery definition for Win10ms
New-AzGalleryImageDefinition -GalleryName $sigGalleryName -ResourceGroupName $imageResourceGroup -Location $location -Name $imageDefName -OsState generalized -OsType Windows -Publisher 'myCo' -Offer 'Windows' -Sku 'Win10ms-20H2'

# create gallery definition for Win10msO365
New-AzGalleryImageDefinition -GalleryName $sigGalleryName -ResourceGroupName $imageResourceGroup -Location $location -Name $imageDefName2 -OsState generalized -OsType Windows -Publisher 'myCo' -Offer 'office-365' -Sku 'Win10msO365-20H2'

# Configure the Image Template
For this example we have a template ready to that will download and update the template with the parameters specified earlier, it will install FsLogix, OS Optimizations, Teams and run Windows Update at the end.

If you open the template you can see in the source property the image that is being used, in this example it uses a Win 10 Multi session image. 

## Windows 10 images
Two key types you should be aware of:

### Multi session
These images are intend for pooled usage, below is the image details in Azure:

```json
"publisher": "MicrosoftWindowsDesktop",
"offer": "Windows-10",
"sku": "20h2-evd",
"version": "latest"
```

### Single session
These images are intend for induvidual usage, below is the image details in Azure:
```json
"publisher": "MicrosoftWindowsDesktop",
"offer": "Windows-10",
"sku": "19h2-ent",
"version": "latest"
```

You can also change the Win10 images available:
```powerShell
Get-AzVMImageSku -Location westus2 -PublisherName MicrosoftWindowsDesktop -Offer windows-10
```

## Download template and configure
```powerShell

$templateUrl="https://raw.githubusercontent.com/RoelDU/azvmimagebuilder/master/armTemplateWVD.json"
$templateFilePath = "armTemplateWVD.json"

Invoke-WebRequest -Uri $templateUrl -OutFile $templateFilePath -UseBasicParsing

((Get-Content -path $templateFilePath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<rgName>',$imageResourceGroup) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region>',$location) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<runOutputName>',$runOutputName) | Set-Content -Path $templateFilePath

((Get-Content -path $templateFilePath -Raw) -replace '<imageDefName>',$imageDefName2) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<sharedImageGalName>',$sigGalleryName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region1>',$location) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<imgBuilderId>',$idenityNameResourceId) | Set-Content -Path $templateFilePath

```
Feel free to view the template, all the code is viewable.


# Submit the template
Your template must be submitted to the service, this will download any dependent artifacts (scripts etc), validate, check permissions, and store them in the staging Resource Group, prefixed, *IT_*.
```powerShell
New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath -api-version "2020-02-14" -imageTemplateName $imageTemplateName -svclocation $location

# Optional - if you have any errors running the above, run:
$getStatus=$(Get-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName)
$getStatus.ProvisioningErrorCode 
$getStatus.ProvisioningErrorMessage
```
 