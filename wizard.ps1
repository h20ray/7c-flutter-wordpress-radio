<#
.SYNOPSIS
    Flutter App Configuration Wizard
    Changes App Name, Package Name, and Version Number.

.DESCRIPTION
    This script provides an interactive menu to modify:
    1. App Display Name (Android Label & iOS Bundle Display Name)
    2. Package Name (Android Application ID & iOS Bundle Identifier) using 'change_app_package_name'
    3. Version Number (pubspec.yaml)

.NOTES
    File Name      : wizard.ps1
    Prerequisites  : Flutter SDK, change_app_package_name (dev_dependency)
#>

$ErrorActionPreference = "Stop"

# --- Configuration Paths ---
$ProjectRoot = $PSScriptRoot
$PubspecPath = Join-Path $ProjectRoot "pubspec.yaml"
$AndroidManifestPath = Join-Path $ProjectRoot "android\app\src\main\AndroidManifest.xml"
$IosInfoPlistPath = Join-Path $ProjectRoot "ios\Runner\Info.plist"

# --- Helper Functions ---

function Show-Header {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "      Flutter App Configuration Wizard    " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Wait-Key {
    Write-Host ""
    Write-Host "Press any key to continue..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Get-CurrentVersion {
    if (Test-Path $PubspecPath) {
        $content = Get-Content $PubspecPath -Raw
        if ($content -match 'version:\s+([^\s]+)') {
            return $matches[1]
        }
    }
    return "Unknown"
}

function Get-CurrentAppName {
    # Try to get from Android Manifest
    if (Test-Path $AndroidManifestPath) {
        $content = Get-Content $AndroidManifestPath -Raw
        if ($content -match 'android:label="([^"]*)"') {
            return $matches[1]
        }
    }
    return "Unknown"
}

function Get-CurrentPackageName {
    # Try to get from build.gradle (simple check)
    $gradlePath = Join-Path $ProjectRoot "android\app\build.gradle"
    if (Test-Path $gradlePath) {
        $content = Get-Content $gradlePath -Raw
        if ($content -match 'applicationId\s+"([^"]*)"') {
            return $matches[1]
        }
    }
    return "Unknown"
}

# --- Action Functions ---

function Update-AppName {
    Show-Header
    $current = Get-CurrentAppName
    Write-Host "Current Display Name: " -NoNewline
    Write-Host $current -ForegroundColor Yellow
    Write-Host ""

    $newName = Read-Host "Enter New Display Name"
    if ([string]::IsNullOrWhiteSpace($newName)) {
        Write-Host "Cancelled." -ForegroundColor Red
        Wait-Key
        return
    }

    Write-Host ""
    Write-Host "This will update:" -ForegroundColor Gray
    Write-Host " - AndroidManifest.xml (android:label)" -ForegroundColor Gray
    Write-Host " - Info.plist (CFBundleDisplayName)" -ForegroundColor Gray
    
    $confirm = Read-Host "Are you sure? (y/n)"
    if ($confirm -ne 'y') { return }

    try {
        # Update AndroidManifest.xml
        if (Test-Path $AndroidManifestPath) {
            $content = Get-Content $AndroidManifestPath -Raw
            $newContent = $content -replace 'android:label="([^"]*)"', "android:label=""$newName"""
            Set-Content -Path $AndroidManifestPath -Value $newContent -Encoding UTF8
            Write-Host "[OK] Updated AndroidManifest.xml" -ForegroundColor Green
        }
        else {
            Write-Host "[SKIP] AndroidManifest.xml not found" -ForegroundColor Yellow
        }

        # Update Info.plist
        if (Test-Path $IosInfoPlistPath) {
            $content = Get-Content $IosInfoPlistPath -Raw
            # Regex to find CFBundleDisplayName and replace the string in the next line
            # This is a bit fragile with regex, but standard plist format usually works.
            # Pattern: <key>CFBundleDisplayName</key>\s*<string>OLD_NAME</string>
            
            # We use a detailed regex to capture the content between tags
            $pattern = '(<key>CFBundleDisplayName<\/key>\s*<string>)([^<]*)(<\/string>)'
            if ($content -match $pattern) {
                $newContent = $content -replace $pattern, "${1}$newName${3}"
                Set-Content -Path $IosInfoPlistPath -Value $newContent -Encoding UTF8
                Write-Host "[OK] Updated Info.plist" -ForegroundColor Green
            }
            else {
                Write-Host "[WARN] CFBundleDisplayName not found in Info.plist" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "[SKIP] Info.plist not found" -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "App Name changed successfully to '$newName'!" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    Wait-Key
}

function Update-PackageName {
    Show-Header
    $current = Get-CurrentPackageName
    Write-Host "Current Package Name: " -NoNewline
    Write-Host $current -ForegroundColor Yellow
    Write-Host ""
    Write-Host "NOTE: This uses the 'change_app_package_name' package." -ForegroundColor Gray
    Write-Host ""

    $newPackage = Read-Host "Enter New Package Name (e.g. com.company.app)"
    if ([string]::IsNullOrWhiteSpace($newPackage)) {
        Write-Host "Cancelled." -ForegroundColor Red
        Wait-Key
        return
    }

    # Basic validation
    if ($newPackage -notmatch '^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$') {
        Write-Host "Invalid package name format. Use lowercase, dots, no spaces (e.g. com.example.app)" -ForegroundColor Red
        Wait-Key
        return
    }

    $confirm = Read-Host "Run 'flutter pub run change_app_package_name:main $newPackage'? (y/n)"
    if ($confirm -ne 'y') { return }

    try {
        Write-Host "Running command..." -ForegroundColor Cyan
        cmd /c "flutter pub run change_app_package_name:main $newPackage"
        
        # --- Post-Processing: Consolidate Custom Files ---
        Write-Host ""
        Write-Host "Consolidating files..." -ForegroundColor Cyan
        
        $kotlinRoot = Join-Path $ProjectRoot "android\app\src\main\kotlin"
        $newPath = Join-Path $kotlinRoot ($newPackage -replace '\.', '\')

        # Ensure new path exists
        if (-not (Test-Path $newPath)) {
            New-Item -ItemType Directory -Path $newPath -Force | Out-Null
        }

        # Find ALL Kotlin files in the kotlin root, recursively
        $allKotlinFiles = Get-ChildItem -Path $kotlinRoot -Filter "*.kt" -Recurse -File

        foreach ($file in $allKotlinFiles) {
            # Skip if already in the correct folder
            if ($file.DirectoryName -eq $newPath) {
                continue
            }

            $fileName = $file.Name
            Write-Host "Found stranded file: $fileName" -ForegroundColor Yellow
            
            $destination = Join-Path $newPath $fileName
            
            # Move the file
            Move-Item -Path $file.FullName -Destination $destination -Force
            Write-Host "  Moved to new package structure." -ForegroundColor Gray

            # Update package declaration
            try {
                $content = Get-Content $destination -Raw
                # Regex to replace ANY package declaration with the new one
                if ($content -match "package\s+[\w\.]+") {
                    $newContent = $content -replace "package\s+[\w\.]+", "package $newPackage"
                    Set-Content -Path $destination -Value $newContent -Encoding UTF8
                    Write-Host "  Updated package declaration." -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "  [WARN] Failed to update content of $fileName" -ForegroundColor Red
            }
        }
        
        # Cleanup empty directories
        # We iterate all directories under kotlin root and delete empty ones
        # We do this a few times to handle nested empty folders
        for ($i = 0; $i -lt 5; $i++) {
            Get-ChildItem -Path $kotlinRoot -Recurse -Directory | Sort-Object FullName -Descending | ForEach-Object {
                if ((Get-ChildItem -Path $_.FullName).Count -eq 0) {
                    Remove-Item -Path $_.FullName -Force
                    Write-Host "Cleaned up empty directory: $($_.FullName)" -ForegroundColor Gray
                }
            }
        }

        Write-Host ""
        Write-Host "Command finished." -ForegroundColor Green
        Write-Host "Please verify the changes in your project." -ForegroundColor Yellow
    }
    catch {
        Write-Host "Error executing command: $_" -ForegroundColor Red
    }
    Wait-Key
}

function Update-Version {
    Show-Header
    $current = Get-CurrentVersion
    Write-Host "Current Version: " -NoNewline
    Write-Host $current -ForegroundColor Yellow
    Write-Host ""

    $newVersion = Read-Host "Enter New Version (e.g. 1.0.0+1)"
    if ([string]::IsNullOrWhiteSpace($newVersion)) {
        Write-Host "Cancelled." -ForegroundColor Red
        Wait-Key
        return
    }

    # Basic validation
    if ($newVersion -notmatch '^\d+\.\d+\.\d+(\+\d+)?$') {
        Write-Host "Invalid version format. Use x.y.z or x.y.z+n" -ForegroundColor Red
        Wait-Key
        return
    }

    $confirm = Read-Host "Update pubspec.yaml to '$newVersion'? (y/n)"
    if ($confirm -ne 'y') { return }

    try {
        if (Test-Path $PubspecPath) {
            $content = Get-Content $PubspecPath -Raw
            $newContent = $content -replace 'version:\s+[^\s]+', "version: $newVersion"
            Set-Content -Path $PubspecPath -Value $newContent -Encoding UTF8
            Write-Host "[OK] Updated pubspec.yaml" -ForegroundColor Green
            
            Write-Host "Running 'flutter pub get' to propagate changes..." -ForegroundColor Cyan
            cmd /c "flutter pub get"
            Write-Host "[OK] Done" -ForegroundColor Green
        }
        else {
            Write-Host "pubspec.yaml not found!" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    Wait-Key
}

# --- Main Loop ---

while ($true) {
    Show-Header
    
    # --- Dashboard: Current Values ---
    Write-Host "Current Configuration:" -ForegroundColor Green
    
    $currName = Get-CurrentAppName
    Write-Host "  App Name     : " -NoNewline
    Write-Host $currName -ForegroundColor White

    $currPkg = Get-CurrentPackageName
    Write-Host "  Package Name : " -NoNewline
    Write-Host $currPkg -ForegroundColor White

    $currVer = Get-CurrentVersion
    Write-Host "  Version      : " -NoNewline
    Write-Host $currVer -ForegroundColor White
    
    Write-Host ""
    Write-Host "------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "1. Change App Display Name"
    Write-Host "2. Change Package Name (Bundle ID)"
    Write-Host "3. Change Version Number"
    Write-Host "4. Exit"
    Write-Host ""
    
    $choice = Read-Host "Select an option [1-4]"
    
    switch ($choice) {
        '1' { Update-AppName }
        '2' { Update-PackageName }
        '3' { Update-Version }
        '4' { Clear-Host; exit }
        default { 
            Write-Host "Invalid selection." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
