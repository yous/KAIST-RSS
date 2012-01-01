require "mechanize"
require "webrick"
require "rss/maker"

a = Mechanize.new

server = WEBrick::HTTPServer.new :BindAddress => "127.0.0.1", :Port => (ARGV[0] or 8080).to_i
server.mount_proc("/") do |req, res|
  res["Last-Modified"] = Time.now
  res["Cache-Control"] = "no-store, no-cache, must-revalidate, post-check=0, pre-check=0"
  res["Pragma"] = "no-cache"
  res["Expires"] = Time.now - 100 ** 4

  res.status = 200
  res["Content-Type"] = "text/xml"

  resp = a.get "http://ara.kaist.ac.kr/board/Wanted/"
  version = "2.0"

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

  res.body = content.to_xml
end

trap("INT") { server.shutdown }
server.start
