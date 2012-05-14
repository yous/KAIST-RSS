# encoding: utf-8
require "json"

module HomeHelper
  def service
    @portal = RSSPage.new("portal") if @portal.nil?
    @noah = RSSPage.new("noah") if @noah.nil?
    @times = RSSPage.new("times") if @times.nil?

    sites = {"portal" => @portal.menus, "noah" => @noah.menus, "times" => @times.menus}

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
            link_to(menu["title"], "http://noah.kaist.ac.kr/#{menu["url"]}/+rss", :target => "_blank") + tag("br")
          elsif site == "times"
            link_to(menu["title"], "http://times.kaist.ac.kr/rss/#{menu["url"]}", :target => "_blank") + tag("br")
          end
        end.reduce(:<<)
      end
    end.reduce(:<<)
    cont1 << cont2
  end

  class RSSPage
    def initialize(site)
      @site = site
      @time = Time.now
    end

    def menus
      get_menu if @page.nil? or (Time.now - @time >= 60 * 60 * 24)
      @page
    end

    private
    def get_menu
      a = Mechanize.new
      if @site == "portal"
        resp = JSON.parse(a.get("https://portal.kaist.ac.kr/api/notice/?format=json").body)
        menus = resp.map do |board|
          {"title" => board["name"], "url" => board["slug"]}
        end
        @page = menus
        @time = Time.now
      elsif @site == "noah"
        menus = []
        resp = a.get "http://noah.kaist.ac.kr/garbage"
        menus.push("title" => resp.at('//div[@id="title"]/p/a').inner_html.gsub([160].pack("U"), " ").strip, "url" => "garbage")
        ["divisionCS", "course"].each do |site|
          resp = a.get "http://noah.kaist.ac.kr/#{site}"
          resp.search('//div[@id="body"]/table/tr[@class!="head"]').each do |r|
            board = r.at('./td[2]/a')
            title = board.inner_html.gsub([160].pack("U"), " ").strip
            if title == ""
              title = $1 if board.attr("href") =~ /\/#{site}\/([\w\W]*)/
            end
            menus.push({"title" => title, "url" => ($1 if board.attr("href") =~ /\/(#{site}\/[\w\W]*)/)})
          end
        end
        @page = menus
        @time = Time.now
      elsif @site == "times"
        menus = a.get("http://times.kaist.ac.kr/rss/").search('//table/tr/td/table[4]/tr[2]/td/table/tr[2]/td/table/tr[2]/td/table/tr[position()>=2]').map do |item|
          {"title" => item.at('./td[@class="rss_td2"]').inner_text, "url" => ($1 if item.at('./td[@class="click"]/a').attr("href") =~ /http:\/\/times\.kaist\.ac\.kr\/rss\/([\w\W]*)/)}
        end
        @page = menus
        @time = Time.now
      end
    end
  end
end
