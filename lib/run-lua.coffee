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

  serialize: ->

  lua_opener: (url) ->
    if Url.parse(url).protocol is 'lua-output:'
      return new LuaOutput url.substr 13

  executeCurrent: ->
    #aPI = atom.workspace.getActivePaneItem()
    #atom.workspace.getActivePane().saveActiveItem()
    #file = aPI.getPath()
    #if not file

    editor = atom.workspace.getActiveTextEditor()
    editor = atom.workspace.getActivePaneItem() if not editor

    editor.save()

    file = editor?.buffer.file
    filePath = file?.path
    #file = editor?.buffer.file.path #aPI.getPath()

    if not filePath
      return
    if filePath?.substr(filePath.length-4, filePath.length) is '.lua'
      atom.workspace.open('lua-output://' + filePath, {split: 'right', activatePane: false}).then (view) ->
        process = ChildProcess.spawn (atom.config.get 'run-lua.executable'), [filePath]
        process.stdout.on 'data', (data) ->
          view.addLine data
        process.stderr.on 'data', (data) ->
          view.addLine 'ERROR: ' + data
        atom.workspace.activatePreviousPane()
