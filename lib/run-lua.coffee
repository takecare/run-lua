{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'
Url = require 'url'
LuaOutput = require './lua-output'

module.exports = RunLua =
  config:
    executable:
      type: 'string'
      default: 'lua'
      description: 'The executable path to lua.'

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'run-lua:executeCurrent': => @executeCurrent()
    @subscriptions.add atom.workspace.addOpener @lua_opener.bind this

  deactivate: ->
    @subscriptions.dispose()

  lua_opener: (url) ->
    return new LuaOutput url.substr 'lua-output://'.length if Url.parse(url).protocol is 'lua-output:'

  getOutputPane: ->
    editors = atom.workspace.getTextEditors()
    for editor in editors
      return editor if editor instanceof LuaOutput
    return

  getFilePath: ->
    editor = atom.workspace.getActivePaneItem()
    editor.save()
    editor?.buffer.file?.path

  executeLua: (filePath, f) ->
    process = ChildProcess.spawn (atom.config.get 'run-lua.executable'), [filePath]
    process.stdout.on 'data', (data) -> f(data)
    process.stderr.on 'data', (data) -> f('ERROR: ' + data)

  executeCurrent: ->
    filePath = @getFilePath()
    outputPane = @getOutputPane()

    return unless filePath

    if filePath?.substr(filePath.length-4, filePath.length) is '.lua'
      activePane = atom.workspace.getActivePane()
      if outputPane
        data = RunLua.executeLua(filePath, (data) ->
          outputPane.addLine('\n' + data)
          )
      else
        atom.workspace.open('lua-output://' + filePath, {split: 'right', activatePane: false}).then (view) ->
          data = RunLua.executeLua(filePath, (data) ->
            view.addLine(data)
            activePane.activate()
          )
