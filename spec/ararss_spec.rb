require "mechanize"
require "fakeweb"
require "lib/ararss"

RSpec.configure do |config|
  config.mock_framework = :rspec
end

describe "ARA RSS" do
  it "gets the first page of ARA board and parse" do
    stream = File.read("./spec/fake_ara_page.html")
    FakeWeb.register_uri(:get, "http://ara.kaist.ac.kr/board/Wanted/", :body => stream, :content_type => "text/html")
    
    rss = ARA_RSS.new
    rss.data.should eq(File.read("./spec/fake_ara_page.xml"))
  end
end
