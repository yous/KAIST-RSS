require "mechanize"
require "fakeweb"
require "./lib/ararss"

describe "ARA RSS" do
  context "gets the page that contains" do
    ["deleted", "one", "one_deleted", "none", "none_2", "trouble"].each do |attr|
      it "#{attr} article(s) and parse" do
        stream = File.read("./spec/pages/page_#{attr}.html")
        (1..3).each do |page_no|
          FakeWeb.register_uri(:get, "http://ara.kaist.ac.kr/board/Wanted/?page_no=#{page_no}", :body => (page_no == 1) ? stream : "", :content_type => "text/html")
        end

        rss = ARA_RSS.new
        rss.data.should eq(File.read("./spec/pages/page_#{attr}.xml"))
      end
    end
  end
end
