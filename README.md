Windows Explorer Context Menu
=============================

Modifies the Windows registry to add options to the explorer context menues.

Disable the package before uninstalling. There is currently no indication that a package is about to be uninstalled. You can also uninstall using the included `uninstall.reg` [here](https://github.com/Zren/atom-windows-context-menu/blob/master/assets/uninstall.reg).

![File Context Menu](http://i.imgur.com/3iRCt7m.png)

![Directory Background Context Menu](http://i.imgur.com/9v0UZKo.png)

Troubleshooting
------------
##### The context menú doesn't show.
You have to enable the context menu settings in System. Here are the steps:

Open File > Settings.
Click on the System tab.
Enable check mark: Show in folder context menus

Alternatives
------------

Installing through registry files:

Use either of these as a template.

* For `C:\Atom\atom.exe`: https://gist.github.com/kyle-ilantzis/c5a30fbabe8923130581
* For `C:\Chocolatey\lib\Atom.0.115.0\tools\Atom\atom.exe`: https://github.com/Zren/atom-windows-context-menu/blob/master/assets/install_template.reg

Installing through powershell:

* For Chocolatey installs: Download [this project](https://github.com/Zren/atom-windows-context-menu/archive/master.zip) and run `assets/install_chocolatey.ps1`.
