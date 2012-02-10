# encoding: utf-8
require "json"

module HomeHelper
  def service
    menus = get_menu

    cont1 = content_tag(:ul, :id => "menu") do
      content_tag(:li, "Portal", :id => "menu1")
    end
    cont2 = content_tag(:div, :id => "submenu1", :class => "submenu") do
      menus.map do |menu|
        link_to(menu["title"], {:controller => "rss", :board => menu["url"], :title => menu["title"]}, :target => "_blank") + tag("br")
      end.reduce(:<<)
    end
    cont1 << cont2
  end

  def get_menu
    a = Mechanize.new
    resp = JSON.parse(a.get("https://portal.kaist.ac.kr/api/notice/?format=json").body)
    menus = resp.map do |board|
      {"title" => board["name"], "url" => board["slug"]}
    end
    menus
  end
end
