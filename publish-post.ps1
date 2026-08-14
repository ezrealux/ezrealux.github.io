$titles = @()

Get-ChildItem -Path .\content -Recurse -File -Include *.md,*.markdown |
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw

        if ($content -match '(?im)^\s*draft\s*:\s*false\s*$') {
            if ($content -match '(?m)^\s*title\s*:\s*["'']?(.*?)["'']?\s*$') {
                $titles += $matches[1].Trim()
            }
        }
    }


$date = ($titles | ForEach-Object {
    ($_ -split '\s+')[0]
}) -join ' '
$date = "b"
git add .

$date += Read-Host "Commit message"

git commit -m "$date"
git push