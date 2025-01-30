# Set up for terminal icons and other visual configurations
$ProgressPreference = 'SilentlyContinue'

# Check for and install Terminal-Icons module if needed
if (-not (Get-Module -ListAvailable -Name Terminal-Icons))
{
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

# Import Z module for directory navigation
if (-not (Get-Module -ListAvailable -Name Z))
{
    Install-Module -Name Z -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Z

# Check connection to GitHub
$canConnectToGitHub = Test-NetConnection -ComputerName github.com -InformationLevel Quiet

# -------------------------
# Functions for Installation
# -------------------------

# Install FiraCode Nerd Font if not installed
function Install-Font
{
    $fontNames = @('FiraCode Nerd Font')
    $fontUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip'

    $installedFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
    $fontsMissing = $fontNames | Where-Object { $_ -notin $installedFonts }

    if ($fontsMissing.Count -gt 0)
    {
        $zipPath = "$env:TEMP\FireCode.zip"
        $extractPath = "$env:TEMP\HackFonts"

        Invoke-WebRequest -Uri $fontUrl -OutFile $zipPath
        New-Item -ItemType Directory -Path $extractPath -Force
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        Get-ChildItem -Path "$extractPath\*" -Filter "*.ttf" | ForEach-Object {
            $fontPath = $_.FullName
            $shell = New-Object -ComObject Shell.Application
            $fontsFolder = $shell.Namespace(0x14) # 0x14 is the Fonts folder
            $fontsFolder.CopyHere($fontPath)
        }

        Remove-Item -Path $zipPath -Force
        Remove-Item -Path $extractPath -Recurse -Force

        Write-Host "Fonts installed successfully: $($fontsMissing -join ', ')"
    } else
    {
        Write-Host "All specified fonts are already installed."
    }
}

# -------------------------
# PowerShell Update Function
# -------------------------

# Update PowerShell if newer version available
function Update-PowerShell
{
    if (-not $global:canConnectToGitHub)
    {
        Write-Host "Skipping PowerShell update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
        return
    }

    try
    {
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
        $currentVersion = [Version]$PSVersionTable.PSVersion
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = [Version]$latestReleaseInfo.tag_name.Trim('v')

        # Compare the current version and latest version
        if ($currentVersion -lt $latestVersion)
        {
            Write-Host "Updating PowerShell from $currentVersion to $latestVersion..." -ForegroundColor Yellow
            winget install --id Microsoft.Powershell --source winget --accept-package-agreements --accept-source-agreements
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes." -ForegroundColor Magenta
        } else
        {
            Write-Host "Your PowerShell version ($currentVersion) is up to date." -ForegroundColor Green
        }
    } catch
    {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}

# -------------------------
# Set Admin Prompt
# -------------------------

# Check for Admin rights and set prompt
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function prompt
{
    if ($isAdmin)
    {
        "[" + (Get-Location) + "] # "
    } else
    {
        "[" + (Get-Location) + "] $ "
    }
}

$adminSuffix = if ($isAdmin)
{ " [ADMIN]" 
} else
{ "" 
}
$Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

# -------------------------
# oh-my-posh Setup
# -------------------------

# Set up oh-my-posh theme
Invoke-Expression (oh-my-posh --init --shell pwsh --config ~/termTheme.json)

# -------------------------
# Paths for Various Projects
# -------------------------

# Define important directories
$rust = "$HOME\Desktop\My Files\Rust"
$repos = "$HOME\source\repos"
$work = "$HOME\Desktop\Armanino"
$myfiles = "$HOME\Desktop\My Files"
$desktop = "$HOME\Desktop"

# Files of interest
$settings =  "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$nvim = "$HOME\AppData\Local\nvim\init.lua"
$wez = "$HOME\.wezterm.lua"
$glaze = "$HOME\.glzr\glazewm\config.yaml"

# -------------------------
# Environment Configuration
# -------------------------

# Add rust-analyzer to PATH
$env:PATH += ";C:\Users\Addison.Fischer\.cargo\bin"

# Programs I use
$env:Path += ";C:\Users\Addison.Fischer\Desktop\My Files\CodemerxDecompilex64"

# -------------------------
# Custom Functions
# -------------------------

# System Info Function
function sysinfo
{
    Get-ComputerInfo 
}

# Networking Functions
function resetnetwork
{

    ipconfig /release | Out-Null
    Write-Host "Network has been released" -foregroundcolor red
    ipconfig /flushdns | Out-Null
    Clear-DnsClientCache | Out-Null
    Write-Host "DNS has been cleared" -foregroundcolor yellow
    ipconfig /renew | Out-Null
    Write-Host "Network has been reset" -foregroundcolor green
    Write-Host "" -foregroundcolor green
    Write-Host "" -foregroundcolor green
}

# Networking Functions
function flushdns
{
    Clear-DnsClientCache
    Write-Host "DNS has been flushed"
}

function weather ($command)
{
    irm "https://wttr.in/$command" 
}

function text
{
    & explorer.exe https://messages.google.com/web/u/0/conversations/8
}
 
function def ($string)
{
    wikit "$string"
}

function whereis ($command)
{
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function qr ($string)
{
    irm "qrenco.de/$string"
}

function rust
{
    Set-Location $rust
}

function work
{
    Set-Location $work
}

function repos
{
    Set-Location $repos
}

function myfiles
{
    Set-Location $myfiles
}

function desktop
{
    Set-Location $desktop
} 

function fcd 
{
    $path = fzf
    echo $path
    Set-Location $path\.. 
}

function home
{
    Set-Location $home
}

function postman
{
    & "C:\Users\Addison.Fischer\AppData\Local\Postman\postman.exe"
}

function npro
{
    nvim.exe $nvim 
}

function profile
{
    nvim.exe $profile 
}

function netlist
{
    param (
        [string]$interfaceIPPrefix = "192.168.69."
    )

    $foundInterface = $false
    arp -a | ForEach-Object {
        if ($_ -match "^Interface: $interfaceIPPrefix.*")
        {
            $foundInterface = $true
            Write-Output $_
        } elseif ($_ -match "^Interface:")
        {
            $foundInterface = $false
        } elseif ($foundInterface -and ($_ -match "^\s*($interfaceIPPrefix[0-9]+)\s+([0-9A-F-]+)"))
        {
            $ipAddress = $matches[1]
            $macAddress = $matches[2]
            $hostname = (Test-Connection -ComputerName $ipAddress -Count 1 -ErrorAction SilentlyContinue).Address.HostName
            [PSCustomObject]@{
                IPAddress = $ipAddress
                MACAddress = $macAddress
                Hostname = $hostname
            }
        }
    } | Format-Table -AutoSize
}

# Apple Device Detection (Using MAC addresses)
function apples
{
    $url = "https://www.netify.ai/resources/macs/brands/apple"
    try
    {
        $pageContent = Invoke-WebRequest -Uri $url -UseBasicParsing
        $appleOuis = [regex]::Matches($pageContent.Content, "(?:[0-9A-Fa-f]{2}:){2}[0-9A-Fa-f]{2}") |
            ForEach-Object { $_.Value.ToUpper() } | Sort-Object -Unique
    } catch
    {
        Write-Output "Failed to fetch MAC prefix list from the website."
        return
    }

    arp -a | ForEach-Object {
        if ($_ -match "^\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\s+([0-9A-F-]+)")
        {
            $ipAddress = $matches[1]
            $macAddress = $matches[2].ToUpper() -replace "-", ":"
            
            $isAppleDevice = $appleOuis | ForEach-Object { $macAddress.StartsWith($_) } | Where-Object { $_ -eq $true }
            
            if ($isAppleDevice)
            {
                $hostname = ""
                try
                {
                    $hostname = (Resolve-DnsName -Name $ipAddress -ErrorAction Stop).NameHost
                } catch
                {
                    $hostname = "Not resolved"
                }
                [PSCustomObject]@{
                    IPAddress = $ipAddress
                    MACAddress = $macAddress
                    Hostname = $hostname
                    DeviceType = "Apple"
                }
            }
        }
    } | Format-Table -AutoSize
}

# -------------------------
# Miscellaneous Utilities
# -------------------------

function wcurl
{
    param(
        [string]$Uri
    )
    Invoke-WebRequest -Uri $Uri | Select-Object -ExpandProperty Content
}


function cheatsheet
{
    param (
        [string]$language
    )
    if (-not $language)
    {
        Write-Host "Please specify a language."
        return
    }
    
    $url = "https://cheat.sh/$language"
    try
    {
        $content = Invoke-WebRequest -Uri $url | Select-Object -ExpandProperty Content
        Write-Output $content
    } catch
    {
        Write-Host "Failed to retrieve content from $url"
    }
}


function cmt
{
    & "C:\Users\Addison.Fischer\.dotnet\tools\pac.exe" tool cmt
}

function touch($file)
{ "" | Out-File $file -Encoding ASCII 
}

function ff($name)
{
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.FullName)"
    }
}

function Get-PubIP
{ (Invoke-WebRequest http://ifconfig.me/ip).Content 
}

function admin
{
    if ($args.Count -gt 0)
    {
        $argList = "& '$args'"
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else
    {
        Start-Process wt -Verb runAs
    }
}

Set-Alias -Name su -Value admin

function parsec
{
    & "C:\Program Files\Parsec\parsecd.exe"
}
function unzip ($file)
{
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function touch($file)
{ "" | Out-File $file -Encoding ASCII 
}

function df
{
    get-volume
}

function mkcd
{ param($dir) mkdir $dir -Force; Set-Location $dir 
}

function la
{
    Get-ChildItem -Path . -Force | Format-Table -AutoSize 
}

function ll
{
    Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize 
}

function gs
{
    git status 
}

function ga
{
    git add . 
}

function gc
{
    param($m) git commit -m "$m" 
}

function gp
{
    git push 
}

function gcl
{
    git clone "$args" 
}

function gcom
{
    git add .
    git commit -m "$args"
}

function lazyg
{
    git add .
    git commit -m "$args"
    git push
}

# Networking Utilities
function flushdns
{
    Clear-DnsClientCache
    Write-Host "DNS has been flushed"
}

function cpy
{ Set-Clipboard $args[0] 
}

function pst
{ Get-Clipboard 
}

# -------------------------
# Final Setup
# -------------------------

# Import PSReadLine and configure
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -PredictionViewStyle ListView

# Networking and completion
Import-Module -Name PowerPlatformCLIAutoComplete

Set-PSReadLineOption -Colors @{
    Command = 'Yellow'
    Parameter = 'Green'
    String = 'DarkCyan'
}

$PSROptions = @{
    ContinuationPrompt = '  '
    Colors             = @{
        Parameter          = $PSStyle.Foreground.Magenta
        Selection          = $PSStyle.Background.Black
        InLinePrediction   = $PSStyle.Foreground.BrightYellow + $PSStyle.Background.BrightBlack
    }
}
Set-PSReadLineOption @PSROptions
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine

# Function for argument completion
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock

# Import the Z module for directory navigation
Import-Module z

# Add Python path to environment
$env:Path += ";C:\Python312\Scripts"
$env:Path += ";C:\Program Files\GitHub CLI"

Clear-Host
