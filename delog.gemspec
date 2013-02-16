$LOAD_PATH.unshift 'lib'
require "delog/version"

Gem::Specification.new do |s|
  s.name              = "delog"
  s.version           = Delog::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Reads log files."
  s.homepage          = "http://github.com/redjazz96/tflog"
  s.email             = "redjazz96@gmail.com"
  s.authors           = [ "redjazz96" ]

  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("spec/**/*")

  s.description       = <<desc
  Reads from log files and using defined parsers creates a representation of
  them.
desc
end
