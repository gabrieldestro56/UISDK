param(
	[string]$Repository = "gabrieldestro56/UISDK",
	[string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$srcRoot = Join-Path $repoRoot "src"
$installerPath = Join-Path $repoRoot "install.lua"

if (-not (Test-Path -LiteralPath $srcRoot -PathType Container)) {
	throw "Missing source directory: $srcRoot"
}

if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
	throw "Missing installer: $installerPath"
}

$srcRootPath = (Resolve-Path -LiteralPath $srcRoot).Path.TrimEnd("\", "/")
$files = Get-ChildItem -LiteralPath $srcRootPath -Filter "*.lua" -File -Recurse | Sort-Object FullName

$entries = foreach ($file in $files) {
	$relative = $file.FullName.Substring($srcRootPath.Length + 1).Replace("\", "/")
	$group = ($relative -split "/")[0]
	$modulePath = "UISDK/" + ($relative -replace "\.lua$", "")

	[pscustomobject]@{
		Group = $group
		UrlPath = "src/$relative"
		InstallPath = $modulePath
	}
}

$groupPriority = @{
	Primitives = 0
	Components = 1
}

$groups = $entries | Group-Object Group | Sort-Object @{
	Expression = {
		if ($groupPriority.ContainsKey($_.Name)) {
			$groupPriority[$_.Name]
		} else {
			100
		}
	}
}, Name

$lines = New-Object "System.Collections.Generic.List[string]"
[void]$lines.Add("local dependencies = {")

foreach ($group in $groups) {
	[void]$lines.Add("`t-- $($group.Name)")

	foreach ($entry in ($group.Group | Sort-Object UrlPath)) {
		[void]$lines.Add("`t{")
		[void]$lines.Add("`t`turl = `"https://raw.githubusercontent.com/$Repository/refs/heads/$Branch/$($entry.UrlPath)`",")
		[void]$lines.Add("`t`tpath = `"$($entry.InstallPath)`",")
		[void]$lines.Add("`t},")
	}

	[void]$lines.Add("")
}

if ($lines.Count -gt 1) {
	$lastIndex = $lines.Count - 1
	if ($lines[$lastIndex] -eq "") {
		$lines.RemoveAt($lastIndex)
	}
}

[void]$lines.Add("}")

$lineBreak = [Environment]::NewLine
$replacement = ($lines -join $lineBreak) + $lineBreak + $lineBreak
$content = [System.IO.File]::ReadAllText($installerPath)
$pattern = "(?s)\Alocal dependencies = \{.*?\}\r?\n\r?\n"

if ($content -notmatch $pattern) {
	throw "Could not find the top-level dependencies table in $installerPath"
}

$regex = New-Object System.Text.RegularExpressions.Regex($pattern)
$content = $regex.Replace($content, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement }, 1)

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($installerPath, $content, $utf8NoBom)

Write-Host "Updated install.lua with $($entries.Count) dependencies."
