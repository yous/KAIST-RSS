require "mechanize"
require "rss/maker"

a = Mechanize.new

resp = a.get "http://ara.kaist.ac.kr/board/Wanted/"

version = "2.0"
destination = "ara_wanted.xml"

content = RSS::Maker.make(version) do |m|
  m.channel.title = "ARA Wanted RSS Feed"
  m.channel.link = "http://ara.kaist.ac.kr/board/Wanted/"
  m.channel.description = "News at ARA Wanted Board"
  m.items.do_sort = true

  resp.search('//table[@class="articleList"]/tbody/tr').each {|r|
    i = m.items.new_item
    i.title = r.search('td[@class="title "]')[0].inner_html.strip
    i.date = Time.parse(r.search('td[@class="date"]')[0].inner_html.strip)
  }
end

File.open(destination, "w") do |f|
  f.write(content)
end
