$LOAD_PATH.unshift 'lib'
require "tflog/version"
 
Gem::Specification.new do |s|
  s.name              = "tflog"
  s.version           = TFLog::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Reads Team Fortress logs."
  s.homepage          = "http://github.com/redjazz96/tflog"
  s.email             = "redjazz96@gmail.com"
  s.authors           = [ "redjazz96" ]
  s.has_rdoc          = false
 
  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("spec/**/*")
 
  s.description       = <<desc
  Reads from Team Fortress 2 logs and interprets them.
desc
end
