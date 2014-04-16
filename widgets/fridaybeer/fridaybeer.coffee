class Dashing.Fridaybeer extends Dashing.Widget

  beerend = ->
    $('.beer').hide()
    $('.pour').height('0px')
    $('#liquid').height('0px')
    $('.beer-foam')
      .css("bottom", '10px')
      .css("opacity",'0')

  beerstart = ->
    $('.beer').show()
    $('.pour')
        .delay(2000)
        .show()
        .animate({
          height: '320px'
          }, 1500)
        .delay(1600)
        .slideUp(500);       #5600
    $('#liquid')
        .delay(3400)
        .fadeIn(100)
        .animate({
          height: '270px'
        }, 2400);            #5800
    $('.beer-foam') 
        .delay(3400)
        .animate({
          opacity: 1,
          bottom: '290px'
        }, 2500);            #5900
    setTimeout beerdrink, 60000

  beerdrink = ->
    $('.beer-foam')
      .animate({
        opacity: 0,
        bottom: '10px'
      },60000)
      .fadeOut(100)
    $('#liquid')
      .animate({
        height: '0px'
      },60000);
    $('.pour')
      .hide()
      .height('0px')
    setTimeout beerstart, 80000

  ready: ->
    $('.beer').hide()
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.beer is "no"
      beerend()
    else
      beerstart()
      setTimeout beerend, 600000
