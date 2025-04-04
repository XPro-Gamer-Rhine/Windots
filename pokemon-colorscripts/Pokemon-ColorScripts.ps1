# Pokemon-ColorScripts.ps1
# PowerShell version of pokemon-colorscripts for Windows

[CmdletBinding(DefaultParameterSetName='Default')]
param (
    [Parameter(ParameterSetName='Help')][switch]$Help,
    [Parameter(ParameterSetName='List')][switch]$List,
    [Parameter(ParameterSetName='Name')][string]$Name,
    [Parameter(ParameterSetName='Name')][string]$Form = "",
    [Parameter(ParameterSetName='Name')][switch]$NoTitle,
    [Parameter(ParameterSetName='RandomOrName')][switch]$Shiny,
    [Parameter(ParameterSetName='RandomOrName')][switch]$Big,
    [Parameter(ParameterSetName='Random')][string]$Random = "1-8",
    [Parameter(ParameterSetName='RandomNames')][string]$RandomByNames
)

# Constants
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path -Parent $ScriptPath
$ColorscriptsDir = Join-Path -Path $ScriptDir -ChildPath "colorscripts"

$RegularSubdir = "regular"
$ShinySubdir = "shiny"

$LargeSubdir = "large"
$SmallSubdir = "small"

$ShinyRate = 1 / 128
$script:Generations = @{
    "1" = @(1, 151)
    "2" = @(152, 251)
    "3" = @(252, 386)
    "4" = @(387, 493)
    "5" = @(494, 649)
    "6" = @(650, 721)
    "7" = @(722, 809)
    "8" = @(810, 898)
}

function Print-File {
    param (
        [string]$FilePath
    )
    
    if (Test-Path -Path $FilePath) {
        Get-Content -Path $FilePath
    } else {
        Write-Error "File not found: $FilePath"
        exit 1
    }
}

function List-PokemonNames {
    $pokemonJsonPath = Join-Path -Path $ScriptDir -ChildPath "pokemon.json"
    $pokemonJson = Get-Content -Path $pokemonJsonPath -Raw | ConvertFrom-Json
    
    foreach ($pokemon in $pokemonJson) {
        Write-Output $pokemon.name
    }
}

function Show-PokemonByName {
    param (
        [string]$Name,
        [bool]$ShowTitle,
        [bool]$IsShiny,
        [bool]$IsLarge,
        [string]$Form = ""
    )
    
    $BasePath = $ColorscriptsDir
    $ColorSubdir = if ($IsShiny) { $ShinySubdir } else { $RegularSubdir }
    # default to smaller size as this makes sense for most font size + terminal size combinations
    $SizeSubdir = if ($IsLarge) { $LargeSubdir } else { $SmallSubdir }
    
    $pokemonJsonPath = Join-Path -Path $ScriptDir -ChildPath "pokemon.json"
    $pokemonJson = Get-Content -Path $pokemonJsonPath -Raw | ConvertFrom-Json
    $pokemonNames = $pokemonJson | ForEach-Object { $_.name }
    
    if ($pokemonNames -notcontains $Name) {
        Write-Error "Invalid pokemon $Name"
        exit 1
    }
    
    if ($Form) {
        $pokemon = $pokemonJson | Where-Object { $_.name -eq $Name } | Select-Object -First 1
        $forms = $pokemon.forms
        $alternateForms = $forms | Where-Object { $_ -ne "regular" }
        
        if ($alternateForms -contains $Form) {
            $Name += "-$Form"
        }
        else {
            Write-Error "Invalid form '$Form' for pokemon $Name"
            if (-not $alternateForms) {
                Write-Output "No alternate forms available for $Name"
            }
            else {
                Write-Output "Available alternate forms are:"
                foreach ($formName in $alternateForms) {
                    Write-Output "- $formName"
                }
            }
            exit 1
        }
    }
    
    $PokemonFile = Join-Path -Path $BasePath -ChildPath "$SizeSubdir\$ColorSubdir\$Name"
    
    if ($ShowTitle) {
        if ($IsShiny) {
            Write-Output "$Name (shiny)"
        }
        else {
            Write-Output $Name
        }
    }
    
    Print-File -FilePath $PokemonFile
}

