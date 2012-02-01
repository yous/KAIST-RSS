require "rss/maker"
require "rubygems"
require "bundler/setup"
require "mechanize"

class ARA_RSS
  attr_reader :rss, :version, :board

  def initialize(board = "Wanted", version = "2.0")
    @board = board
    @version = version
    @url = (board == "all") ? board : "board/#{board}"
    get
  end

  def data
    @rss.to_xml
  end

  def get
    @rss = RSS::Maker.make(@version) do |m|
      m.channel.title = (@board == "all") ? "ARA RSS Feed" : "ARA #{@board} RSS Feed"
      m.channel.link = "http://ara.kaist.ac.kr/#{@url}/"
      m.channel.description = (@board == "all") ? "News at ARA Board" : "News at ARA #{@board} Board"
      m.items.do_sort = true

      a = Mechanize.new
      (1..3).each do |page_no|
        resp = a.get "http://ara.kaist.ac.kr/#{@url}/?page_no=#{page_no}"
        resp.search('//table[@class="articleList"]/tbody/tr').each do |r|
          if r.inner_html.strip != ""
            m.items.new_item do |item|
              title = (r.at('./td[@class="title "]') or r.at('./td[@class="title  deleted"]'))
              item.title = title.inner_text.strip
              item.date = Time.parse(r.at('./td[@class="date"]').inner_html.strip)
              item.guid.content = r.at('./td[@class="articleid hidden"]').inner_text.strip
              item.guid.isPermaLink = false
              item.link = "http://ara.kaist.ac.kr/#{@url}/#{item.guid.content}"
            end
          end
        end
      end
    end
  end
end
