# TODO:
# Create Site
# -M365 group site
# -Supress Outlook Client and GAL
# -Add Internal Label
# -Default Owner: Admin Account 
# -Create Libraries 

# Create Entra Groups
# -Import CSV Spread Sheet with group names and descriptions
# -Site Group SGA-SP-R-SiteName
# -Library Groups
#   -SGA-SP-R-SiteName-LibraryName
#   -SGA-SP-C-SiteName-LibraryName

# Establish Secure Site 
# -Set M365 Group Site to restricted access
# -Add site Group SGA-SP-R-SiteName as permitted group

# Create Libraries
# -create a library 
# -Break Inheritance from Site
# -Add library groups SGA-SP-R-SiteName-LibraryName and SGA-SP-C-SiteName-LibraryName as permitted groups for their respective libraries
# -Remove Site Gorups.


# CREATE M365 GROUP SITE

# TODO: Iterate through Library Groups
# TODO: Create CSV Schema for script series (SiteName, AccessGroup, LibraryName, ContributeGroup, ReadGroup, Discription, Role)
# TODO: Create Json Files For Passing Parameters to Scripts

Connect-MgGraph

$businessUnit = "DWE"
$M365displayName = "$businessUnit Document Center"
$secGroupName = "SGA-SP-R-SiteName"
# Connect-PnPOnline -Url "https://contoso.sharepoint.com/sites/SiteName" -Interactive

$NewGroupParams = @{
    DisplayName = $M365displayName
    Description = "Restricted Site for SiteName"
    MailNickname = $M365displayName -replace " ", "."
    Visibility = "Private"
    GroupTypes = @("Unified")
    AssignedLabels = @(@{LabelId = "Internal"; IsDefault = $true})  
    ResourceBehaviorOptions = @("HideGroupInOutlook", "WelcomeEmailDisabled")
    Owners = @("admin@contoso.com")
}

$AccessGroupParams = @{
   DisplayName = $secGroupName
   Description = "This is a demo security group created via PowerShell"
   MailEnabled = $false
   SecurityEnabled = $true
   MailNickname = $secGroupName -replace " ", "."
}

$LibraryGroupParams = @{
   DisplayName = $secGroupName
   Description = "This is a demo security group created via PowerShell"
   MailEnabled = $false
   SecurityEnabled = $true
   MailNickname = $secGroupName -replace " ", "."
}

$AccessGroup = New-MgGroup @AccessGroupParams
$M365Group = New-MgGroup -BodyParameter @NewGroupParams
$LibararyGroups = New-MgGroup @LibraryGroupParams





# Passing Environement Variables NOT NEEDED Json parameters to be used instead
# $env:GROUP_ID = $M365Group.Id
# $env:ACCESS_GROUP_ID = $AccessGroup.Id


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Require Exchange Online PowerShell Module

Connect-ExcahngeOnline

Set-UnifiedGroup -Identity $env:GROUP_ID -HiddenFromAddressListsEnabled $true


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Requrie PNP PowerShell Module

$clientId = "<PNPClientID>"
$tenantId = "<TenantId>"

Connect-PnPOnline -ClientId $clientId -Tenant $tenantId -Url "https://yourtenant.sharepoint.com" -Interactive


$list = New-PnPList -Title "LibraryName" -Template DocumentLibrary

Set-PnPList -Identity "LibraryName" -BreakRoleInheritance

Set-PnPListPermission `
    -Identity "LibraryName" `
    -Group "M365-Library-Contributors" `
    -AddRole "Contribute" 

