# Install-PokemonColorScripts.ps1
# Installation script for Pokémon ColorScripts in Windows PowerShell

# Requires admin privileges to install to Program Files
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires Administrator privileges. Please run PowerShell as Administrator and try again."
    exit 1
}

# Configuration
$InstallDir = "$env:ProgramFiles\PokemonColorScripts"
$ScriptName = "Pokemon-ColorScripts.ps1"

# Create the installation directory if it doesn't exist
if (-not (Test-Path -Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
    Write-Host "Created installation directory: $InstallDir"
}

# Copy files to installation directory
Write-Host "Copying files to $InstallDir..."
Copy-Item -Path ".\colorscripts" -Destination $InstallDir -Recurse -Force
Copy-Item -Path ".\Pokemon-ColorScripts.ps1" -Destination $InstallDir -Force
Copy-Item -Path ".\pokemon.json" -Destination $InstallDir -Force

# Add to PATH if not already present
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if (-not $envPath.Contains($InstallDir)) {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$InstallDir", "Machine")
    Write-Host "Added installation directory to system PATH"
}

# Create shortcut in PowerShell profile directory if it doesn't exist
$ProfileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path -Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

# Create profile if it doesn't exist
if (-not (Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "Created PowerShell profile: $PROFILE"
}

# Add function to profile if not already present
$functionScript = @"
function Show-Pokemon {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName='Help')][switch]`$Help,
        [Parameter(ParameterSetName='List')][switch]`$List,
        [Parameter(ParameterSetName='Name')][string]`$Name,
        [Parameter(ParameterSetName='Name')][string]`$Form,
        [Parameter(ParameterSetName='Name')][switch]`$NoTitle,
        [Parameter(ParameterSetName='RandomOrName')][switch]`$Shiny,
        [Parameter(ParameterSetName='RandomOrName')][switch]`$Big,
        [Parameter(ParameterSetName='Random')][switch]`$Random,
        [Parameter(ParameterSetName='Random')][string]`$RandomValue,
        [Parameter(ParameterSetName='RandomNames')][string]`$RandomByNames
    )

    `$ScriptPath = "$InstallDir\\$ScriptName"

    # Build a hashtable of parameters to splat
    `$params = @{}

    if (`$Help) { `$params.Add('Help', `$true) }
    if (`$List) { `$params.Add('List', `$true) }
    if (`$Name) { `$params.Add('Name', `$Name) }
    if (`$Form) { `$params.Add('Form', `$Form) }
    if (`$NoTitle) { `$params.Add('NoTitle', `$true) }
    if (`$Shiny) { `$params.Add('Shiny', `$true) }
    if (`$Big) { `$params.Add('Big', `$true) }
    
    if (`$Random) {
        if (`$RandomValue) {
            `$params.Add('Random', `$RandomValue)
        } else {
            `$params.Add('Random', "1-8")  # Default value
        }
    }
    
    if (`$RandomByNames) { `$params.Add('RandomByNames', `$RandomByNames) }

    # Execute the script with the parameters
    & `$ScriptPath @params
}

Set-Alias -Name pokemon-colorscripts -Value Show-Pokemon
"@

$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -notlike "*function Show-Pokemon*") {
    Add-Content -Path $PROFILE -Value "`n# Pokemon ColorScripts"
    Add-Content -Path $PROFILE -Value $functionScript
    Write-Host "Added Pokemon-ColorScripts function to PowerShell profile"
} else {
    # Replace existing function
    $pattern = "function Show-Pokemon[\s\S]*?Set-Alias -Name pokemon-colorscripts -Value Show-Pokemon"
    $profileContent = $profileContent -replace $pattern, $functionScript
    Set-Content -Path $PROFILE -Value $profileContent
    Write-Host "Updated Pokemon-ColorScripts function in PowerShell profile"
}

Write-Host "Installation completed successfully!"
Write-Host "Please restart PowerShell to use the 'pokemon-colorscripts' command."