# ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ████████╗███████╗
# ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
# ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║   ██║   ███████╗
# ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║   ██║   ╚════██║
# ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝   ██║   ███████║
#  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
# Profile.ps1 - Scott McKendry
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# Aliases 🔗
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Set-Alias -Name cat -Value bat
Set-Alias -Name df -Value Get-Volume
Set-Alias -Name ff -Value Find-File
Set-Alias -Name grep -Value Find-String
Set-Alias -Name l -Value Get-ChildItemPretty
Set-Alias -Name la -Value Get-ChildItemPretty
Set-Alias -Name ll -Value Get-ChildItemPretty
Set-Alias -Name ls -Value Get-ChildItemPretty
Set-Alias -Name rm -Value Remove-ItemExtended
Set-Alias -Name su -Value Update-ShellElevation
Set-Alias -Name tif Show-ThisIsFine
Set-Alias -Name touch -Value New-File
Set-Alias -Name up -Value Update-Profile
Set-Alias -Name us -Value Update-Software
Set-Alias -Name vi -Value nvim
Set-Alias -Name vim -Value nvim
Set-Alias -Name which -Value Show-Command


# Putting the FUN in Functions 🎉
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Find-WindotsRepository {
    <#
    .SYNOPSIS
        Finds the local Windots repository.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ProfilePath
    )

    Write-Verbose "Resolving the symbolic link for the profile"
    $profileSymbolicLink = Get-ChildItem $ProfilePath | Where-Object FullName -EQ $PROFILE.CurrentUserAllHosts
    return Split-Path $profileSymbolicLink.Target
}

function Update-Profile {
    <#
    .SYNOPSIS
        Gets the latest changes from git, reruns the setup script and reloads the profile.
        Note that functions won't be updated, this requires a full PS session restart. Alias: up
    #>
    Write-Verbose "Storing current working directory in memory"
    $currentWorkingDirectory = $PWD

    Write-Verbose "Updating local profile from Github repository"
    Set-Location $ENV:WindotsLocalRepo
    git stash | Out-Null
    git pull | Out-Null
    git stash pop | Out-Null

    Write-Verbose "Rerunning setup script to capture any new dependencies."
    if (Get-Command -Name sudo -ErrorAction SilentlyContinue) {
        sudo pwsh ./Setup.ps1
    }
    else {
        Start-Process wezterm -Verb runAs -WindowStyle Hidden -ArgumentList "start --cwd $PWD pwsh -NonInteractive -Command ./Setup.ps1"
    }

    Write-Verbose "Reverting to previous working directory"
    Set-Location $currentWorkingDirectory

    Write-Verbose "Re-running profile script from $($PROFILE.CurrentUserAllHosts)"
    .$PROFILE.CurrentUserAllHosts
}

function Update-Software {
    <#
    .SYNOPSIS
        Updates all software installed via Winget & Chocolatey. Alias: us
    #>
    Write-Verbose "Updating software installed via Winget & Chocolatey"
    sudo winget upgrade --all --include-unknown --silent --verbose
    sudo choco upgrade all -y
    $ENV:SOFTWARE_UPDATE_AVAILABLE = ""
}

function Find-File {
    <#
    .SYNOPSIS
        Finds a file in the current directory and all subdirectories. Alias: ff
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        [string]$SearchTerm
    )

    Write-Verbose "Searching for '$SearchTerm' in current directory and subdirectories"
    $result = Get-ChildItem -Recurse -Filter "*$SearchTerm*" -ErrorAction SilentlyContinue

    Write-Verbose "Outputting results to table"
    $result | Format-Table -AutoSize
}

function Update-ShellElevation {
    <#
    .SYNOPSIS
        Elevates the current shell to run as an administrator. Alias: su
    #>
    Write-Verbose "Elevating shell to run as administrator"
    sudo -E pwsh -NoLogo -Interactive -NoExit -c "Clear-Host"
}

