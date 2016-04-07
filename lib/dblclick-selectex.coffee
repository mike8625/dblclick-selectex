SubAtom = require 'sub-atom'

class DblClickSelectEX
  config:
    boundary:
      type: 'string'
      default: " ,{}<>\"'"
      description: 'set boundary letter'

  activate: ->
    @subs = new SubAtom
    @subs.add atom.workspace.observeTextEditors        (editor) => @setEditor()
    @subs.add atom.workspace.onDidChangeActivePaneItem (editor) => @setEditor()

  setEditor: ->
    process.nextTick =>
      if not (@editor = atom.workspace.getActiveTextEditor())
        return
      @boundary = atom.config.get('dblclick-selectex.boundary')
      @linesSubs?.dispose()
      @lines = atom.views.getView(@editor).shadowRoot.querySelector '.lines'
      @linesSubs = new SubAtom
      @linesSubs.add @lines, 'dblclick', (e) => @dblclick e
  dblclick: (e) ->
    if not @editor then return
    if not e.ctrlKey then return
    @selMarker = @editor.getLastSelection().marker
    @selBufferRange = @selMarker.getBufferRange()
    @selScreenRange = @selMarker.getScreenRange()
    if @selBufferRange.isEmpty() then return

    startRow = @selBufferRange.start.row
    endRow = @selBufferRange.end.row
    screenStarRow = @selScreenRange.start.row
    if startRow != endRow
      return;
    txt = @editor.buffer.lines[startRow]

    startCol = @selBufferRange.start.column
    endCol = @selBufferRange.end.column
    curText = @editor.getTextInBufferRange @selBufferRange
    startTxt = txt.substring 0,startCol
    endTxt = txt.substring startCol+curText.length, txt.length

    startCount = 0
    for i in startTxt by -1
      if(@boundary.indexOf(i) > -1)
        break
      startCount++

    endCount = 0
    for t in endTxt
      if(@boundary.indexOf(t) > -1)
        break
      endCount++

    startCol -= startCount
    endCol += endCount
    @editor.setSelectedScreenRange [[screenStarRow, startCol], [screenStarRow, endCol]]

  deactivate: ->
    @linesSubs?.dispose()
    @subs.dispose()

module.exports = new DblClickSelectEX
