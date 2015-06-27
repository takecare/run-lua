{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'

module.exports = RunLua =
  config:
    executable:
      type: 'string'
      default: 'lua'
      description: 'The executable path to lua.'
  subscriptions: null

  activate: (state) ->
    console.log 'activated'
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'run-lua:executeCurrent': => @executeCurrent()

  deactivate: ->
    console.log 'deactivated'
    @subscriptions.dispose()

  serialize: ->

  executeCurrent: ->
    atom.workspace.getActivePaneItem().save()
    file = atom.workspace.getActivePaneItem().buffer.file.path
    if file.substr(file.length-4, file.length) is '.lua'
      atom.workspace.open('lua-output://', {split: 'right'}).then (view) ->
        process = ChildProcess.exec (atom.config.get 'run-lua.executable') + ' "' + file + '"', (error, stdout, stderr) ->
          view.setText(stdout);
