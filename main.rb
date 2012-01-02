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

    resp = a.get "http://ara.kaist.ac.kr/board/Wanted/"
    resp.search('//table[@class="articleList"]/tbody/tr').each do |r|
      m.items.new_item do |item|
        title = r.at('td[@class="title "]') or r.at('td[@class="title  deleted"]')
        item.title = title.inner_text.strip
        item.date = Time.parse(r.at('td[@class="date"]').inner_html.strip)
        item.guid.content = r.at('td[@class="articleid hidden"]').inner_text.strip
        item.guid.isPermaLink = false
      end
    end
  end

  res.body = content.to_xml
end

trap("INT") { server.shutdown }
server.start
