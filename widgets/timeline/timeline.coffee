class Dashing.Timeline extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered
    dNow = new Date()
    m = dNow.getMonth()+1
    m = "0"+m if m<10
    d = dNow.getDate()
    y = dNow.getFullYear()
    @set('today',d+"."+m+"."+y)
  onData: (data) ->
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.
