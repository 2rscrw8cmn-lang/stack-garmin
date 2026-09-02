$ErrorActionPreference = "Stop"

$root = Join-Path $PSScriptRoot "..\.reference-repos"
New-Item -ItemType Directory -Force -Path $root | Out-Null

$repos = @(
    @{ Name = "garmin-connectiq-apps"; Url = "https://github.com/garmin/connectiq-apps.git" },
    @{ Name = "wintertime-watchface"; Url = "https://github.com/chrisdfennell/WinterTime-Watchface.git" },
    @{ Name = "tactical-grid-reference-only"; Url = "https://github.com/ilkerender/ilker-garmin-watchface.git" },
    @{ Name = "burndown-reference-only"; Url = "https://github.com/digitalhen/burndown-garmin-watchface.git" },
    @{ Name = "gregor-watchface-reference-only"; Url = "https://github.com/gregor-srdic/garmin-watchface.git" },
    @{ Name = "crystal-face-gpl-reference"; Url = "https://github.com/warmsound/crystal-face.git" }
)

foreach ($repo in $repos) {
    $dest = Join-Path $root $repo.Name
    if (Test-Path $dest) {
        Write-Host "Exists: $($repo.Name)"
        continue
    }
    Write-Host "Cloning $($repo.Name)..."
    git clone --depth 1 $repo.Url $dest
}

Write-Host "Reference repositories are in $root"
Write-Host "See docs/REFERENCE_REPOS.md before copying any code."
