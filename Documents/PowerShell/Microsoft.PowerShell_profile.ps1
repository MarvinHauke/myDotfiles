Import-Module PSReadline
Set-PSReadlineOption -PredictionViewStyle ListView #add jk selection for suggestions
Set-PSReadlineOption -EditMode Vi

# This example emits a cursor change VT escape in response to a Vi mode change.

function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange


function go_to_dev {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
        [String]$Directory
    )

    $path = Join-Path $HOME\Development\ $Directory

    if (Test-Path -Path $path -PathType Container) {
        Set-Location -Path $path
    }
    else {
        Write-Host "Directory '$Directory' not found in $HOME\Development/."
    }
}
<#
.SYNOPSIS
	Binds the config repo to the home directory
.DESCRIPTION
	Funktion for creating a git alias for the config repo
.NOTES
	Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
	Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
	Test-MyTestFunction -Verbose
	Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function cfg {
    param(
        [Parameter(Position = 0, Mandatory = $false, ValueFromRemainingArguments = $true)]
        [String[]]$AdditionalArgs
    )

    $gitCommand = "git --git-dir=`$HOME/.cfg/ --work-tree=`$HOME"

    if ($AdditionalArgs[1] -eq '-m') {
        $commitMessage = $AdditionalArgs[2]
        $command = "$gitCommand commit -m `"$commitMessage`""
    }
    else {
        $arguments = $AdditionalArgs -join ' '
        $command = "$gitCommand --% $arguments"
    }

    Invoke-Expression $command
}

Set-Alias -Name config -Value cfg

Set-Alias -Name 'cdd' -Value go_to_dev
