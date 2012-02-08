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
