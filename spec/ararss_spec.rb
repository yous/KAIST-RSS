require "mechanize"
require "fakeweb"
require "./lib/ararss"

describe "ARA RSS" do
  it "gets the page that contains deleted articles and parse" do
    stream = File.read("./spec/pages/page_deleted.html")
    FakeWeb.register_uri(:get, "http://ara.kaist.ac.kr/board/Wanted/", :body => stream, :content_type => "text/html")
    
    rss = ARA_RSS.new
    rss.data.should eq(File.read("./spec/pages/page_deleted.xml"))
  end

  it "gets the page that contains only one article and parse" do
    stream = File.read("./spec/pages/page_one.html")
    FakeWeb.register_uri(:get, "http://ara.kaist.ac.kr/board/Wanted/", :body => stream, :content_type => "text/html")

    rss = ARA_RSS.new
    rss.data.should eq(File.read("./spec/pages/page_one.xml"))
  end

  it "gets the page that contains only one deleted article and parse" do
    stream = File.read("./spec/pages/page_one_deleted.html")
    FakeWeb.register_uri(:get, "http://ara.kaist.ac.kr/board/Wanted/", :body => stream, :content_type => "text/html")

    rss = ARA_RSS.new
    rss.data.should eq(File.read("./spec/pages/page_one_deleted.xml"))
  end
end