function Show-RandomPokemon {
    param (
        [string]$Generations,
        [bool]$ShowTitle,
        [bool]$IsShiny,
        [bool]$IsLarge
    )
    
    # Generation list
    if ($Generations.Split(",").Count -gt 1) {
        $inputGens = $Generations.Split(",")
        $startGen = $inputGens | Get-Random
        $endGen = $startGen
    }
    # Generation range
    elseif ($Generations.Split("-").Count -gt 1) {
        $genSplit = $Generations.Split("-")
        $startGen = $genSplit[0]
        $endGen = $genSplit[1]
    }
    # Single generation
    else {
        $startGen = $Generations
        $endGen = $startGen
    }
    
    $pokemonJsonPath = Join-Path -Path $ScriptDir -ChildPath "pokemon.json"
    $pokemonJson = Get-Content -Path $pokemonJsonPath -Raw | ConvertFrom-Json
    $pokemon = $pokemonJson | ForEach-Object { $_.name }
    
    try {
        $startIdx = $script:Generations[$startGen][0]
        $endIdx = $script:Generations[$endGen][1]
        $randomIdx = Get-Random -Minimum $startIdx -Maximum ($endIdx + 1)
        $randomPokemon = $pokemon[$randomIdx - 1]
        
        # if the shiny flag is not passed, set a small random chance for the
        # pokemon to be shiny. If the flag is set, always show shiny
        if (-not $IsShiny) {
            $IsShiny = (Get-Random -Minimum 0.0 -Maximum 1.0) -le $ShinyRate
        }
        
        Show-PokemonByName -Name $randomPokemon -ShowTitle $false -IsShiny $IsShiny -IsLarge $IsLarge
    }
    catch {
        Write-Error "Invalid generation '$Generations'"
        Write-Error $_.Exception.Message
        exit 1
    }
}

function Show-RandomPokemonByNames {
    param (
        [string]$Names,
        [bool]$ShowTitle,
        [bool]$IsShiny,
        [bool]$IsLarge
    )
    
    $namesList = @()
    $pokemonJsonPath = Join-Path -Path $ScriptDir -ChildPath "pokemon.json"
    $pokemonJson = Get-Content -Path $pokemonJsonPath -Raw | ConvertFrom-Json
    $pokemonNames = $pokemonJson | ForEach-Object { $_.name }
    
    # Test and reject invalid names
    foreach ($name in $Names.Split(",")) {
        if ($pokemonNames -notcontains $name) {
            Write-Error "Invalid pokemon $name"
        }
        else {
            $namesList += $name
        }
    }
    
    if ($namesList.Count -lt 1) {
        Write-Error "No correct pokemon names have been provided."
        exit 1
    }
    
    $randomPokemon = $namesList | Get-Random
    
    # if the shiny flag is not passed, set a small random chance for the
    # pokemon to be shiny. If the flag is set, always show shiny
    if (-not $IsShiny) {
        $IsShiny = (Get-Random -Minimum 0.0 -Maximum 1.0) -le $ShinyRate
    }
    
    Show-PokemonByName -Name $randomPokemon -ShowTitle $false -IsShiny $IsShiny -IsLarge $IsLarge
}

function Show-Help {
    Write-Output @"
Pokemon-ColorScripts - CLI utility to print out unicode image of a pokemon in your PowerShell

USAGE:
    pokemon-colorscripts [OPTION] [POKEMON NAME]

OPTIONS:
    -Help                  Show this help message and exit
    -List                  Print list of all pokemon
    -Name <string>         Select pokemon by name. Generally spelled like in the games.
                           A few exceptions are nidoran-f, nidoran-m, mr-mime, farfetchd, flabebe
                           type-null etc. Perhaps filter the output of -List if in doubt.
    -Form <string>         Show an alternate form of a pokemon
    -NoTitle               Do not display pokemon name
    -Shiny                 Show the shiny version of the pokemon instead
    -Big                   Show a larger version of the sprite
    -Random [string]       Show a random pokemon. This parameter can optionally be
                           followed by a generation number or range (1-8) to show random
                           pokemon from a specific generation or range of generations.
                           The generations can be provided as a continuous range (eg. 1-3)
                           or as a list of generations (1,3,6)
    -RandomByNames <string> Show a random pokemon chosen in the provided list of names.
                           This list is in form (poke_1,poke_2,...,poke_n) only separated
                           by commas WITHOUT whitespace (eg. charmander,bulbasaur,squirtle)
"@
}

# Main script logic
if ($Help) {
    Show-Help
}
elseif ($List) {
    List-PokemonNames
}
elseif ($Name) {
    Show-PokemonByName -Name $Name -ShowTitle (-not $NoTitle) -IsShiny $Shiny -IsLarge $Big -Form $Form
}
elseif ($PSBoundParameters.ContainsKey('Random')) {
    if ($Form) {
        Write-Error "-Form parameter is unexpected with -Random"
        exit 1
    }
    Show-RandomPokemon -Generations $Random -ShowTitle (-not $NoTitle) -IsShiny $Shiny -IsLarge $Big
}
elseif ($RandomByNames) {
    if ($Form) {
        Write-Error "-Form parameter is unexpected with -RandomByNames"
        exit 1
    }
    Show-RandomPokemonByNames -Names $RandomByNames -ShowTitle (-not $NoTitle) -IsShiny $Shiny -IsLarge $Big
}
else {
    Show-Help
}