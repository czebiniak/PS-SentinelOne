function Invoke-S1AgentAction {
    <#
    .SYNOPSIS
        Initiates a scan on a SentinelOne agent
    
    .PARAMETER AgentID
        Agent ID for the agent you want to scan
    
    .PARAMETER Scan
        Initiates a scan on a SentinelOne agent
    
    .PARAMETER AbortScan
        Aborts a running scan on a SentinelOne agent
    
    .PARAMETER Protect
        Sends a protect command to a SentinelOne agent
    
    .PARAMETER Unprotect
        Sends an unprotect command to a SentinelOne agent
    
    .PARAMETER Reload
        Initiates service reload on a SentinelOne agent
    
    .PARAMETER SendMessage
        Sends a message to SentinelOne agents
    
    .PARAMETER FetchLogs
        Sends a fetch log command for a SentinelOne agent
    
    .PARAMETER DisconnectFromNetwork
        Sends a command to disconnect a SentinelOne agent from the network
    
    .PARAMETER ReconnectToNetwork
        Sends a command to reconnect a SentinelOne agent to the network
    
    .PARAMETER ResetLocalConfig
        Sends a command to clear the SentinelCtl changes for targeted agents
    
    .PARAMETER ApproveUninstall
        Approve an uninstall request

    .PARAMETER RejectUninstall
        Reject an uninstall request

    .PARAMETER MoveToSite
        Move an agent to a different site. Use with -TargetSiteID

    .PARAMETER TargetSiteID
        Site ID for the Site where the agent should be moved

    .PARAMETER Decommission
        Decommission an agent
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [String[]]
        $AgentID,

        [Parameter(Mandatory=$True,ParameterSetName="Scan")]
        [Switch]
        $Scan,

        [Parameter(Mandatory=$True,ParameterSetName="AbortScan")]
        [Switch]
        $AbortScan,

        [Parameter(Mandatory=$True,ParameterSetName="Protect")]
        [Switch]
        $Protect,

        [Parameter(Mandatory=$True,ParameterSetName="Unprotect")]
        [Switch]
        $Unprotect,

        [Parameter(Mandatory=$True,ParameterSetName="Reload")]
        [ValidateSet("log", "static", "agent", "monitor")]
        [String]
        $Reload,

        [Parameter(Mandatory=$True,ParameterSetName="SendMessage")]
        [String]
        $SendMessage,

        [Parameter(Mandatory=$True,ParameterSetName="FetchLogs")]
        [Switch]
        $FetchLogs,

        [Parameter(Mandatory=$True,ParameterSetName="DisconnectFromNetwork")]
        [Switch]
        $DisconnectFromNetwork,

        [Parameter(Mandatory=$True,ParameterSetName="ReconnectToNetwork")]
        [Switch]
        $ReconnectToNetwork,

        [Parameter(Mandatory=$True,ParameterSetName="ResetLocalConfig")]
        [Switch]
        $ResetLocalConfig,

        [Parameter(Mandatory=$True,ParameterSetName="ApproveUninstall")]
        [Switch]
        $ApproveUninstall,

        [Parameter(Mandatory=$True,ParameterSetName="RejectUninstall")]
        [Switch]
        $RejectUninstall,

        [Parameter(Mandatory=$True,ParameterSetName="MoveToSite")]
        [Switch]
        $MoveToSite,

        [Parameter(Mandatory=$True,ParameterSetName="MoveToSite")]
        [String]
        $TargetSiteID,

        [Parameter(Mandatory=$True,ParameterSetName="Decommission")]
        [Switch]
        $Decommission
    )
    # Log the function and parameters being executed
    $InitializationLog = $MyInvocation.MyCommand.Name
    $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
    Write-Log -Message $InitializationLog -Level Informational

    $Method = "POST"
    $Body = @{ data = @{}; filter = @{}}

    switch ($PSCmdlet.ParameterSetName) {
        "Scan" {
            $URI = "/web/api/v2.1/agents/actions/initiate-scan"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Scan initiated for"
        }
        "AbortScan" {
            $URI = "/web/api/v2.1/agents/actions/abort-scan"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Scan aborted for"
        }
        "Protect" {
            $URI = "/web/api/v2.1/private/agents/support-actions/protect"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Protect command initiated for"
        }
        "Unprotect" {
            $URI = "/web/api/v2.1/private/agents/support-actions/unprotect"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Unprotect command initiated for"
        }
        "Reload" {
            $URI = "/web/api/v2.1/private/agents/support-actions/reload"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $Body.data.Add("module", $Reload.ToLower())
            $OutputMessage = "Service reload initiate for"
        }
        "SendMessage" {
            $URI = "/web/api/v2.1/agents/actions/broadcast"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $Body.data.Add("message", $SendMessage)
            $OutputMessage = "Message sent to"
        }
        "FetchLogs" {
            $URI = "/web/api/v2.1/agents/actions/fetch-logs"
            $Body.data.Add("platformLogs", $true)
            $Body.data.Add("agentLogs", $true)
            $Body.data.Add("customerFacingLogs", $true)
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Fetch logs initiated for"
        }
        "DisconnectFromNetwork" {
            $URI = "/web/api/v2.1/agents/actions/disconnect"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Network Disconnect initiated for"
        }
        "ReconnectToNetwork" {
            $URI = "/web/api/v2.1/agents/actions/connect"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Network Reconnect initiated for"
        }
        "ResetLocalConfig" {
            $URI = "/web/api/v2.1/agents/actions/reset-local-config"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Reset local config command sent to"
        }
        "ApproveUninstall" {
            $URI = "/web/api/v2.1/agents/actions/approve-uninstall"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Uninstall approved for"
        }
        "RejectUninstall" {
            $URI = "/web/api/v2.1/agents/actions/reject-uninstall"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Uninstall rejected for"
        }
        "MoveToSite" {
            $URI = "/web/api/v2.1/agents/actions/move-to-site"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $Body.Add("data", @{"targetSiteId" = $TargetSiteID})
            $OutputMessage = "Move to site $TargetSiteID initiated for"
        }
        "Decommission" {
            $URI = "/web/api/v2.1/agents/actions/decommission"
            $Body.filter.Add("ids", ($AgentID -join ","))
            $OutputMessage = "Decommission initiated for"
        }
    }

    $Response = Invoke-S1Query -URI $URI -Method $Method -Body ($Body | ConvertTo-Json) -ContentType "application/json"

    if ($Response.data.affected) {
        Write-Output "$OutputMessage $($Response.data.affected) agents"
        return
    }
    Write-Output $Response.data
}