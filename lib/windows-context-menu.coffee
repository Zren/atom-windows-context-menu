# WinReg = require 'winreg' # Current build doesn't support setting an empty name. Aka: (Default).
WinReg = require './registry' # So use our fork.
process = require 'process'

module.exports =
  launchPath: process.argv[0]
  openFileContextMenuText: 'Open File in Atom'
  openFolderContextMenuText: 'Open Folder in Atom'

  regKeyCallback: (error) ->
    if error
      console.log(error)

  lastLaunchPath: () ->
    atom.config.get('windows-context-menu.lastLaunchPath', '')

  launchPathHasChanged: () ->
    return @launchPath != @lastLaunchPath()

  applyRegKey: (hive, key, name, value) ->
    regKey = new WinReg({
      hive: hive
      key: key
    })
    regKey.set(name, WinReg.REG_SZ, value, @regKeyCallback)

  deleteRegKey: (hive, key) ->
    regKey = new WinReg({
      hive: hive
      key: key
    })
    regKey.delete(@regKeyCallback)

  installOpenFileContextMenu: () ->
    # * => Open File
    @applyRegKey(WinReg.HKCR, '\\*\\shell\\' + @openFileContextMenuText, '', @openFileContextMenuText)
    @applyRegKey(WinReg.HKCR, '\\*\\shell\\' + @openFileContextMenuText, 'Icon', @launchPath)
    @applyRegKey(WinReg.HKCR, '\\*\\shell\\' + @openFileContextMenuText + '\\command', '', @launchPath + ' "%1"')

  uninstallOpenFileContextMenu: () ->
    @deleteRegKey(WinReg.HKCR, '\\*\\shell\\' + @openFileContextMenuText)


  installOpenFolderContextMenu: () ->
    # Directory Selected => Open Folder
    @applyRegKey(WinReg.HKCR, '\\Directory\\shell\\' + @openFolderContextMenuText, '', @openFolderContextMenuText)
    @applyRegKey(WinReg.HKCR, '\\Directory\\shell\\' + @openFolderContextMenuText, 'Icon', @launchPath)
    @applyRegKey(WinReg.HKCR, '\\Directory\\shell\\' + @openFolderContextMenuText + '\\command', '', @launchPath + ' "%1"')

    # Directory Background Selected: Open Folder
    @applyRegKey(WinReg.HKCR, '\\Directory\\Background\\shell\\' + @openFolderContextMenuText, '', @openFolderContextMenuText)
    @applyRegKey(WinReg.HKCR, '\\Directory\\Background\\shell\\' + @openFolderContextMenuText, 'Icon', @launchPath)
    @applyRegKey(WinReg.HKCR, '\\Directory\\Background\\shell\\' + @openFolderContextMenuText + '\\command', '', @launchPath + ' "%V"')

    # Directory Background Selected (Within Library): Open Folder
    @applyRegKey(WinReg.HKCR, '\\LibraryFolder\\Background\\shell\\' + @openFolderContextMenuText, '', @openFolderContextMenuText)
    @applyRegKey(WinReg.HKCR, '\\LibraryFolder\\Background\\shell\\' + @openFolderContextMenuText, 'Icon', @launchPath)
    @applyRegKey(WinReg.HKCR, '\\LibraryFolder\\Background\\shell\\' + @openFolderContextMenuText + '\\command', '', @launchPath + ' "%V"')


  uninstallOpenFolderContextMenu: () ->
    # @deleteRegKey(WinReg.HKCR, '\\LibraryFolder\\Background\\shell\\' + @openFolderContextMenuText + '\\command')
    @deleteRegKey(WinReg.HKCR, '\\LibraryFolder\\Background\\shell\\' + @openFolderContextMenuText)
    # @deleteRegKey(WinReg.HKCR, '\\Directory\\Background\\shell\\' + @openFolderContextMenuText + '\\command')
    @deleteRegKey(WinReg.HKCR, '\\Directory\\Background\\shell\\' + @openFolderContextMenuText)
    # @deleteRegKey(WinReg.HKCR, '\\Directory\\shell\\' + @openFolderContextMenuText + '\\command')
    @deleteRegKey(WinReg.HKCR, '\\Directory\\shell\\' + @openFolderContextMenuText)


  install: () ->
    @installOpenFileContextMenu()
    @installOpenFolderContextMenu()
    atom.config.set('windows-context-menu.lastLaunchPath', @launchPath)

  uninstall: () ->
    @uninstallOpenFileContextMenu()
    @uninstallOpenFolderContextMenu()

  disable: () ->
    @uninstall()


  ###
  === PackageManager Hooks
  ###

  activate: (state) ->
    if @launchPathHasChanged()
      @install()

  deactivate: ->
    if atom.packages.isPackageDisabled('windows-context-menu')
      @disable()
