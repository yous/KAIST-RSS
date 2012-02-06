# encoding: utf-8

module HomeHelper
  def get_menu
    menus = [{"index" => 0, "submenu" => [{"url" => "all", "title" => "모아보기"}]}]
    a = Mechanize.new
    resp = a.get "http://ara.kaist.ac.kr/main/"
    resp.search('//div[@id="navigation"]/ul[@class="menu"]/li/a[@class="category"]').each do |r|
      menu = Hash.new
      menu["index"] = $1.to_i if r.attr("id") =~ /menuCategory(\d+)/
      menu["submenu"] = []
      resp.search("//dl[@id=\"boardInCategory#{menu["index"]}\"]/dd/ul/li/a").each do |sub_r|
        submenu = Hash.new
        submenu["url"] = $1 if sub_r.attr("href") =~ /\/board\/([\w\W]*)\//
        submenu["title"] = sub_r.inner_html.strip
        menu["submenu"].push(submenu)
      end
      menus.push(menu)
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
