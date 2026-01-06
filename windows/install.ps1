# Windows 11 Developer Setup Script
# Run this from an Administrator PowerShell terminal

$ErrorActionPreference = "Stop"

# --- 1. Define Variables ---
$DotfilesDir = Resolve-Path "$PSScriptRoot\.."
$SharedVimrc = "$DotfilesDir\shared\.vimrc"
$AwsConfigJson = "$DotfilesDir\macos\aws-config.json"
$UserProfile = $env:USERPROFILE

Write-Host "🪟 Starting Windows Setup..." -ForegroundColor Cyan

# --- 2. Check & Install Winget ---
# Windows 11 usually has Winget pre-installed.
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warning "Winget not found! Please install App Installer from the Microsoft Store."
    # Attempting to continue, but likely will fail on package installs
} else {
    Write-Host "✅ Winget is available." -ForegroundColor Green
}

# --- 3. Install Packages via Winget ---
$Packages = @(
    "Git.Git",
    "Python.Python.3",
    "Amazon.AWSCLI",
    "jqlang.jq",
    "WarpTerminal.Warp",
    "Notion.Notion",
    "Obsidian.Obsidian",
    "Discord.Discord"
    # "Microsoft.PowerToys" # Optional but recommended
)

Write-Host "📦 Installing packages..." -ForegroundColor Cyan
foreach ($Pkg in $Packages) {
    Write-Host "Installing $Pkg..."
    try {
        winget install --id $Pkg --source winget --accept-package-agreements --accept-source-agreements --silent
    } catch {
        Write-Warning "Failed to install $Pkg or it is already installed."
    }
}

# --- 4. PowerShell Profile Setup ---
$ProfilePath = $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $ProfilePath)) {
    New-Item -Type File -Path $ProfilePath -Force | Out-Null
    Write-Host "📄 Created PowerShell profile at $ProfilePath" -ForegroundColor Green
}

$ProfileContent = @"
# Custom Prompt
function prompt {
    Write-Host "[$env:USERNAME" -NoNewline -ForegroundColor Cyan
    Write-Host "@" -NoNewline -ForegroundColor Gray
    Write-Host "$env:COMPUTERNAME] " -NoNewline -ForegroundColor Cyan
    Write-Host (Get-Location) -ForegroundColor Yellow
    return "> "
}

# Aliases
Set-Alias ll Get-ChildItem
Set-Alias g git
Set-Alias vim code # Or actual vim if installed
"@

Add-Content -Path $ProfilePath -Value $ProfileContent
Write-Host "✅ PowerShell profile updated." -ForegroundColor Green

# --- 5. Dotfiles (Symlink .vimrc) ---
Write-Host "🔗 Linking .vimrc..." -ForegroundColor Cyan
$DestVimrc = "$UserProfile\_vimrc"

# Try removing existing file/link first
if (Test-Path $DestVimrc) {
    Remove-Item $DestVimrc -Force
}

try {
    # Requires Admin or Developer Mode for Symlinks
    New-Item -ItemType SymbolicLink -Path $DestVimrc -Target $SharedVimrc | Out-Null
    Write-Host "✅ Symlinked .vimrc" -ForegroundColor Green
} catch {
    Write-Warning "Symlink failed (needs Admin or Developer Mode). Copying instead."
    Copy-Item $SharedVimrc $DestVimrc -Force
    Write-Host "✅ Copied .vimrc" -ForegroundColor Green
}

# --- 6. AWS CLI Configuration ---
if (Test-Path $AwsConfigJson) {
    Write-Host "☁️  Configuring AWS CLI..." -ForegroundColor Cyan
    
    try {
        $JsonContent = Get-Content $AwsConfigJson | ConvertFrom-Json
        
        $AwsKey = $JsonContent.aws_access_key_id
        $AwsSecret = $JsonContent.aws_secret_access_key
        $AwsRegion = $JsonContent.default_region
        $AwsOutput = $JsonContent.default_output

        if ($AwsKey -and $AwsSecret) {
            & aws configure set aws_access_key_id "$AwsKey"
            & aws configure set aws_secret_access_key "$AwsSecret"
        }
        if ($AwsRegion) { & aws configure set default.region "$AwsRegion" }
        if ($AwsOutput) { & aws configure set default.output "$AwsOutput" }
        
        Write-Host "✅ AWS CLI configured." -ForegroundColor Green
    } catch {
        Write-Error "Failed to parse AWS config JSON or configure AWS CLI."
    }
} else {
    Write-Warning "AWS Config JSON not found at $AwsConfigJson"
}

# --- 7. Fonts ---
Write-Host "🅰️  Installing Fonts..." -ForegroundColor Cyan
$FontsDir = "$DotfilesDir\shared\fonts"
if (Test-Path $FontsDir) {
    $DestFonts = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    # Ensure Windows user fonts dir exists (sometimes needs creation)
    if (-not (Test-Path $DestFonts)) {
        New-Item -ItemType Directory -Force -Path $DestFonts | Out-Null
    }
    
    Get-ChildItem -Path $FontsDir -Filter "*.ttf" | ForEach-Object {
        $FontFile = $_.FullName
        $FontName = $_.Name
        try {
            Copy-Item $FontFile -Destination $DestFonts -Force
            # Note: Registering fonts in registry is usually needed for them to be picked up immediately by all apps without manual install
            # But simple copy often works for some apps. A full registry script is complex. 
            # We will stick to copy for now and advise user to 'Install' if needed.
            Write-Host "  Copied $FontName"
        } catch {
            Write-Warning "  Failed to copy $FontName"
        }
    }
    Write-Host "✅ Fonts copied to $DestFonts" -ForegroundColor Green
    Write-Warning "Note: You may need to manually right-click > 'Install' on font files if they don't appear."
} else {
    Write-Warning "Fonts directory not found at $FontsDir"
}

Write-Host "🎉 Windows Setup Complete! Please restart your terminal." -ForegroundColor Magenta
