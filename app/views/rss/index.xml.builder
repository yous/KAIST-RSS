board = params[:board] || "all"
url = (board == "all") ? board : "board/#{board}"

xml.instruct!
xml.rss "version" => "2.0", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:trackback" => "http://madskills.com/public/xml/rss/module/trackback/", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd" do
  xml.channel do
    if board == "all"
      xml.title "ARA RSS Feed"
      xml.description "News at ARA Board"
    else
      xml.title "ARA #{board} RSS Feed"
      xml.description "News at ARA #{board} Board"
    end
    xml.link "http://ara.kaist.ac.kr/#{url}/"

    a = Mechanize.new
    (1..3).each do |page_no|
      resp = a.get "http://ara.kaist.ac.kr/#{url}/?page_no=#{page_no}"
      resp.search('//table[@class="articleList"]/tbody/tr').each do |r|
        if r.inner_html.strip != ""
          xml.item do
            title = (r.at('./td[@class="title "]') or r.at('./td[@class="title  deleted"]'))
            xml.title title.inner_text.strip.gsub("<", "＜").gsub(">", "＞")
            time = Time.parse(r.at('./td[@class="date"]').inner_html.strip)
            xml.pubDate time.strftime("%a, %d %b %Y %H:%M:%S %z")
            guid = r.at('./td[@class="articleid hidden"]').inner_text.strip
            xml.guid guid, :isPermaLink => false
            xml.link "http://ara.kaist.ac.kr/#{url}/#{guid}"
          end
        end
      end
    end
  end
end
