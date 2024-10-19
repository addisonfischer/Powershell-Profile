$sourcePath = .\Microsoft.PowerShell_profile.ps1
$destinationPath = ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

if (-Not (Test-Path -Path $destinationPath))
{
    Copy-Item -Path $sourcePath -Destination $destinationPath
    Write-Host "File copied to $destinationPath."
}

if (-not (Get-Module -ListAvailable -Name Terminal-Icons))
{
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

$canConnectToGitHub = Test-NetConnection -ComputerName github.com -InformationLevel Quiet

function Install-Font
{
    $fontNames = @('Hack Nerd Font', 'Hack Nerd Font Mono', 'Hack Nerd Font Propo')
    $fontUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip'

    $installedFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
    $fontsMissing = $fontNames | Where-Object { $_ -notin $installedFonts }

    if ($fontsMissing.Count -gt 0)
    {
        $zipPath = "$env:TEMP\Hack.zip"
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

Install-Font


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
        $updateNeeded = $false
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
        if ($currentVersion -lt $latestVersion)
        {
            $updateNeeded = $true
        }

        if ($updateNeeded)
        {
            Write-Host "Updating PowerShell..." -ForegroundColor Yellow
            winget install --id Microsoft.Powershell --source winget --accept-package-agreements --accept-source-agreements
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else
        {
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch
    {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}
Update-PowerShell

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function prompt
{
    if ($isAdmin)
    { "[" + (Get-Location) + "] # " 
    } else
    { "[" + (Get-Location) + "] $ " 
    }
}
$adminSuffix = if ($isAdmin)
{ " [ADMIN]" 
} else
{ "" 
}
$Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

#ohmyposh setup
Copy-Item -Path .\termTheme.json -Destination ~\
Invoke-Expression (oh-my-posh --init --shell pwsh --config ~/termTheme.json)

try
{
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} catch
{
    Write-Error "Failed to install Chocolatey. Error: $_"
}
try
{
    winget install -e --id ajeetdsouza.zoxide
    Write-Host "zoxide installed successfully."
} catch
{
    Write-Error "Failed to install zoxide. Error: $_"
}

#Directories
$rust = "$HOME\Desktop\My Files\Rust"
$repos = "$HOME\source\repos"
$work = "$HOME\Desktop\Armanino"
$myfiles = "$HOME\Desktop\My Files"
$desktop = "$HOME\Desktop"

#Files
$settings =  "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$nvim = "$HOME\AppData\Local\nvim\init.lua"
$wez = "$HOME\.wezterm.lua"

# Add rust-analyzer to PATH
$env:PATH += ";C:\Users\Addison.Fischer\.cargo\bin"

#progz I use
$env:Path += ";C:\Users\Addison.Fischer\Desktop\My Files\CodemerxDecompilex64"

#functions
function whereis ($command)
{
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
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

function home
{
    Set-Location $home
}

Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -PredictionViewStyle ListView
Import-Module -Name PowerPlatformCLIAutoComplete

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

function df
{
    get-volume
}

function mkcd
{ param($dir) mkdir $dir -Force; Set-Location $dir 
}

function la
{ Get-ChildItem -Path . -Force | Format-Table -AutoSize 
}
function ll
{ Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize 
}

function gs
{ git status 
}

function ga
{ git add . 
}

function gc
{ param($m) git commit -m "$m" 
}

function gp
{ git push 
}

function gcl
{ git clone "$args" 
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

# Quick Access to System Information
function sysinfo
{ Get-ComputerInfo 
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


$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Clear-Host
