Using Namespace Microsoft.Graph.PowerShell.Models
Select-MgProfile -Name "v1.0"
Connect-MgGraph -TenantId "TENANT_ID" -AppId "APP_ID" -CertificateThumbprint "CERT_THUMB"

Function New-GraphUnifiedGroup {
    Param (
        # Define parameters below, each separated by a comma
        [Parameter(Mandatory = $True)]
        [string]$displayName,
        [string]$mailnickname,
        [string]$description,
        [string]$visibility,
        [string]$classification,
        [string]$owner,
        [string]$preferredDataLocation
    ) 
    Write-Verbose 'Getting Unified Group from Graph'
    
    $Body = [PSCustomObject]@{
        "template@odata.bind" = "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
        "displayName"           = $displayName
        "mailenabled"           = $true
        "securityenabled"       = $false
        "description"           = $description
    }
    $ownerteamuser = Get-MgUser -UserId $owner

    
    $ownerteam = [PSCustomObject]@{
    "@odata.type"     = "#microsoft.graph.aadUserConversationMember";
    "user@odata.bind" = "https://graph.microsoft.com/v1.0/users('$($ownerteamuser.Id)')";
}
$Roles = [PSCustomObject]@("owner")
Add-Member -InputObject $ownerteam -MemberType NoteProperty -Name 'roles' -Value $roles

    $members = [PSCustomObject]@($ownerteam)
    Add-Member -InputObject $Body -MemberType NoteProperty -Name 'members' -Value $members
    #$members| convertto-json
    #$ownerteam | convertto-json 
    #$body | convertto-json -Depth 3
    
    #-------------------------------------------
    # add additional properties as neccessary
    #-------------------------------------------
    if ($visibility) {
        Add-Member -InputObject $Body -MemberType NoteProperty -Name 'visibility' -Value $visibility
    }
    $BodyJson = $Body | ConvertTo-Json -Depth 3
    #$BodyJson
    if ($classification) {
        Add-Member -InputObject $Body -MemberType NoteProperty -Name 'classification' -Value $classification
    }
    if ($preferredDataLocation) {
        Add-Member -InputObject $Body -MemberType NoteProperty -Name 'preferredDataLocation' -Value $preferredDataLocation
    }
    $BodyJson = $Body | ConvertTo-Json -Depth 3
    #Write-Output "body: $BodyJson"
 
    <#$BodyJson= @"
{
    "template@odata.bind":"https://graph.microsoft.com/v1.0/teamsTemplates('standard')",
    "displayName":"My Sample Team",
    "description":"My Sample Team’s Description",
    "members":[
       {
          "@odata.type":"#microsoft.graph.aadUserConversationMember",
          "roles":[
             "owner"
          ],
          "user@odata.bind":"https://graph.microsoft.com/beta/users('c2532f3d-cf8b-4b4a-aa5f-a5f2e9e80777')"
       }
    ]
 }
"@#>

    try {
        #$result = New-MgTeam -BodyParameter $BodyJson

        #$result =
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/teams" -Body $BodyJson -ContentType 'application/json' -ErrorAction Stop -OutputType Json
        #$result = Invoke-WebRequest -Method POST -Uri "https://graph.microsoft.com/beta/teams" -Body $BodyJson -ContentType 'application/json' -ErrorAction Stop
        #Write-Output $result
        # and save the generated Group ID
        $GroupID = $result.id
        Write-Output "Group created: ID:[$GroupID]"
    }
    catch [System.Net.WebException] {
        Write-Output  $result
        $result = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
     
        throw "CreateGroup: ErrorCode: [$($responseBody.error.message)] | [$($responseBody.error.details.ToString())]"
    }
    catch {
        Write-Output "CreateGroup: Another Exception caught: [$($_.Exception)]"
        throw "CreateGroup: Another Exception caught: [$($_.Exception)]"
    }
    return $result
}

$NewTeam = @{
displayName             = 'This is a Test gb4374 23_12_21'
description             = 'This is a Test gb4374 23_12_21 desc'
visibility              = 'private'
classification          = 'internal'
preferredDataLocation   = 'EUR'
owner                   = 'loz@lrarbin.onmicrosoft.com'
}


New-GraphUnifiedGroup @NewTeam

