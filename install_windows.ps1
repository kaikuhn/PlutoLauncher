# Pfade definieren
$scriptName = "pluto_launcher.jl"
$installDir = "$HOME\.pluto_app"
$targetPath = "$installDir\$scriptName"

# Ordner erstellen und Skript kopieren
if (!(Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir }
Copy-Item $scriptName $targetPath

# Verknüpfung auf dem Desktop erstellen
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$HOME\Desktop\Pluto Notebooks.lnk")
$Shortcut.TargetPath = "julia.exe"
$Shortcut.Arguments = "--startup-file=no `"$targetPath`""
# Versucht das Julia Icon zu finden
$Shortcut.IconLocation = "julia.exe, 0" 
$Shortcut.Save()

Write-Host "Installation abgeschlossen! Ein Icon wurde auf deinem Desktop erstellt." -ForegroundColor Green