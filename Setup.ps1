# ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ████████╗███████╗
# ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
# ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║   ██║   ███████╗
# ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║   ██║   ╚════██║
# ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝   ██║   ███████║
#  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
# Setup.ps1
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#Requires -RunAsAdministrator
#Requires -Version 7

# Linked Files (Destination => Source)
$symlinks = @{
    $PROFILE.CurrentUserAllHosts                                                                    = ".\Profile.ps1"
    "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"                                   = ".\Microsoft.PowerShell_profile.ps1"
    "$HOME\AppData\Local\fastfetch"                                                                 = ".\fastfetch"
    "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\windowsterminal\settings.json"
    "$HOME\.gitconfig"                                                                              = ".\.gitconfig"
    "$HOME\AppData\Roaming\lazygit"                                                                 = ".\lazygit"
    "$HOME\AppData\Roaming\AltSnap\AltSnap.ini"                                                     = ".\altsnap\AltSnap.ini"
    "$HOME\AppData\Roaming\starship\starship.toml"                                                  = ".\starship\starship.toml"
    "$ENV:PROGRAMFILES\WezTerm\wezterm_modules"                                                     = ".\wezterm\"
}

# Winget & choco dependencies
$wingetDeps = @(
    "chocolatey.chocolatey"
    "eza-community.eza"
    "ezwinports.make"
    "fastfetch-cli.fastfetch"
    "git.git"
    "github.cli"
    "kitware.cmake"
    "mbuilov.sed"
    "microsoft.powershell"
    "openjs.nodejs"
    "starship.starship"
    "task.task"
    "JanDeDobbeleer.OhMyPosh"
)
$chocoDeps = @(
    "altsnap"
    "bat"
    "fd"
    "fzf"
    "gawk"
    "lazygit"
    "mingw"
    "nerd-fonts-jetbrainsmono"
    "ripgrep"
    "sqlite"
    "wezterm"
    "zig"
    "zoxide"
    "nvm"
    "yarn"
    "vscode"
)

# PS Modules
$psModules = @(
    "CompletionPredictor"
    "PSScriptAnalyzer"
    "PSReadLine"
    "Terminal-Icons"
    "ps-arch-wsl"
    "ps-color-scripts"
)

# Set working directory
Set-Location $PSScriptRoot
[Environment]::CurrentDirectory = $PSScriptRoot

Write-Host "Installing missing dependencies..." -ForegroundColor Cyan
$installedWingetDeps = winget list | Out-String
foreach ($wingetDep in $wingetDeps) {
    if ($installedWingetDeps -notmatch $wingetDep) {
        Write-Host "Installing $wingetDep via winget..." -ForegroundColor Yellow
        winget install --id $wingetDep
    } else {
        Write-Host "$wingetDep is already installed." -ForegroundColor Green
    }
}

# Path Refresh
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "Installing Chocolatey packages..." -ForegroundColor Cyan
$installedChocoDeps = (choco list --limit-output --id-only).Split("`n")
foreach ($chocoDep in $chocoDeps) {
    if ($installedChocoDeps -notcontains $chocoDep) {
        Write-Host "Installing $chocoDep via Chocolatey..." -ForegroundColor Yellow
        choco install $chocoDep -y
    } else {
        Write-Host "$chocoDep is already installed." -ForegroundColor Green
    }
}

# Install PS Modules
Write-Host "Installing PowerShell modules..." -ForegroundColor Cyan
foreach ($psModule in $psModules) {
    if (!(Get-Module -ListAvailable -Name $psModule)) {
        Write-Host "Installing PowerShell module: $psModule" -ForegroundColor Yellow
        Install-Module -Name $psModule -Force -AcceptLicense -Scope CurrentUser
    } else {
        Write-Host "PowerShell module $psModule is already installed." -ForegroundColor Green
    }
}

# Install Pokemon-ColorScripts
Write-Host "Installing Pokemon-ColorScripts..." -ForegroundColor Cyan
$InstallDir = "$env:ProgramFiles\PokemonColorScripts"
$ScriptName = "Pokemon-ColorScripts.ps1"

