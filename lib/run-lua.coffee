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
    aPI = atom.workspace.getActivePaneItem()
    atom.workspace.getActivePane().saveActiveItem()
    file = aPI.getPath()
    if not file
      return
    if file.substr(file.length-4, file.length) is '.lua'
      atom.workspace.open('lua-output://' + file, {split: 'right', activatePane: false}).then (view) ->
      #   process = ChildProcess.exec (atom.config.get 'run-lua.executable') + ' "' + file + '"', (error, stdout, stderr) ->
      #     view.setText stdout
        process = ChildProcess.spawn (atom.config.get 'run-lua.executable'), [file]
        process.stdout.on 'data', (data) ->
          view.addLine data
        process.stderr.on 'data', (data) ->
          view.addLine 'ERROR: ' + data
