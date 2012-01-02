require "rubygems"

FileList[File.dirname(__FILE__) + "/tasks/*.rake"].each do |rakefile|
  load rakefile
end

task :default => :autotest
