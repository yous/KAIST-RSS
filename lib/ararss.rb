require "rss/maker"
require "rubygems"
require "bundler/setup"
require "mechanize"

class ARA_RSS
  attr_reader :rss

  def initialize(version = "2.0")
    @version = version
    get
  end

  def data
    @rss.to_xml
  end

  def get
    @rss = RSS::Maker.make(@version) do |m|
      m.channel.title = "ARA Wanted RSS Feed"
      m.channel.link = "http://ara.kaist.ac.kr/board/Wanted/"
      m.channel.description = "News at ARA Wanted Board"
      m.items.do_sort = true

      a = Mechanize.new
      resp = a.get "http://ara.kaist.ac.kr/board/Wanted/"
      resp.search('//table[@class="articleList"]/tbody/tr').each do |r|
        m.items.new_item do |item|
          title = (r.at('td[@class="title "]') or r.at('td[@class="title  deleted"]'))
          item.title = title.inner_text.strip
          item.date = Time.parse(r.at('td[@class="date"]').inner_html.strip)
          item.guid.content = r.at('td[@class="articleid hidden"]').inner_text.strip
          item.guid.isPermaLink = false
          item.link = "http://ara.kaist.ac.kr/board/Wanted/#{item.guid.content}"
        end
      end
    end
  end
end
