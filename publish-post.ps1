git add .

$message = Read-Host "Commit message"

git commit -m "$message"
git push