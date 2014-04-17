class Dashing.Fridaybeer extends Dashing.Widget
  i = 1
  beerend = ->
    clearTimeout
    $('.beer').hide()
    $('.pour').height('0px')
    $('#liquid').height('0px')
    $('.beer-foam')
      .css("bottom", '10px')
      .css("opacity",'0')

  beerstart = ->
    clearTimeout
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
    clearTimeout
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
    i = i+1
    if i < 6 then setTimeout beerstart, 80000 else setTimeout beerend, 60100

  ready: ->
    $('.beer').hide()
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.beer is "no"
      beerend()
    else
      beerstart()
