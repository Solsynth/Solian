$pubCache = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev"
$projectDir = Split-Path -Parent $PSScriptRoot

Write-Host "=== Android Gradle Patch Script ==="
Write-Host ""

# 1. Stop Gradle daemon to avoid "File modified during build" errors
Write-Host "[1/4] Stopping Gradle daemon..."
$gradlew = Join-Path $projectDir "android\gradlew.bat"
if (Test-Path $gradlew) {
    $env:JAVA_TOOL_OPTIONS = "-Djavax.net.ssl.trustStore=$env:USERPROFILE\.cacerts -Djavax.net.ssl.trustStorePassword=changeit"
    $stopOutput = & $gradlew --stop 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Host "  (no daemon running or stop failed)" }
    Start-Sleep -Seconds 2
}
Write-Host "  Done."
Write-Host ""

# 2. Patch compileSdk in pub cache
Write-Host "[2/4] Patching Flutter plugin compileSdk versions to 36..."

# Groovy DSL
Get-ChildItem -Path $pubCache -Recurse -Filter "*.gradle" | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    $modified = $false

    # compileSdkVersion NN -> compileSdkVersion 36
    if ($content -match 'compileSdkVersion\s+\d+') {
        $content = $content -replace 'compileSdkVersion\s+\d+', 'compileSdkVersion 36'
        $modified = $true
    }

    # compileSdk = NN or compileSdk: NN -> compileSdk = 36
    if ($content -match 'compileSdk\s+[=:]\s*\d+') {
        $content = $content -replace 'compileSdk\s+[=:]\s*\d+', 'compileSdk = 36'
        $modified = $true
    }

    if ($modified) {
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "  Patched: $($_.FullName)"
    }
}

# Kotlin DSL
Get-ChildItem -Path $pubCache -Recurse -Filter "*.gradle.kts" | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    $modified = $false

    # compileSdk = NN -> compileSdk = 36
    if ($content -match 'compileSdk\s*=\s*\d+') {
        $content = $content -replace 'compileSdk\s*=\s*\d+', 'compileSdk = 36'
        $modified = $true
    }

    # compileSdkVersion(NN) -> compileSdkVersion(36)
    if ($content -match 'compileSdkVersion\(\s*\d+\s*\)') {
        $content = $content -replace 'compileSdkVersion\(\s*\d+\s*\)', 'compileSdkVersion(36)'
        $modified = $true
    }

    if ($modified) {
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "  Patched: $($_.FullName)"
    }
}

# 3. Patch media_kit download URLs to use ghproxy mirror
Write-Host "[3/4] Patching media_kit download URLs (ghproxy mirror)..."
$mediaKitDirs = Get-ChildItem -Path $pubCache -Directory -Filter "media_kit_libs_android_video-*" -ErrorAction SilentlyContinue
$mirrorPatched = $false
foreach ($dir in $mediaKitDirs) {
    $gradleFile = Join-Path $dir.FullName "android\build.gradle"
    if (Test-Path $gradleFile) {
        $content = Get-Content -Path $gradleFile -Raw
        if ($content -match 'https://github\.com/media-kit') {
            $content = $content -replace 'https://github\.com/media-kit', 'https://ghproxy.net/https://github.com/media-kit'
            Set-Content -Path $gradleFile -Value $content -NoNewline
            Write-Host "  Patched: $gradleFile"
            $mirrorPatched = $true
        }
    }
}
if (-not $mirrorPatched) { Write-Host "  No media_kit files to patch (already fixed)." }

# 4. Fix missing MaterialSymbolsRounded.ttf in material_symbols_icons
Write-Host "[4/4] Fixing missing MaterialSymbolsRounded.ttf..."
$iconsPkg = Join-Path $pubCache "material_symbols_icons-*"
$iconsDirs = Get-ChildItem -Path $iconsPkg -Directory -ErrorAction SilentlyContinue
$fontFixed = $false
foreach ($dir in $iconsDirs) {
    $libFont = Join-Path $dir.FullName "lib\fonts"
    $rawDir  = Join-Path $dir.FullName "rawFontsUnfixed"
    $target  = Join-Path $libFont "MaterialSymbolsRounded.ttf"
    if ((Test-Path $libFont) -and (Test-Path $rawDir) -and -not (Test-Path $target)) {
        $src = Get-ChildItem -LiteralPath $rawDir -Filter "MaterialSymbolsRounded*.ttf" | Select-Object -First 1
        if ($src) {
            Copy-Item -LiteralPath $src.FullName -Destination $target
            Write-Host "  Copied: $($src.Name) -> $target ($($src.Length) bytes)"
            $fontFixed = $true
        }
    }
}
if (-not $fontFixed) { Write-Host "  No missing font found (already fixed)." }

Write-Host ""
Write-Host "=== All patches applied. Ready to build ==="
