class Dashing.Ews extends Dashing.Widget
  onData: (data) ->
    if data.type
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\btype-\S+/g, ''
      # add new class
      $(@get('node')).addClass "type-#{data.type}"
