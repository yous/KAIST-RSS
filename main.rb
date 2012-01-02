require "mechanize"
require "webrick"
require "rss/maker"

a = Mechanize.new

server = WEBrick::HTTPServer.new :Port => (ARGV[0] or 8888).to_i
server.mount_proc("/") do |req, res|
  res["Last-Modified"] = Time.now
  res["Cache-Control"] = "no-store, no-cache, must-revalidate, post-check=0, pre-check=0"
  res["Pragma"] = "no-cache"
  res["Expires"] = Time.now - 100 ** 4

  res.status = 200
  res["Content-Type"] = "text/xml"

  version = "2.0"
  content = RSS::Maker.make(version) do |m|
    m.channel.title = "ARA Wanted RSS Feed"
    m.channel.link = "http://ara.kaist.ac.kr/board/Wanted/"
    m.channel.description = "News at ARA Wanted Board"
    m.items.do_sort = true

    (1..10).each do |page_no|
      resp = a.get "http://ara.kaist.ac.kr/board/Wanted/?page_no=#{page_no}"
      resp.search('//table[@class="articleList"]/tbody/tr').each do |r|
        m.items.new_item do |item|
          item.title = r.search('td[@class="title "]')[0]
          item.title = if item.title == nil
                      r.search('td[@class="title  deleted"]')[0].inner_html.strip
                    else
                      item.title.inner_html.strip
                    end
          item.date = Time.parse(r.search('td[@class="date"]')[0].inner_html.strip)
        end
      end
    end
  end

  res.body = content.to_xml
end

trap("INT") { server.shutdown }
server.start
