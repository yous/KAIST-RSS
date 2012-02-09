# encoding: utf-8

module HomeHelper
  def service
    menus = get_menu

    cont1 = content_tag(:ul, :id => "menu") do
      _cont1 = menus["link"].map do |menu|
        link_to(get_title(menu["index"]), {:controller => "rss", :board => menu["url"]}, :class => "menu#{menu["index"]}", :target => "_blank")
      end.reduce(:<<)
      _cont2 = menus["category"].map do |menu|
        content_tag(:li, get_title(menu["index"]), :id => "menu#{menu["index"]}")
      end.reduce(:<<)
      _cont1 + _cont2
    end
    cont2 = menus["category"].map do |menu|
      content_tag(:div, :id => "submenu#{menu["index"]}", :class => "submenu") do
        menu["submenu"].map do |submenu|
          link_to(submenu["title"], {:controller => "rss", :board => submenu["url"]}, :target => "_blank") + tag("br")
        end.reduce(:<<)
      end
    end.reduce(:<<)
    cont1 << cont2
  end

  def get_menu
    menus = {"link" => [], "category" => []}
    a = Mechanize.new
    resp = a.get "http://ara.kaist.ac.kr/main/"
    resp.search('//div[@id="navigation"]/ul[@class="menu"]/li/a').each do |r|
      menu = Hash.new
      if r.attr("id") == "menuFavorite"
        menu["index"] = 0
        menu["url"] = $1 if r.attr("href") =~ /\/([\w\W]*)\//
        menus["link"].push(menu)
      else
        menu["index"] = $1.to_i if r.attr("id") =~ /menuCategory(\d+)/
        menu["submenu"] = []
        resp.search("//dl[@id=\"boardInCategory#{menu["index"]}\"]/dd/ul/li/a").each do |sub_r|
          submenu = Hash.new
          submenu["url"] = $1 if sub_r.attr("href") =~ /\/board\/([\w\W]*)\//
            submenu["title"] = sub_r.inner_html.strip
          menu["submenu"].push(submenu)
        end
        menus["category"].push(menu)
      end
    end
    menus
  end

  def get_title(menu)
    case menu
    when 0
      "모아보기"
    when 1
      "KAIST"
    when 2
      "TALK"
    when 3
      "SHARE"
    when 4
      "INFO"
    when 5
      "HOBBY"
    when 6
      "ARA"
    end
  end
end
