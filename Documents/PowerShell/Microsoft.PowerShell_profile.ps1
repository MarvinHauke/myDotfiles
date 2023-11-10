Set-PSReadlineOption -PredictionViewStyle ListView #add jk selection for suggestions
Set-PSReadLineKeyHandler -Key 'ctrl+k' -Function BackwardWord
# Set-PSReadlineKeyHandler -Key -Function MenuCompleteBackward
Set-PSReadlineOption -EditMode Vi

# This example emits a cursor change VT escape in response to a Vi mode change.
function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    }
    else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin {
    if ($args.Count -gt 0) {   
        $argList = "& '" + $args + "'"
        Start-Process "$psHome\pwsh.exe" -Verb runAs -ArgumentList $argList
    }
    else {
        Start-Process "$psHome\pwsh.exe" -Verb runAs
    }
}
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin

# Add some common Bash commadns:
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function find-file($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}


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


# Define your PowerShell function
# function My-Function {
#     param(
#         [string]$Path
#     )

#     # Your function logic here
#     Write-Host "Path: $Path"
# }

# Define a custom argument completer for the 'Path' parameter
$CompletePath = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    # Get suggestions for partly typed paths
    $suggestions = Get-ChildItem -Path $wordToComplete -Directory | Select-Object -ExpandProperty Name

    foreach ($suggestion in $suggestions) {
        if ($suggestion.StartsWith($wordToComplete, [StringComparison]::InvariantCultureIgnoreCase)) {
            $suggestion
        }
    }
}

# Register the argument completer for the 'Path' parameter of your function

Set-Alias -Name 'cdd' -Value go_to_dev
Register-ArgumentCompleter -CommandName 'cdd' -ParameterName 'Path' -ScriptBlock $CompletePath





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
