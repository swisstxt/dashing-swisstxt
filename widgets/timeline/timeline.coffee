class Dashing.Timeline extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered
  onData: (data) ->
    dNow = new Date()
    m = dNow.getMonth()+1
    m = "0"+m if m<10
    d = dNow.getDate()
    y = dNow.getFullYear()
    @set('today',d+"."+m+"."+y)
