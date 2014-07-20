#$chocolateyDir = $env:ALLUSERSPROFILE
$chocolateyDir = 'c:\chocolatey'

. .\Install-ExplorerMenuItem.ps1
. $chocolateyDir\chocolateyinstall\helpers\functions\Start-ChocolateyProcessAsAdmin.ps1

# Remove the old menu item
# Moving it from \Atom to \Open File in Atom (as this is what controls the order in the context menu).
try {
  $elevated = ""
  $elevated += "if(Test-Path -LiteralPath 'HKCR:\*\shell\Atom') { Remove-Item -LiteralPath 'HKCR:\*\shell\Atom' -Recurse };"
  $elevated += "return 0;"
  Start-ChocolateyProcessAsAdmin $elevated
  Write-Host "'HKCR:\*\shell\Atom' was deleted"
} catch {
  $errorMessage = "Unable to delete 'HKCR:\*\shell\Atom' registry item $($_.Exception.Message)"
  Write-Error $errorMessage
  throw $errorMessage
}


$atomDir = (Get-ChildItem $chocolateyDir\lib\atom* | select $_.last)
$atomExe = "$atomDir\tools\Atom\atom.exe"
$atomIcon = $atomExe
Install-ExplorerMenuItem "Open File in Atom" "Open File in Atom" $atomExe $atomIcon
Install-ExplorerMenuItem "Open Folder in Atom" "Open Folder in Atom" $atomExe $atomIcon "directory"
