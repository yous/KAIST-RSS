require "mechanize"
require "fakeweb"
require "./lib/ararss"

describe "ARA RSS" do
  context "gets the page that contains" do
    ["deleted", "one", "one_deleted", "none", "none_2", "trouble"].each do |attr|
      it "#{attr} article(s) and parse" do
        stream = File.read("./spec/pages/page_#{attr}.html")
        FakeWeb.register_uri(:get, "http://ara.kaist.ac.kr/board/Wanted/", :body => stream, :content_type => "text/html")

        rss = ARA_RSS.new
        rss.data.should eq(File.read("./spec/pages/page_#{attr}.xml"))
      end
    end
  end
end
