{TextEditor} = require 'atom'

class LuaOutput extends TextEditor
  constructor: (filePath, arg_) ->
    super(arg_)
    @oPath = filePath
  getTitle: ->
    'Lua Output for ' + @oPath.substr @oPath.lastIndexOf('\\') + 1
  save: ->
    if @oPath
      @saveAs @oPath
    else
      atom.workspace.paneForItem(this).saveItemAs(this)
  addLine: (text) ->
    @setText @getText() + text
    @scrollToBottom()


module.exports = LuaOutput
