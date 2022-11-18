App.ProjectLicenses =
  init: ->
    $('#license_details > .well').slick
      arrows: false
      speed: 700
      infinite: true
      slidesToShow: 1
      slidesToScroll: 1
      autoplay: true
      autoplaySpeed: 20000
      dots: true
      adaptiveHeight: true

    $('.license_details span').tipso(background: '#333333')
    $('.license_details i.fa').tipso(background: '#333333')

$(document).ready ->
  App.ProjectLicenses.init()
