# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  for menu_li in $("#menu li")
    menu_li.onclick = ->
      submenus = $(".submenu")
      submenu = $("#submenu" + (this.id)[4..-1])
      if submenu.css("display") == "none"
        submenu_div.style.display = "none" for submenu_div in submenus
        submenu.css("display", "block")
      else
        submenu_div.style.display = "none" for submenu_div in submenus
  clip_init = ->
    ZeroClipboard.setMoviePath("/zeroclipboard/ZeroClipboard.swf")
    if $(".mobile").length == 0
      for menu_link in $("#menu .menu0")
        clip = new ZeroClipboard.Client()
        clip.setHandCursor(true)
        clip.setText(menu_link.href)
        clip.addEventListener("complete", (client, text) ->
          alert "클립보드에 저장되었습니다!\nRSS URL : " + text
        )
        clip.glue(menu_link, menu_link.parentNode)
      for submenu in $(".submenu")
        submenu.style.display = "block"
        for submenu_a in $("#" + submenu.id + " a")
          clip = new ZeroClipboard.Client()
          clip.setHandCursor(true)
          clip.setText(submenu_a.href)
          clip.addEventListener("complete", (client, text) ->
            alert "클립보드에 저장되었습니다!\nRSS URL : " + text
          )
          clip.glue(submenu_a, submenu_a.parentNode)
        submenu.style.display = "none"
  clip_init()