function Find-String {
    <#
    .SYNOPSIS
        Searches for a string in a file or directory. Alias: grep
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SearchTerm,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        [string]$Directory,
        [Parameter(Mandatory = $false)]
        [switch]$Recurse
    )

    Write-Verbose "Searching for '$SearchTerm' in '$Directory'"
    if ($Directory) {
        if ($Recurse) {
            Write-Verbose "Searching for '$SearchTerm' in '$Directory' and subdirectories"
            Get-ChildItem -Recurse $Directory | Select-String $SearchTerm
            return
        }

        Write-Verbose "Searching for '$SearchTerm' in '$Directory'"
        Get-ChildItem $Directory | Select-String $SearchTerm
        return
    }

    if ($Recurse) {
        Write-Verbose "Searching for '$SearchTerm' in current directory and subdirectories"
        Get-ChildItem -Recurse | Select-String $SearchTerm
        return
    }

    Write-Verbose "Searching for '$SearchTerm' in current directory"
    Get-ChildItem | Select-String $SearchTerm
}

function New-File {
    <#
    .SYNOPSIS
        Creates a new file with the specified name and extension. Alias: touch
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    Write-Verbose "Creating new file '$Name'"
    New-Item -ItemType File -Name $Name -Path $PWD | Out-Null
}

function Show-Command {
    <#
    .SYNOPSIS
        Displays the definition of a command. Alias: which
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )
    Write-Verbose "Showing definition of '$Name'"
    Get-Command $Name | Select-Object -ExpandProperty Definition
}

function Get-OrCreateSecret {
    <#
    .SYNOPSIS
        Gets secret from local vault or creates it if it does not exist. Requires SecretManagement and SecretStore modules and a local vault to be created.
        Install Modules with:
            Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore
        Create local vault with:
            Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore
            Set-SecretStoreConfiguration -Authentication None -Confirm:$False

        https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/

    .PARAMETER secretName
        Name of the secret to get or create. It is recommended to use the username or public key / client id as secret name to make it easier to identify the secret later.

    .EXAMPLE
        $password = Get-OrCreateSecret -secretName $username

    .EXAMPLE
        $clientSecret = Get-OrCreateSecret -secretName $clientId

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$secretName
    )

    Write-Verbose "Getting secret $secretName"
    $secretValue = Get-Secret $secretName -AsPlainText -ErrorAction SilentlyContinue

    if (!$secretValue) {
        $createSecret = Read-Host "No secret found matching $secretName, create one? Y/N"

        if ($createSecret.ToUpper() -eq "Y") {
            $secretValue = Read-Host -Prompt "Enter secret value for ($secretName)" -AsSecureString
            Set-Secret -Name $secretName -SecureStringSecret $secretValue
            $secretValue = Get-Secret $secretName -AsPlainText
        }
        else {
            throw "Secret not found and not created, exiting"
        }
    }
    return $secretValue
}

function Get-ChildItemPretty {
    <#
    .SYNOPSIS
        Runs eza with a specific set of arguments. Plus some line breaks before and after the output.
        Alias: ls, ll, la, l
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path = $PWD
    )

    Write-Host ""
    eza -a -l --header --icons --hyperlink --time-style relative $Path
    Write-Host ""
}

