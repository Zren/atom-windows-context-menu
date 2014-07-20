function Install-ExplorerMenuItem {
<#
.SYNOPSIS
Creates a windows explorer context menu items that launch Atom

.DESCRIPTION
Improves upon Install-ChocolateyExplorerMenuItem. Also assigns an icon and adds
menu items when clicking the background of a folder.

Because this command accesses and edits the root class registry node, it will be
elevated to admin.

.PARAMETER MenuKey
A unique string to identify this menu item in the registry. The order of this
item in the menu is determined by this key.

.PARAMETER MenuLabel
The string that will be displayed in the context menu

.PARAMETER Command
A command line command that will be invoked when the menu item is selected

.PARAMETER Icon
The path to an icon. Optionally followed by a command and an index.

.PARAMETER Type
Specifies if the menu item should be applied to a folder or a file

.EXAMPLE
C:\PS>$atomDir = (Get-ChildItem $env:ALLUSERSPROFILE\chocolatey\lib\atom* | select $_.last)
C:\PS>$atomExe = "$atomDir\tools\Atom\atom.exe"
C:\PS>$atomIcon = $atomExe
C:\PS>Install-ExplorerMenuItem "Open File in Atom" "Open File in Atom" $atomExe $atomIcon

This will create a context menu item in Windows Explorer when any file is right clicked. The menu item will appear with the text "Open File in Atom" and will invoke atom when selected.

.EXAMPLE
C:\PS>$atomDir = (Get-ChildItem $env:ALLUSERSPROFILE\chocolatey\lib\atom* | select $_.last)
C:\PS>$atomExe = "$atomDir\tools\Atom\atom.exe"
C:\PS>$atomIcon = $atomExe
C:\PS>Install-ExplorerMenuItem "Open Folder in Atom" "Open Folder in Atom" $atomExe $atomIcon "directory"

This will create a context menu item in Windows Explorer when any folder is right clicked. The menu item will appear with the text "Open File in Atom" and will invoke atom when selected.

.NOTES
Chocolatey will automatically add the path of the file or folder clicked to the command. This is done simply by appending a %1 (or %V for directory backgrounds) to the end of the command.
#>
param(
  [string]$menuKey,
  [string]$menuLabel,
  [string]$command,
  [string]$icon,
  [ValidateSet('file','directory')]
  [string]$type = "file"
)
  try {
    Write-Debug "Running 'Install-ChocolateyExplorerMenuItem' with menuKey:'$menuKey', menuLabel:'$menuLabel', command:'$command', icon:'$icon', type '$type'"

    $elevated = ""

    # Map HKCR:\
    $elevated += "if(!(Test-Path -path HKCR:) ) {New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root};"

    if ($type -eq "file") {
      # * => Open File
      $registryKeyPath = 'HKCR:\*\shell'
      $elevated += @"
        if(!(Test-Path -LiteralPath '$registryKeyPath\$menuKey')) { New-Item -Path '$registryKeyPath\$menuKey' };
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name '(Default)'  -Value '$menuLabel';
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name 'Icon'  -Value '$icon';
        if(!(Test-Path -LiteralPath '$registryKeyPath\$menuKey\command')) { New-Item -Path '$registryKeyPath\$menuKey\command' };
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name '(Default)'  -Value '$command \`"%1\`"';
"@
    } elseif ($type -eq "directory") {
      # Directory Selected => Open Folder
      $registryKeyPath = 'HKCR:\Directory\shell'
      $elevated += @"
        if(!(Test-Path -LiteralPath '$registryKeyPath\$menuKey')) { New-Item -Path '$registryKeyPath\$menuKey' };
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name '(Default)'  -Value '$menuLabel';
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name 'Icon'  -Value '$icon';
        if(!(Test-Path -LiteralPath '$registryKeyPath\$menuKey\command')) { New-Item -Path '$registryKeyPath\$menuKey\command' };
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name '(Default)'  -Value '$command \`"%1\`"';
"@

      # Directory Background Selected: Open Folder
      $registryKeyPath = 'HKCR:\Directory\Background\shell'
      $elevated += @"
        if(!(Test-Path -LiteralPath '$registryKeyPath\$menuKey')) { New-Item -Path '$registryKeyPath\$menuKey' };
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name '(Default)'  -Value '$menuLabel';
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name 'Icon'  -Value '$icon';
        if(!(Test-Path -LiteralPath '$registryKeyPath\$menuKey\command')) { New-Item -Path '$registryKeyPath\$menuKey\command' };
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name '(Default)'  -Value '$command \`"%1\`"';
"@

      # Directory Background Selected (Within Library): Open Folder
      $registryKeyPath = 'HKCR:\LibraryFolder\Background\shell'
      $elevated += @"
        if(!(Test-Path -LiteralPath '$registryKeyPath\$menuKey')) { New-Item -Path '$registryKeyPath\$menuKey' };
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name '(Default)'  -Value '$menuLabel';
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name 'Icon'  -Value '$icon';
        if(!(Test-Path -LiteralPath '$registryKeyPath\$menuKey\command')) { New-Item -Path '$registryKeyPath\$menuKey\command' };
        Set-ItemProperty -LiteralPath '$registryKeyPath\$menuKey' -Name '(Default)'  -Value '$command \`"%1\`"';
"@
    } else {
      return 1
    }

    $elevated += "return 0;"

    Start-ChocolateyProcessAsAdmin $elevated
    Write-Host "'$menuKey' explorer menu items have been created"
  } catch {
    $errorMessage = "'$menuKey' explorer menu items was not created $($_.Exception.Message)"
    Write-Error $errorMessage
    throw $errorMessage
  }
}