# Create the installation directory if it doesn't exist
if (-not (Test-Path -Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
    Write-Host "Created installation directory: $InstallDir" -ForegroundColor Green
}

# Copy files to installation directory
Write-Host "Copying Pokemon-ColorScripts files to $InstallDir..." -ForegroundColor Yellow
Copy-Item -Path ".\pokemon-colorscripts\colorscripts" -Destination $InstallDir -Recurse -Force
Copy-Item -Path ".\pokemon-colorscripts\Pokemon-ColorScripts.ps1" -Destination $InstallDir -Force
Copy-Item -Path ".\pokemon-colorscripts\pokemon.json" -Destination $InstallDir -Force

# Add to PATH if not already present
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if (-not $envPath.Contains($InstallDir)) {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$InstallDir", "Machine")
    Write-Host "Added Pokemon-ColorScripts directory to system PATH" -ForegroundColor Green
}

# Persist Environment Variables
Write-Host "Setting environment variables..." -ForegroundColor Cyan
[System.Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', "$PSScriptRoot\wezterm\wezterm.lua", [System.EnvironmentVariableTarget]::User)

# Save current git configuration
$currentGitEmail = (git config --global user.email)
$currentGitName = (git config --global user.name)

# Create Symbolic Links
Write-Host "Creating Symbolic Links..." -ForegroundColor Cyan
foreach ($symlink in $symlinks.GetEnumerator()) {
    # Create parent directory if it doesn't exist
    $parentDir = Split-Path -Parent $symlink.Key
    if (-not (Test-Path -Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        Write-Host "Created directory: $parentDir" -ForegroundColor Green
    }
    
    # Remove existing item if it exists
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    
    # Create symlink
    $targetPath = Resolve-Path $symlink.Value -ErrorAction SilentlyContinue
    if ($targetPath) {
        New-Item -ItemType SymbolicLink -Path $symlink.Key -Target $targetPath -Force | Out-Null
        Write-Host "Created symlink: $($symlink.Key) -> $targetPath" -ForegroundColor Green
    } else {
        Write-Host "Warning: Could not find target path for $($symlink.Value)" -ForegroundColor Yellow
    }
}

# Restore git configuration
git config --global --unset user.email | Out-Null
git config --global --unset user.name | Out-Null
git config --global user.email $currentGitEmail | Out-Null
git config --global user.name $currentGitName | Out-Null

# Install bat themes
Write-Host "Configuring bat..." -ForegroundColor Cyan
bat cache --clear
bat cache --build

# Install oh-my-posh if not already installed
Write-Host "Verifying Oh My Posh installation..." -ForegroundColor Cyan
$ohMyPoshInstalled = $null
try {
    $ohMyPoshInstalled = Get-Command oh-my-posh -ErrorAction SilentlyContinue
} catch {
    # Command not found
}

if (-not $ohMyPoshInstalled) {
    Write-Host "Oh My Posh not found, installing..." -ForegroundColor Yellow
    winget install JanDeDobbeleer.OhMyPosh -s winget
    # Refresh the PATH so we can use oh-my-posh immediately
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
else {
    Write-Host "Oh My Posh is already installed." -ForegroundColor Green
}

# Setup oh-my-posh theme
Write-Host "Configuring Oh My Posh..." -ForegroundColor Cyan
$ohMyPoshThemesDir = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
if (-not (Test-Path -Path $ohMyPoshThemesDir)) {
    New-Item -ItemType Directory -Path $ohMyPoshThemesDir -Force | Out-Null
    Write-Host "Created Oh My Posh themes directory: $ohMyPoshThemesDir" -ForegroundColor Green
}
# Copy easy-term.omp.json theme if exists
if (Test-Path ".\starship\easy-term.omp.json") {
    Copy-Item -Path ".\starship\easy-term.omp.json" -Destination "$ohMyPoshThemesDir\easy-term.omp.json" -Force
    Write-Host "Installed Oh My Posh theme: easy-term.omp.json" -ForegroundColor Green
}

# Configure PowerShell Profile
Write-Host "Configuring PowerShell profile..." -ForegroundColor Cyan
$ProfileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path -Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    Write-Host "Created PowerShell profile directory: $ProfileDir" -ForegroundColor Green
}

# Add Pokemon-ColorScripts function to profile if not already present
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

# Check if Profile.ps1 exists, and if not, create it from our template
if (-not (Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
    Write-Host "Copying Profile.ps1 to $($PROFILE.CurrentUserAllHosts)" -ForegroundColor Yellow
    Copy-Item -Path ".\Profile.ps1" -Destination $PROFILE.CurrentUserAllHosts -Force
} else {
    # For existing profile, ensure Pokemon-ColorScripts function is added
    $profileContent = Get-Content -Path $PROFILE.CurrentUserAllHosts -Raw -ErrorAction SilentlyContinue
    if ($profileContent -notlike "*function Show-Pokemon*") {
        Write-Host "Adding Pokemon-ColorScripts function to PowerShell profile" -ForegroundColor Yellow
        Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "`n# Pokemon ColorScripts"
        Add-Content -Path $PROFILE.CurrentUserAllHosts -Value $functionScript
    } else {
        # Replace existing function
        Write-Host "Updating Pokemon-ColorScripts function in PowerShell profile" -ForegroundColor Yellow
        $pattern = "function Show-Pokemon[\s\S]*?Set-Alias -Name pokemon-colorscripts -Value Show-Pokemon"
        $profileContent = $profileContent -replace $pattern, $functionScript
        Set-Content -Path $PROFILE.CurrentUserAllHosts -Value $profileContent
    }
}

# Ensure oh-my-posh configuration is in profile
$profileContent = Get-Content -Path $PROFILE.CurrentUserAllHosts -Raw -ErrorAction SilentlyContinue
if ($profileContent -notlike "*oh-my-posh --init*") {
    Write-Host "Adding Oh My Posh initialization to PowerShell profile" -ForegroundColor Yellow
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "`n# Initialize Oh My Posh"
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "oh-my-posh --init --shell pwsh --config '$env:LOCALAPPDATA\Programs\oh-my-posh\themes\easy-term.omp.json' | Invoke-Expression"
}

# Ensure Terminal-Icons and PSReadLine are loaded in Profile.ps1
$profileContent = Get-Content -Path $PROFILE.CurrentUserAllHosts -Raw -ErrorAction SilentlyContinue
if ($profileContent -notlike "*Import-Module -Name Terminal-Icons*") {
    Write-Host "Adding Terminal-Icons module import to PowerShell profile" -ForegroundColor Yellow
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "`n# Load Terminal-Icons module"
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Import-Module -Name Terminal-Icons"
}

if ($profileContent -notlike "*Import-Module PSReadLine*") {
    Write-Host "Adding PSReadLine module import to PowerShell profile" -ForegroundColor Yellow
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "`n# Load PSReadLine module"
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "if (`$host.Name -eq 'ConsoleHost') { Import-Module PSReadLine }"
    
    # Add basic PSReadLine configuration
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "`n# Configure PSReadLine"
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Set-PSReadLineOption -PredictionSource History"
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Set-PSReadLineOption -PredictionViewStyle ListView" 
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Set-PSReadLineOption -EditMode Windows"
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward"
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward"
}

# Also check Microsoft.PowerShell_profile.ps1 for oh-my-posh configuration
$microsoftProfilePath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path -Path $microsoftProfilePath) {
    $microsoftProfileContent = Get-Content -Path $microsoftProfilePath -Raw -ErrorAction SilentlyContinue
    # Check if the profile already has oh-my-posh init, but not the import module line
    if ($microsoftProfileContent -like "*Import-Module oh-my-posh*" -and $microsoftProfileContent -like "*oh-my-posh --init*") {
        Write-Host "Fixing Oh My Posh configuration in Microsoft PowerShell profile" -ForegroundColor Yellow
        $microsoftProfileContent = $microsoftProfileContent -replace "Import-Module oh-my-posh", "# Import-Module oh-my-posh is no longer needed as we use the init method below"
        Set-Content -Path $microsoftProfilePath -Value $microsoftProfileContent
    }
    # Add oh-my-posh initialization if it's not there
    elseif ($microsoftProfileContent -notlike "*oh-my-posh --init*") {
        Write-Host "Adding Oh My Posh initialization to Microsoft PowerShell profile" -ForegroundColor Yellow
        Add-Content -Path $microsoftProfilePath -Value "`n# Initialize Oh My Posh"
        Add-Content -Path $microsoftProfilePath -Value "oh-my-posh --init --shell pwsh --config '$env:LOCALAPPDATA\Programs\oh-my-posh\themes\easy-term.omp.json' | Invoke-Expression"
    }
}

# Ensure Terminal-Icons and PSReadLine are loaded in Microsoft PowerShell profile
$microsoftProfilePath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path -Path $microsoftProfilePath) {
    $microsoftProfileContent = Get-Content -Path $microsoftProfilePath -Raw -ErrorAction SilentlyContinue
    
    # Add Terminal-Icons module import if it's not there
    if ($microsoftProfileContent -notlike "*Import-Module -Name Terminal-Icons*") {
        Write-Host "Adding Terminal-Icons module import to Microsoft PowerShell profile" -ForegroundColor Yellow
        Add-Content -Path $microsoftProfilePath -Value "`n# Load Terminal-Icons module"
        Add-Content -Path $microsoftProfilePath -Value "Import-Module -Name Terminal-Icons"
    }
    
    # Add PSReadLine module import if it's not there
    if ($microsoftProfileContent -notlike "*Import-Module PSReadLine*") {
        Write-Host "Adding PSReadLine module import to Microsoft PowerShell profile" -ForegroundColor Yellow
        Add-Content -Path $microsoftProfilePath -Value "`n# Load PSReadLine module"
        Add-Content -Path $microsoftProfilePath -Value "if (`$host.Name -eq 'ConsoleHost') { Import-Module PSReadLine }"
        
        # Add basic PSReadLine configuration
        Add-Content -Path $microsoftProfilePath -Value "`n# Configure PSReadLine"
        Add-Content -Path $microsoftProfilePath -Value "Set-PSReadLineOption -PredictionSource History"
        Add-Content -Path $microsoftProfilePath -Value "Set-PSReadLineOption -PredictionViewStyle ListView" 
        Add-Content -Path $microsoftProfilePath -Value "Set-PSReadLineOption -EditMode Windows"
        Add-Content -Path $microsoftProfilePath -Value "Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward"
        Add-Content -Path $microsoftProfilePath -Value "Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward"
    }
}

# Run AltSnap configuration if it exists
if (Test-Path ".\altsnap\createTask.ps1") {
    Write-Host "Setting up AltSnap..." -ForegroundColor Cyan
    .\altsnap\createTask.ps1 | Out-Null
}

# Configure Microsoft.PowerShell_profile.ps1
Write-Host "Configuring Microsoft PowerShell profile..." -ForegroundColor Cyan
$MicrosoftProfileDir = Split-Path -Parent "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path -Path $MicrosoftProfileDir)) {
    New-Item -ItemType Directory -Path $MicrosoftProfileDir -Force | Out-Null
    Write-Host "Created Microsoft PowerShell profile directory: $MicrosoftProfileDir" -ForegroundColor Green
}

# Create Microsoft.PowerShell_profile.ps1 if it doesn't exist
if (-not (Test-Path -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1")) {
    Write-Host "Copying Microsoft.PowerShell_profile.ps1 to $HOME\Documents\PowerShell\" -ForegroundColor Yellow
    Copy-Item -Path ".\Microsoft.PowerShell_profile.ps1" -Destination "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
} 

Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "-----------------------------------------" -ForegroundColor Cyan
Write-Host "Summary of Installed Components:" -ForegroundColor Cyan
Write-Host "✓ PowerShell Modules: PSReadLine, Terminal-Icons, etc." -ForegroundColor Green
Write-Host "✓ Tools: Wezterm, Starship, Oh-My-Posh, Lazygit, Fastfetch" -ForegroundColor Green
Write-Host "✓ Pokemon-ColorScripts for terminal decoration" -ForegroundColor Green
Write-Host "✓ Configuration files for all tools" -ForegroundColor Green
Write-Host "-----------------------------------------" -ForegroundColor Cyan
Write-Host "Important Paths:" -ForegroundColor Cyan
Write-Host "PowerShell Profile: $($PROFILE.CurrentUserAllHosts)" -ForegroundColor Yellow
Write-Host "Microsoft PowerShell Profile: $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -ForegroundColor Yellow
Write-Host "WezTerm Config: $PSScriptRoot\wezterm\wezterm.lua" -ForegroundColor Yellow
Write-Host "Pokemon-ColorScripts: $InstallDir" -ForegroundColor Yellow
Write-Host "Oh-My-Posh Theme: $env:LOCALAPPDATA\Programs\oh-my-posh\themes\easy-term.omp.json" -ForegroundColor Yellow
Write-Host "-----------------------------------------" -ForegroundColor Cyan
Write-Host "You may need to restart your PowerShell session for all changes to take effect." -ForegroundColor Yellow
Write-Host "Enjoy your new terminal setup!" -ForegroundColor Green
