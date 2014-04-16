class Dashing.Fridaybeer extends Dashing.Widget

  beerend = ->
    $('.beer').hide()
    $('.pour').height('0px')
    $('#liquid').height('0px')
    $('.beer-foam').css("bottom", '10px')

  beerstart = ->
    $('.beer').show()
    $('.pour')
        .delay(2000)
        .animate({
          height: '320px'
          }, 1500)
        .delay(1600)
        .slideUp(500);
    $('#liquid')
        .delay(3400)
        .fadeIn(100)
        .animate({
          height: '270px'
        }, 2400);
    $('.beer-foam') 
        .delay(3400)
        .animate({
          opacity: 1,
          bottom: '290px'
        }, 2500);

  ready: ->
    $('.beer').hide()
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.beer is "no"
      beerend()
    else
      beerstart()
      setTimeout beerend, 300000
