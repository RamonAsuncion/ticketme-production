#Install nmake
#Requires -RunAsAdministrator
Write-Host "Downloading VS Build Tools installer..."
$exeUrl = "https://aka.ms/vs/17/release/vs_BuildTools.exe"
$exePath = "$env:TEMP\vs_BuildTools.exe"
Write-Host "Download complete."
Write-Host "Installing VS Build Tools with WIN SDK..."
Invoke-WebRequest $exeUrl -OutFile $exePath
Start-Process -FilePath $exePath -ArgumentList @("--passive", "--wait", "--norestart", "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64", "--add", "Microsoft.VisualStudio.Component.WindowsAppSDK") -NoNewWindow -Wait
Write-Host "Installation complete."
Write-Host "Setup VS env variables..."
# A new error and told to add this: cmd /K "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
$vsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build"
& "$vsPath\vcvarsall.bat" amd64
Write-Host "Env variables set."
Write-Host "Setting up system-wide PATH..."
# $nmakePath = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.36.32532\bin\Hostx64\x64"
$nmakePath = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.36.32532\bin\Hostx64\x64"
[System.Environment]::SetEnvironmentVariable("Path", $Env:Path + ";$nmakePath", [System.EnvironmentVariableTarget]::Machine)
$env:Path += ";$nmakePath"
Write-Host "Added nmake to path."
nmake /?

# References:
# If you're running where all these commands came from I used the following sources.
# 1. https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-7.5
# 2. https://stackoverflow.com/questions/51225598/downloading-a-file-with-powershell
# 3. https://learn.microsoft.com/en-us/cpp/build/reference/nmake-reference?view=msvc-170
# 4. https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022
# 5. https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.5
# 6. https://serverfault.com/questions/95431/in-a-powershell-script-how-can-i-check-if-im-running-with-administrator-privil
# 7. https://superuser.com/questions/1729958/how-do-i-permanently-set-a-system-variable-system-environmentsetenvironment