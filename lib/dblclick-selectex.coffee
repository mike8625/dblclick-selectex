SubAtom = require 'sub-atom'

class DblClickSelectEX
  config:
    copyKey:
      type: 'string'
      default: 'ctrl'
      description: 'select the keys'
      enum: ['alt', 'ctrl', 'meta']

  activate: ->
    @subs = new SubAtom
    @subs.add atom.workspace.observeTextEditors        (editor) => @setEditor()
    @subs.add atom.workspace.onDidChangeActivePaneItem (editor) => @setEditor()

  setEditor: ->
    process.nextTick =>
      if not (@editor = atom.workspace.getActiveTextEditor())
        return

      @linesSubs?.dispose()
      @lines = atom.views.getView(@editor).shadowRoot.querySelector '.lines'
      @linesSubs = new SubAtom
      @linesSubs.add @lines, 'dblclick', (e) => @dblclick e
  dblclick: (e) ->
    if not @editor then return
    if not e.ctrlKey then return
    @selMarker = @editor.getLastSelection().marker
    @selBufferRange = @selMarker.getBufferRange()
    if @selBufferRange.isEmpty() then return

    startRow = @selBufferRange.start.row
    endRow = @selBufferRange.end.row
    if startRow != endRow
      return;
    txt = @editor.buffer.lines[startRow]

    startCol = @selBufferRange.start.column
    endCol = @selBufferRange.end.column
    curText = @editor.getTextInBufferRange @selBufferRange
    startTxt = txt.substring 0,startCol+curText.length
    endTxt = txt.substring startCol, txt.length
    reg = new RegExp("(\\w+-)*" + curText + "$")
    arr = startTxt.match reg
    startRegTxt = startTxt.match(reg)[0];
    reg = new RegExp("^" + curText + "(-\\w+)*")
    endRegTxt = endTxt.match(reg)[0];
    startCol -= startRegTxt.length - curText.length
    endCol += endRegTxt.length - curText.length
    @editor.setSelectedScreenRange [[startRow, startCol], [startRow, endCol]]

  deactivate: ->
    @linesSubs?.dispose()
    @subs.dispose()

module.exports = new DblClickSelectEX
