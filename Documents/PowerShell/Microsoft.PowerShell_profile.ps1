
# Enable ListView for PSReadline and set vi mode
Set-PSReadlineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key 'ctrl+k' -Function NextHistory
Set-PSReadLineKeyHandler -Key 'ctrl+j' -Function PreviousHistory
Set-PSReadlineOption -EditMode Vi

# Import necessary modules
Import-Module posh-git
Import-Module PSScriptAnalyzer
Import-Module PSReadLine

# Function to handle Vi mode cursor change
function OnViModeChange {
  if ($args[0] -eq 'Command') {
    Write-Host -NoNewLine "`e[1 q"  # Blinking block cursor
  } else {
    Write-Host -NoNewLine "`e[5 q"  # Blinking line cursor
  }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange

# Set autopair quotes
Set-PSReadLineKeyHandler -Chord '"',"'" `
  -BriefDescription SmartInsertQuote `
  -LongDescription "Insert paired quotes if not already on a quote" `
  -ScriptBlock {
  param($key, $arg)
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($line.Length -gt $cursor -and $line[$cursor] -eq $key.KeyChar) {
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
  } else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)" * 2)
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
  }
}

# Function to run a command as admin
function admin {
  if ($args.Count -gt 0) {
    $argList = "& '" + $args + "'"
    Start-Process "$psHome\pwsh.exe" -Verb runAs -ArgumentList $argList
  } else {
    Start-Process "$psHome\pwsh.exe" -Verb runAs
  }
}
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin

# Function to find command path
function which($name) {
  Get-Command $name | Select-Object -ExpandProperty Definition
}

# Function to find a file recursively
function find-file($name) {
  Get-ChildItem -Recurse -Filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    $place_path = $_.DirectoryName
    Write-Output "${place_path}\${_}"
  }
}

# Function to grep content in files
function grep($regex, $dir) {
  if ($dir) {
    Get-ChildItem $dir | Select-String $regex
  } else {
    $input | Select-String $regex
  }
}

# Function to change to development directory
function go_to_dev {
  param (
    [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
    [String]$Directory
  )
  $path = Join-Path $HOME\Development\ $Directory
  if (Test-Path -Path $path -PathType Container) {
    Set-Location -Path $path
  } else {
    Write-Host "Directory '$Directory' not found in $HOME\Development/."
  }
}
Set-Alias -Name 'cdd' -Value go_to_dev

# Argument completer for the 'Path' parameter
$CompletePath = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
  Get-ChildItem -Path $wordToComplete -Directory | Select-Object -ExpandProperty Name | ForEach-Object {
    if ($_.StartsWith($wordToComplete, [StringComparison]::InvariantCultureIgnoreCase)) {
      $_
    }
  }
}
Register-ArgumentCompleter -CommandName 'cdd' -ParameterName 'Path' -ScriptBlock $CompletePath

# Git alias and function
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
  } else {
    $arguments = $AdditionalArgs -join ' '
    $command = "$gitCommand --% $arguments"
  }
  Invoke-Expression $command
}
Set-Alias -Name config -Value cfg

function showConfigFiles {
  git --git-dir=$HOME/.cfg/ ls-tree -r master --name-only
}

function LazyGitFunc {
  $lazyGitCommand = "lazygit --git-dir=$HOME/.cfg/ --work-tree=$HOME"
  if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Invoke-Expression $lazyGitCommand
  } else {
    Write-Host "LazyGit not installed"
  }
}
Set-Alias -Name lzconf -Value LazyGitFunc

# Nvim configuration functions
if (Get-Command nvim -ErrorAction Ignore) {
  Set-Alias -Name vim -Value nvim
  Write-Host "vim is now nvim"
} else {
  Write-Host "Nvim is not installed!" -ForegroundColor Red
}

function NvimConfigFunc {
  $nvim_config_path = "$HOME\AppData\Local\nvim\"
  if (Test-Path -Path $nvim_config_path -PathType Container) {
    Invoke-Expression "vim $nvim_config_path"
  } else {
    Write-Host "Nvim configuration directory not found!" -ForegroundColor Red
  }
}
Set-Alias -Name nvc -Value NvimConfigFunc

function NvimConfigFolder {
  $nvim_config_path = "$HOME\AppData\Local\nvim\"
  if (Test-Path -Path $nvim_config_path -PathType Container) {
    Set-Location $nvim_config_path
  } else {
    Write-Host "Nvim configuration directory not found!" -ForegroundColor Red
  }
}
Set-Alias -Name cdn -Value NvimConfigFolder

# Notes directory function
function NotesFolder {
  $notesPath = "$HOME\Documents\Notizen"
  if (Test-Path -Path $notesPath -PathType Container) {
    Set-Location $notesPath
  } else {
    Write-Host "Notes directory not found!" -ForegroundColor Red
  }
}
Set-Alias -Name notes -Value NotesFolder
function NotesFolderPikes {
  $pikesNotesPath = "C:\Users\MarvinHauke\OneDrive - Pikes GmbH\Dokumente\Notizen"
  if (Test-Path -Path $pikesNotesPath -PathType Container) {
    Set-Location $pikesNotesPath
  } else{
    Write-Host "Pikes Notes directory not found!" -ForegroundColor Red
  }
}
Set-Alias -Name pNotes -Value NotesFolderPikes

# Edit profile configuration function
function ProfileConfigFunc {
  vim "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
}
Set-Alias -Name nvp -Value ProfileConfigFunc

# Import Chocolatey profile for tab completion
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
  Import-Module $ChocolateyProfile
}
