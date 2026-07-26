# Import-Module Microsoft.PowerShell.Management

function Get-AclMapping {
    param (
        [string]$RootPath,
        [string]$ExportPath,
        [string]$BusinessUnit
    )

    $Folders = Get-ChildItem -Directory -Path $RootPath -Recurse -Depth 5 -Force
    $AccessMap = @()

    foreach ($Folder in $Folders) {
        $Acl = Get-Acl -Path $folder.FullName

        $RelativePath = $Folder.FullName.Replace($RootPath, "")
        $Depth = ($RelativePath -split '\\').Count - 1

        $Level = if ($Depth -eq 1) { "Site Level" } else { "Library Level" }

        foreach ($Access in $Acl.Access) {
            if ($Level -eq "Library Level" -and $Access.IsInherited -eq $true ) { continue }

            $SharePointRole = switch ($Access.FileSystemRights.ToString()) {
                { $_ -match "FullControl" } { "Owner (FullControl)"; break }
                { $_ -match "Modify" -or $_ -match "Write" } { "Member (Contribute)"; break }
                { $_ -match "Read" -or $_ -match "ListDirectory" } { "Visitor (Read)"; break }
                default { "Review Manually" }
            }

            
            if ($Level -eq "Library Level" -and $Access.IsInherited -eq $false) {

                $SharePointGroup = switch ($Access.FileSystemRights.ToString()) {
                { $_ -match "Modify" -or $_ -match "Write" } { "SP-C-$BusinessUnit-LibraryTBD"; break }
                { $_ -match "Read" -or $_ -match "ListDirectory" } { "SP-R-$BusinessUnit-LibraryTBD"; break }
                default { "Review Manually" }
                }
            } else {
                $SharePointGroup = switch ($Access.FileSystemRights.ToString()) {
                { $_ -match "Modify" -or $_ -match "Write" } { "SP-C-$BusinessUnit"; break }
                { $_ -match "Read" -or $_ -match "ListDirectory" } { "SP-R-$BusinessUnit"; break }
                default { "Review Manually" }
                }
            }
        

            $MapEntry = [ordered]@{
                'DirectoryPath'         = $Folder.FullName
                'StructureLevel'        = $Level
                'Identity (User/AD)'    = $Access.IdentityReference 
                'NTFS Rights'           = $Access.FileSystemRights
                'Target SP Role'        = $SharePointRole
                'IsInherited'           = $Access.IsInherited
                'SharePoint Group'      = $SharePointGroup   
            }
            $AccessMap += New-Object -TypeName PSObject -Property $MapEntry
        }
    }
    $AccessMap | Export-Csv -Path $ExportPath
}
            
Get-AclMapping -RootPath "" -ExportPath "" -BusinessUnit ""
