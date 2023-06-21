function go_to_dev {
	[CmdletBinding()]
	param()
	cd $HOME/Development/
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

Set-Alias cdd go_to_dev