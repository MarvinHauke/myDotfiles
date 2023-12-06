Set-PSReadlineOption -PredictionViewStyle ListView #TODO: add jk selection for suggestions
Set-PSReadLineKeyHandler -Key 'ctrl+k' -Function BackwardWord
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


# Add some common Bash commadns:

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

# Add path to your Development Directory
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

function cfg {
    param(
        [Parameter(Position = 0, Mandatory = $false, ValueFromRemainingArguments = $true)]
        [String[]]$AdditionalArgs
    )

    $gitCommand = "git --git-dir=`$HOME/.cfg/ --work-tree=`$HOME"

    $commitIndex = $AdditionalArgs.IndexOf('-m')
    if ($commitIndex -ne -1) {
        $commitMessage = $AdditionalArgs[$commitIndex + 1]
        $command = "$gitCommand commit -m `"$commitMessage`""
    }
    else {
        $arguments = $AdditionalArgs -join ' '
        $command = "$gitCommand --% $arguments"
    }

    Invoke-Expression $command
}
Set-Alias -Name config -Value cfg

# Set vim to nvim if installe
if ((Get-Command nvim -ErrorAction Ignore)) {
    Set-Alias -Name vim -Value nvim
    echo "vim is now nvim"
}
else {
    echo "Nvim is not installed!"
}

# import several Modules
Import-Module posh-git
