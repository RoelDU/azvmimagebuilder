# destination AIB RG
$imageResourceGroup="AIB-RG"

# location (see possible locations in main docs)
$location="westus2"

# Image template submission
$subscriptionID="74eaa7c3-20cd-428c-90c4-24cee8f0be25"
Set-AzContext -Subscription $subscriptionID
$imageTemplateName="wvd10ImageTemplate06"
$templateUrl="https://raw.githubusercontent.com/RoelDU/azvmimagebuilder/master/armTemplateWVD.json"
$templateFilePath = "armTemplateWVD.json"

New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath -api-version "2020-02-14" -imageTemplateName $imageTemplateName -svclocation $location

# Start build
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -NoWait

# Check Build Status
$getStatus=$(Get-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName)
$getStatus | Format-List -Property *

# these show the status the build
$getStatus.LastRunStatusRunState 
$getStatus.LastRunStatusMessage
$getStatus.LastRunStatusRunSubState