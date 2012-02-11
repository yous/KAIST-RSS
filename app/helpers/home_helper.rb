# encoding: utf-8
require "json"

module HomeHelper
  def service
    sites = {"portal" => get_menu("portal"), "noah" => get_menu("noah")}

    cont1 = content_tag(:ul, :id => "menu") do
      sites.keys.each_with_index.map do |site, idx|
        content_tag(:li, site.capitalize, :id => "menu#{idx + 1}")
      end.reduce(:<<)
    end
    cont2 = sites.keys.each_with_index.map do |site, idx|
      content_tag(:div, :id => "submenu#{idx + 1}", :class => "submenu") do
        sites[site].map do |menu|
          if site == "portal"
            link_to(menu["title"], {:controller => "rss", :board => menu["url"], :title => menu["title"]}, :target => "_blank") + tag("br")
          elsif site == "noah"
            link_to(menu["title"], "https://noah.haje.org/course/#{menu["url"]}/+rss", :target => "_blank") + tag("br")
          end
        end.reduce(:<<)
      end
    end.reduce(:<<)
    cont1 << cont2
  end

  def get_menu(site)
    a = Mechanize.new
    if site == "portal"
      resp = JSON.parse(a.get("https://portal.kaist.ac.kr/api/notice/?format=json").body)
      menus = resp.map do |board|
        {"title" => board["name"], "url" => board["slug"]}
      end
      menus
    elsif site == "noah"
      a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      menus = []
      resp = a.get "https://noah.haje.org/course"
      resp.search('//div[@id="body"]/table/tr[@class!="head"]').each do |r|
        board = r.at('./td[2]/a')
        menus.push({"title" => board.inner_html.strip, "url" => ($1 if board.attr("href") =~ /\/course\/([\w\W]*)/)})
      end
      menus
    end
  end
end
