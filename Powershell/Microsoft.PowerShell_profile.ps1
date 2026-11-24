# ==============================================================================
#  PowerShell Profile - lean edition
#  Uses only built-in PowerShell features + Starship + Fastfetch.
#  No extra modules needed. Starship/Fastfetch are skipped silently if missing.
#  Location: $PROFILE   ->  nvim $PROFILE   (or: ep)
# ==============================================================================

# Skip for non-interactive hosts (scheduled tasks, services, etc.)
if (-not [Environment]::UserInteractive) { return }

# ------------------------------------------------------------------------------
#  Settings
# ------------------------------------------------------------------------------
$ProfileConfig = @{
    ShowFastfetch        = $true    # run fastfetch on every new terminal
    ClearBeforeFastfetch = $false   # Clear-Host before fastfetch
    UseStarship          = $true    # use the Starship prompt
    TransientPrompt      = $false    # collapse old prompts to a minimal one
}

function Test-Command {
    param([Parameter(Mandatory)][string]$Name)
    [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

# UTF-8 so icons/glyphs render correctly
try {
    [Console]::OutputEncoding = [Console]::InputEncoding = [Text.Encoding]::UTF8
    $OutputEncoding = [Text.Encoding]::UTF8
} catch {}

$env:POWERSHELL_TELEMETRY_OPTOUT = 1

# ------------------------------------------------------------------------------
#  PSReadLine (built in): predictions, history search, key bindings
# ------------------------------------------------------------------------------
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    $psrlVersion = (Get-Module PSReadLine).Version

    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistoryNoDuplicates:$true
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -PredictionSource History

    # Richer predictions on PS 7.2+ (PSReadLine 2.2+)
    if ($psrlVersion -ge [version]'2.2.0') {
        try { Set-PSReadLineOption -PredictionSource HistoryAndPlugin } catch {}
        try { Set-PSReadLineOption -PredictionViewStyle ListView }       catch {}
    }

    # Keep secrets out of history
    Set-PSReadLineOption -AddToHistoryHandler {
        param($line)
        return ($line -notmatch 'password|passwd|secret|token|apikey|api_key|-AsPlainText')
    }

    Set-PSReadLineKeyHandler -Key UpArrow         -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow       -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab             -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Ctrl+d          -Function DeleteChar
    Set-PSReadLineKeyHandler -Key Ctrl+w          -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Alt+d           -Function DeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+z          -Function Undo
    Set-PSReadLineKeyHandler -Key Ctrl+y          -Function Redo
    }

if ($PSStyle) {
    $PSStyle.FileInfo.Directory = $PSStyle.Foreground.FromRgb(0x14, 0xa9, 0xfd) + $PSStyle.Bold
}
# ------------------------------------------------------------------------------
#  Tab completion for tools that ship with Windows / .NET
# ------------------------------------------------------------------------------
if (Test-Command winget) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [Text.UTF8Encoding]::new()
        $word = $wordToComplete.Replace('"', '""')
        $ast  = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$word" --commandline "$ast" --position $cursorPosition |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    }
}

if (Test-Command dotnet) {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ------------------------------------------------------------------------------
#  Navigation
# ------------------------------------------------------------------------------
function ..   { Set-Location .. }
function ...  { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ~    { Set-Location $HOME }
function docs { Set-Location ([Environment]::GetFolderPath('MyDocuments')) }
function dl   { Set-Location (Join-Path $HOME 'Downloads') }
function desk { Set-Location ([Environment]::GetFolderPath('Desktop')) }

function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# ------------------------------------------------------------------------------
#  File & text utilities
# ------------------------------------------------------------------------------
function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force -Hidden @args }

function touch {
    param([Parameter(Mandatory, ValueFromRemainingArguments)][string[]]$Path)
    foreach ($p in $Path) {
        if (Test-Path $p) { (Get-Item $p).LastWriteTime = Get-Date }
        else              { New-Item -ItemType File -Path $p | Out-Null }
    }
}

function which {
    param([Parameter(Mandatory)][string]$Name)
    Get-Command $Name -All -ErrorAction SilentlyContinue |
        Select-Object Name, CommandType,
            @{n='Path'; e={ if ($_.Source) { $_.Source } else { $_.Definition } }}
}

function head {
    param([Parameter(Mandatory, Position = 0)][string]$Path, [int]$n = 10)
    Get-Content $Path -TotalCount $n
}

function tail {
    param([Parameter(Mandatory, Position = 0)][string]$Path, [int]$n = 10, [switch]$f)
    Get-Content $Path -Tail $n -Wait:$f
}

function grep {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Pattern,
        [Parameter(Position = 1)][string]$Path,
        [Parameter(ValueFromPipeline)]$InputObject
    )
    begin   { $pipe = @() }
    process { if ($null -ne $InputObject) { $pipe += $InputObject } }
    end {
        if ($Path)           { Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | Select-String -Pattern $Pattern }
        elseif ($pipe.Count) { $pipe | Out-String -Stream | Select-String -Pattern $Pattern }
        else                 { Get-ChildItem . -Recurse -File -ErrorAction SilentlyContinue | Select-String -Pattern $Pattern }
    }
}

