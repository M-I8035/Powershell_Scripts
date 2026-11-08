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

$secGroupParams = @{
   DisplayName = $secGroupName
   Description = "This is a demo security group created via PowerShell"
   MailEnabled = $false
   SecurityEnabled = $true
   MailNickname = $secGroupName -replace " ", "."
}

$AccessGroup = New-MgGroup @secGroupParams
$M365Group = New-MgGroup -BodyParameter @NewGroupParams

$env:GROUP_ID = $M365Group.Id
$env:ACCESS_GROUP_ID = $AccessGroup.Id


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Connect-ExcahngeOnline

Set-UnifiedGroup -Identity $env:GROUP_ID -HiddenFromAddressListsEnabled $true


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





