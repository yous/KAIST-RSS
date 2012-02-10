require "json"

board = params[:board] or "notice"
title = params[:title]

xml.instruct!
xml.rss "version" => "2.0", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:trackback" => "http://madskills.com/public/xml/rss/module/trackback/", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd" do
  xml.channel do
    a = Mechanize.new
    resp = JSON.parse(a.get("https://portal.kaist.ac.kr/api/notice/#{board}/?format=json&page=1").body)

    xml.title "KAIST Portal #{title}"
    xml.description "KAIST Portal #{title} RSS"
    xml.link "https://portal.kaist.ac.kr/notice/#{board}/"
    resp.each do |article|
      xml.item do
        xml.title "#{article["title"]} - #{article["user"]["first_name"]} #{article["user"]["last_name"]}"
        xml.pubDate Time.parse(article["created_at"]).to_s(:rfc822)
        xml.link "https://portal.kaist.ac.kr/notice/#{board}/#{article["id"]}/"
        xml.guid "https://portal.kaist.ac.kr/notice/#{board}/#{article["id"]}/"
        attachments = article["attachments"].map do |file|
          "<a href=\"https://portal.kaist.ac.kr#{file["download_path"]}\">#{file["filename"]}</a><br/>"
        end.join
        xml.description attachments + article["content"]
      end
    end
  end
end