function extract {
    param([Parameter(Mandatory)][string]$File, [string]$Destination = '.')
    $full = (Resolve-Path $File).Path
    switch -Regex ($full) {
        '\.zip$'                                  { Expand-Archive -Path $full -DestinationPath $Destination -Force }
        '\.(tar|tgz|tar\.gz|tar\.bz2|tar\.xz)$'  { tar -xf $full -C $Destination }
        default                                   { Write-Warning "Unsupported archive type: $full" }
    }
}

function sizeof {
    param([string]$Path = '.')
    $bytes = (Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
              Measure-Object -Property Length -Sum).Sum
    '{0:N2} MB' -f ($bytes / 1MB)
}

function cpy { param([Parameter(ValueFromPipeline)]$Text) process { $Text | Set-Clipboard } }
function pst { Get-Clipboard }

# ------------------------------------------------------------------------------
#  System & process utilities
# ------------------------------------------------------------------------------
function df {
    Get-Volume | Where-Object DriveLetter |
        Format-Table DriveLetter, FileSystemLabel,
            @{n='SizeGB'; e={[math]::Round($_.Size / 1GB, 1)}},
            @{n='FreeGB'; e={[math]::Round($_.SizeRemaining / 1GB, 1)}} -AutoSize
}

function pgrep { param([Parameter(Mandatory)][string]$Name) Get-Process -Name "*$Name*" -ErrorAction SilentlyContinue }
function pkill { param([Parameter(Mandatory)][string]$Name) Get-Process -Name "*$Name*" -ErrorAction SilentlyContinue | Stop-Process -Force }

function killport {
    param([Parameter(Mandatory)][int]$Port)
    $conns = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if (-not $conns) { Write-Host "Nothing listening on port $Port"; return }
    $conns | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object {
        Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
        Write-Host "Killed PID $_ on port $Port"
    }
}

function uptime {
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $span = (Get-Date) - $boot
    'Up {0}d {1}h {2}m (since {3})' -f $span.Days, $span.Hours, $span.Minutes, $boot
}

function Get-PubIP { Invoke-RestMethod -Uri 'https://api.ipify.org' }
function flushdns  { Clear-DnsClientCache; Write-Host 'DNS cache flushed' }
function path      { $env:Path -split ';' | Where-Object { $_ } }

# Refresh PATH in the current session (handy right after installing Starship/Fastfetch)
function Update-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

# Open a new elevated shell
function admin {
    Start-Process (Get-Process -Id $PID).Path -Verb RunAs -ArgumentList '-NoLogo'
}

function Update-All {
    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
}

# ------------------------------------------------------------------------------
#  Git shortcuts (only defined if git exists)
# ------------------------------------------------------------------------------
if (Test-Command git) {
    function g   { git @args }
    function gs  { git status -sb }
    function ga  { git add @args }
    function gaa { git add --all }
    function gc  { git commit -m @args }
    function gp  { git push @args }
    function gpl { git pull @args }
    function gco { git checkout @args }
    function gb  { git branch @args }
    function gd  { git diff @args }
    function gl  { git log --oneline --graph --decorate -n 20 }
    function lg  { lazygit @args }
}

# ------------------------------------------------------------------------------
#  Profile management & aliases
# ------------------------------------------------------------------------------
function ep     { nvim $PROFILE }
function reload { . $PROFILE; Write-Host 'Profile reloaded.' -ForegroundColor Green }

Set-Alias -Name open -Value Invoke-Item
Set-Alias -Name edit   -Value nvim
Set-Alias -Name c    -Value Clear-Host

# ------------------------------------------------------------------------------
#  Starship prompt
# ------------------------------------------------------------------------------
[Environment]::SetEnvironmentVariable('STARSHIP_CONFIG', 'C:/Users/hyprarcher/.config/starship/starship.toml', 'User')
if ($ProfileConfig.UseStarship -and (Test-Command starship)) {
    Invoke-Expression (& starship init powershell)
    if ($ProfileConfig.TransientPrompt -and (Test-Command Enable-TransientPrompt)) {
        Enable-TransientPrompt
    }
}

# ------------------------------------------------------------------------------
#  Fastfetch - every new interactive terminal
# ------------------------------------------------------------------------------
$isInteractiveHost = ($Host.Name -in 'ConsoleHost', 'Visual Studio Code Host') -and
                     (-not ([Environment]::GetCommandLineArgs() -contains '-NonInteractive'))

if ($ProfileConfig.ShowFastfetch -and $isInteractiveHost -and (Test-Command fastfetch)) {
    if ($ProfileConfig.ClearBeforeFastfetch) { Clear-Host }
    fastfetch
}

Remove-Variable isInteractiveHost -ErrorAction SilentlyContinue
