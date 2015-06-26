LuaOutput = require './lua-output'
{CompositeDisposable} = require 'atom'
BufferedProcess = require 'atom'

module.exports = RunLua =
  config:
    executable:
      type: 'string'
      default: 'lua'
      description: 'The executable path to lua.'
  outputView: null
  subscriptions: null

  activate: (state) ->
    console.log 'activated'
    @outputView = new LuaOutput(state.outputViewState)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'run-lua:executeCurrent': => @executeCurent()

  deactivate: ->
    console.log 'deactivated'
    @subscriptions.dispose()
    @outputView.destroy()

  serialize: ->
    outputViewState: @outputView.serialize()

  executeCurrent: ->
    console.log 'execute current'
    atom.workspace.getActivePaneItem().save()
    file = atom.workspace.getActivePaneItem().buffer.file.path
    if file.substr(file.length-4, file.length) = '.lua'
      console.log 'is lua'
      command = atom.config.get 'run-lua.executable'
      args = [file]
      out = ''
      stdout = (output) -> out += output
      exit = -> @outputView.setContent(out);
      command = new BufferedProcess({command, args, stdout, exit});
