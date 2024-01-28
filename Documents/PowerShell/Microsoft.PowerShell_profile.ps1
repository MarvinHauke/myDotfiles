Set-PSReadlineOption -PredictionViewStyle ListView #TODO: add jk selection for suggestions
Set-PSReadLineKeyHandler -Key 'ctrl+k' -Function NextHistory
Set-PSReadLineKeyHandler -Key 'ctrl+j' -Function PreviousHistory
Set-PSReadlineOption -EditMode Vi
# import several Modules
Import-Module posh-git
Import-Module PSScriptAnalyzer


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

# This script parses the .profileSettings.json at your Home Directory
# Check if the dyn_path file exists in the user's home directory
function SetProfilesettingsJSON {
  $dev_path = Read-Host "Please enter your Development Folder Path"
  $dow_path = Read-Host "Please enter your Downloads Folder Path"
  $nvim_path = Read-Host "Please enter your Nvim_config Folder Path"
  $chatgpt_key = Read-Host "Please enter your chatgpt_key"

  # Generate a json File structure
  $profileSettingsData = @{
    userpaths = @{
      dev_path = $dev_path
      dow_path = $dow_path
      nvim_path = $nvim_path
    }
    userkeys = @{
      chatgpt_key = $chatgpt_key
    }
  }
  $jsonOutput = $profileSettingsData | ConvertTo-Json

  # Write the updated JSON content back to the file
  $jsonOutput | Set-Content -Path $profileSettingsPath
}

$profileSettingsPath = Join-Path $HOME ".profileSettings.json"
if (-not (Test-Path -Path $profileSettingsPath)) {
  Write-Host "There is no file for your profilesettings yet"
    
  # Prompt the user to create a pathfile containing system settings
  $answer = Read-Host `
    "Do you want to create a .profilesettings.json?
    (Enter 'yes' to continue)"
  # Convert the input to lowercase
  $inputToLower = $answer.ToLower()
  if ($inputToLower -eq "yes" -or $inputToLower -eq "y") {
    SetProfilesettingsJSON
  }
}

# Read existing Data from .profileSettings.json back in
$profileSettingsData = Get-Content $profileSettingsPath | ConvertFrom-JSON 

# Check if 'userpaths' is present in the JSON data
if ($profileSettingsData.PSObject.Properties['userpaths']) {
  # Initialize an array to store values
  $userPathsArray = @()

  # Iterate through each property in 'userpaths'
  foreach ($property in $profileSettingsData.userpaths.PSObject.Properties) {
    # Add the value of each property to the array
    $userPathsArray += $property.Value
  }

  # Output the array to the console
  # $userPathsString = $userPathsArray -join ", `n" # This prints every value in a new line
  # Write-Host "There are following userPaths:`n$userPathsString" 
} else {
  Write-Host "'userpaths' not found in the JSON data."
  SetProfilesettingsJSON
}

foreach ($path in $userPathsArray) {
  if (Test-Path -Path $path -PathType Container) { 
    # Add a function for valid paths
  } else {
    Write-Host "Invalid Path: $path does not exist"
    SetProfilesettingsJSON
  }
}


# Add OPENAI_API_KEY as $Env
$key_path = "$HOME/.env"
if (Test-Path -Path $key_path) {
  $env:OPENAI_API_KEY = (Get-Content $key_path)
} else {
  Write-Host "There is no .env file yet"
}

# Add some common Bash commadns:

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
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
  } else {
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
  } else {
    $arguments = $AdditionalArgs -join ' '
    $command = "$gitCommand --% $arguments"
  }
  Invoke-Expression $command
}
Set-Alias -Name config -Value cfg

function LazyGitFunc{
  $lazyGitCommand = "lazygit --git-dir=$HOME/.cfg/ --work-tree=$HOME"
  if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Invoke-Expression $lazyGitCommand
  } else{
    Write-Host "LazyGit not installed"
  }
}
Set-Alias -Name lzconf -Value lazyGitFunc

# Set vim to nvim if installe
if ((Get-Command nvim -ErrorAction Ignore)) {
  Set-Alias -Name vim -Value nvim
  Write-Host "vim is now nvim"
} else {
  Write-Host "Nvim is not installed!"
}

function NvimConfigFunc{
  $nvim_config_path = "$HOME/AppData/Local/nvim/"
  if (Test-Path -Path $nvim_config_path -PathType Container){
    $nvconfCommand =  "nvim " + $nvim_config_path
    Invoke-Expression $nvconfCommand
  }
}
Set-Alias -Name nvc -Value NvimConfigFunc

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