function Invoke-CustomFastfetch {
    $configPath = "$HOME/AppData/Local/fastfetch/config.jsonc"
    $tempPokemonFile = "$env:TEMP\pokemon_temp.txt"
    
    # Try to find the Pokemon-ColorScripts.ps1 script in different locations
    $possiblePaths = @(
        "C:\Program Files\PokemonColorScripts\Pokemon-ColorScripts.ps1",
        "$ENV:WindotsLocalRepo\pokemon-colorscripts\Pokemon-ColorScripts.ps1",
        "$PSScriptRoot\Pokemon-ColorScripts.ps1"
    )
    
    $pokemonScriptPath = $null
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $pokemonScriptPath = $path
            break
        }
    }
    
    # Check if Pokemon script exists
    if (-not $pokemonScriptPath) {
        Write-Warning "Pokemon Color Scripts not found. Falling back to standard fastfetch."
        fastfetch
        return
    }
    
    # Check if the config path exists, create directory if needed
    $configDir = Split-Path -Parent $configPath
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    try {
        # Use a simple approach with just the -Random parameter
        # This should work reliably based on the help output
        $randomGen = "1-8"  # All generations
        
        # Execute the command and capture output to file
        & $pokemonScriptPath -Random  $randomGen | Out-File -FilePath $tempPokemonFile -ErrorAction Stop
        
        # Check if the file was created and has content
        if (-not (Test-Path $tempPokemonFile) -or (Get-Item $tempPokemonFile).Length -eq 0) {
            throw "Pokemon file was not created or is empty"
        }
        
        # Read the existing config if it exists, otherwise create a new one
        if (Test-Path $configPath) {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
            if (-not $config) {
                $config = [PSCustomObject]@{}
            }
        } else {
            $config = [PSCustomObject]@{}
        }
        
        # Check if logo property exists and has the correct structure
        if (-not $config.logo) {
            $config | Add-Member -NotePropertyName logo -NotePropertyValue @{
                source = $tempPokemonFile
                type = "file"
                padding = @{
                    top = 1
                    left = 3
                }
            } -Force
        } else {
            # Ensure the logo property has a source property
            if (-not $config.logo.PSObject.Properties['source']) {
                $config.logo | Add-Member -NotePropertyName source -NotePropertyValue $tempPokemonFile -Force
            } else {
                $config.logo.source = $tempPokemonFile
            }
            
            # Ensure padding exists
            if (-not $config.logo.PSObject.Properties['padding']) {
                $config.logo | Add-Member -NotePropertyName padding -NotePropertyValue @{
                    top = 1
                    left = 3
                } -Force
            }
        }
        
        # Save the modified config
        $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
        
        # Run fastfetch
        fastfetch
    }
    catch {
        Write-Warning "Failed to generate Pokemon: $_"
        Write-Warning "Falling back to standard fastfetch."
        fastfetch
    }
    finally {
        # Clean up the temporary file
        if (Test-Path $tempPokemonFile) {
            Remove-Item -Path $tempPokemonFile -Force -ErrorAction SilentlyContinue
        }
    }
}

# Override Clear-Host to refresh Pokemon when clearing the screen
function global:Clear-Host {
    # Call a reliable method to clear the screen instead of the original Clear-Host
    [System.Console]::Clear()
    
    # Run fastfetch with a new random Pokemon
    Invoke-CustomFastfetch
}

# Create aliases for cls and clear to use our custom Clear-Host function
Set-Alias -Name cls -Value Clear-Host -Option AllScope -Force -Scope Global
Set-Alias -Name clear -Value Clear-Host -Option AllScope -Force -Scope Global

function Remove-ItemExtended {
    <#
    .SYNOPSIS
        Removes an item and (optionally) all its children. Alias: rm
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$rf,
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    Write-Verbose "Removing item '$Path' $($rf ? 'and all its children' : '')"
    Remove-Item $Path -Recurse:$rf -Force:$rf
}


# Environment Variables 🌐
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$ENV:WindotsLocalRepo = Find-WindotsRepository -ProfilePath $PSScriptRoot
$ENV:STARSHIP_CONFIG = "$ENV:WindotsLocalRepo\starship\starship.toml"
$ENV:_ZO_DATA_DIR = $ENV:WindotsLocalRepo
$ENV:OBSIDIAN_PATH = "$HOME\git\obsidian-vault"
$ENV:BAT_CONFIG_DIR = "$ENV:WindotsLocalRepo\bat"
$ENV:FZF_DEFAULT_OPTS = '--color=fg:-1,fg+:#ffffff,bg:-1,bg+:#3c4048 --color=hl:#5ea1ff,hl+:#5ef1ff,info:#ffbd5e,marker:#5eff6c --color=prompt:#ff5ef1,spinner:#bd5eff,pointer:#ff5ea0,header:#5eff6c --color=gutter:-1,border:#3c4048,scrollbar:#7b8496,label:#7b8496 --color=query:#ffffff --border="rounded" --border-label="" --preview-window="border-rounded" --height 40% --preview="bat -n --color=always {}"'


# Prompt & Shell Configuration 🐚
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Start background jobs for dotfiles and software update checks
Start-ThreadJob -ScriptBlock {
    Set-Location -Path $ENV:WindotsLocalRepo
    $gitUpdates = git fetch && git status
    if ($gitUpdates -match "behind") {
        $ENV:DOTFILES_UPDATE_AVAILABLE = "󱤛 "
    }
    else {
        $ENV:DOTFILES_UPDATE_AVAILABLE = ""
    }
} | Out-Null

