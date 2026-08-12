$day = Read-Host "Day"
$title = Read-Host "Main topic"
$subtitle = Read-Host "Sub topic"

$path = "posts/day$day $title-$subtitle/index.md"

hugo new $path
