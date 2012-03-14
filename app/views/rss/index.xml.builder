require "json"

board = params[:board] or "notice"
title = params[:title]

def article_json(article, xml, board)
  xml.item do
    xml.title "#{article["title"]} - #{article["user"]["first_name"]} #{article["user"]["last_name"]}"
    xml.pubDate Time.parse(article["created_at"]).to_s(:rfc822)
    xml.link "https://portal.kaist.ac.kr/notice/#{board}/#{article["id"]}/"
    xml.guid "https://portal.kaist.ac.kr/notice/#{board}/#{article["id"]}/"
    attachments = article["attachments"].map do |file|
      "<br/><a href=\"https://portal.kaist.ac.kr#{file["download_path"]}\">#{file["filename"]}</a>"
    end.join
    xml.description article["content"] + attachments
  end
end

def article_page(article, xml, board, guid)
  title = article.at('./td[contains(@class, "title")]/span[@class="title"]').attr("title").strip
  writer = "#{article.at('./td[contains(@class, "author center")]/span').attr("title").strip} (#{article.at('./td[contains(@class, "orgname center")]/span').attr("title").strip})"
  date = Time.parse(article.at('./td[contains(@class, "date center")]').inner_text.strip).to_s(:rfc822)

  xml.item do
    xml.title "#{title} - #{writer}"
    xml.pubDate date
    xml.link "https://portal.kaist.ac.kr/notice/#{board}/#{guid}/"
    xml.guid "https://portal.kaist.ac.kr/notice/#{board}/#{guid}/"
    xml.description "글을 보시려면 로그인 하셔야만 합니다."
  end
end

xml.instruct!
xml.rss "version" => "2.0", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:trackback" => "http://madskills.com/public/xml/rss/module/trackback/", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd" do
  xml.channel do
    a = Mechanize.new
    a.get "https://portal.kaist.ac.kr/setlang/?language=ko"
    resp_json = JSON.parse(a.get("https://portal.kaist.ac.kr/api/notice/#{board}/?format=json&page=1").body)
    resp_page = a.get("https://portal.kaist.ac.kr/notice/#{board}/").search('//div[@id="articleList"]/table/tbody/tr')

    xml.title "KAIST Portal #{title}"
    xml.description "KAIST Portal #{title} RSS"
    xml.link "https://portal.kaist.ac.kr/notice/#{board}/"

    json_iter = 0
    page_iter = 0

    page_guid = []
    resp_page.each do |article|
      page_guid.push $1.to_i if article.at('./td[contains(@class, "title")]/span[@class="title"]/a').attr("href") =~ /\/notice\/#{board}\/(\d+)/
    end

    while json_iter < resp_json.length and page_iter < resp_page.length
      if resp_json[json_iter]["id"] >= page_guid[page_iter]
        article_json(resp_json[json_iter], xml, board)

        page_iter += 1 if resp_json[json_iter]["id"] == page_guid[page_iter]
        json_iter += 1
      else
        article_page(resp_page[page_iter], xml, board, page_guid[page_iter])
        page_iter += 1
      end
    end

    while json_iter < resp_json.length
      article_json(resp_json[json_iter], xml, board)
      json_iter += 1
    end

    while page_iter < resp_page.length
      article_page(resp_page[page_iter], xml, board, page_guid[page_iter])
      page_iter += 1
    end
  end
end