Start-ThreadJob -ScriptBlock {
    <#
        This is gross, I know. But there's a noticible lag that manifests in powershell when running the winget and choco commands
        within the main pwsh process. Running this whole block as an isolated job fails to set the environment variable correctly.
        The compromise is to run the main logic of this block within a threadjob and get the output of the winget and choco commands
        via two isolated jobs. This sets the environment variable correctly and doesn't cause any lag (that I've noticed yet).
    #>
    $wingetUpdatesString = Start-Job -ScriptBlock { winget list --upgrade-available | Out-String } | Wait-Job | Receive-Job
    $chocoUpdatesString = Start-Job -ScriptBlock { choco upgrade all --noop -y | Out-String } | Wait-Job | Receive-Job
    if ($wingetUpdatesString -match "upgrades available" -or $chocoUpdatesString -notmatch "can upgrade 0/") {
        $ENV:SOFTWARE_UPDATE_AVAILABLE = " "
    }
    else {
        $ENV:SOFTWARE_UPDATE_AVAILABLE = ""
    }
} | Out-Null

function Invoke-Starship-TransientFunction {
    &starship module character
}

Invoke-Expression (&starship init powershell)
Enable-TransientPrompt
Invoke-Expression (& { ( zoxide init powershell --cmd cd | Out-String ) })

$colors = @{
    "Operator"         = "`e[35m" # Purple
    "Parameter"        = "`e[36m" # Cyan
    "String"           = "`e[32m" # Green
    "Command"          = "`e[34m" # Blue
    "Variable"         = "`e[37m" # White
    "Comment"          = "`e[38;5;244m" # Gray
    "InlinePrediction" = "`e[38;5;244m" # Gray
}

Set-PSReadLineOption -Colors $colors
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Function AcceptSuggestion -Key Alt+l
Import-Module -Name CompletionPredictor

# Skip fastfetch for non-interactive shells
if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
    return
}
Invoke-CustomFastfetch

# Pokemon ColorScripts
function Show-Pokemon {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName='Help')][switch]$Help,
        [Parameter(ParameterSetName='List')][switch]$List,
        [Parameter(ParameterSetName='Name')][string]$Name,
        [Parameter(ParameterSetName='Name')][string]$Form,
        [Parameter(ParameterSetName='Name')][switch]$NoTitle,
        [Parameter(ParameterSetName='RandomOrName')][switch]$Shiny,
        [Parameter(ParameterSetName='RandomOrName')][switch]$Big,
        [Parameter(ParameterSetName='Random')][switch]$Random,
        [Parameter(ParameterSetName='Random')][string]$RandomValue,
        [Parameter(ParameterSetName='RandomNames')][string]$RandomByNames
    )

    $ScriptPath = "C:\Program Files\PokemonColorScripts\\Pokemon-ColorScripts.ps1"

    # Build a hashtable of parameters to splat
    $params = @{}

    if ($Help) { $params.Add('Help', $true) }
    if ($List) { $params.Add('List', $true) }
    if ($Name) { $params.Add('Name', $Name) }
    if ($Form) { $params.Add('Form', $Form) }
    if ($NoTitle) { $params.Add('NoTitle', $true) }
    if ($Shiny) { $params.Add('Shiny', $true) }
    if ($Big) { $params.Add('Big', $true) }
    
    if ($Random) {
        if ($RandomValue) {
            $params.Add('Random', $RandomValue)
        } else {
            $params.Add('Random', "1-8")  # Default value
        }
    }
    
    if ($RandomByNames) { $params.Add('RandomByNames', $RandomByNames) }

    # Execute the script with the parameters
    & $ScriptPath @params
}

Set-Alias -Name pokemon-colorscripts -Value Show-Pokemon

# Initialize Oh My Posh
oh-my-posh --init --shell pwsh --config 'C:\Users\Death\AppData\Local\Programs\oh-my-posh\themes\easy-term.omp.json' | Invoke-Expression

# Load Terminal-Icons module
Import-Module -Name Terminal-Icons

# Load PSReadLine module
if ($host.Name -eq 'ConsoleHost') { Import-Module PSReadLine }

# Configure PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward




