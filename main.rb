require "webrick"
require "./ararss.rb"

server = WEBrick::HTTPServer.new :Port => (ARGV[0] or 8888).to_i

server.mount_proc("/") do |req, res|
  res["Last-Modified"] = Time.now
  res["Cache-Control"] = "no-store, no-cache, must-revalidate, post-check=0, pre-check=0"
  res["Pragma"] = "no-cache"
  res["Expires"] = Time.now - 100 ** 4

  res.status = 200
  res["Content-Type"] = "text/xml"

  rss = ARA_RSS.new
  res.body = rss.data
end

trap("INT") { server.shutdown }
server.start
