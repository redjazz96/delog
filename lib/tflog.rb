lib_path = File.expand_path("../", __FILE__)
$: << lib_path unless $:.include? lib_path

require 'set'
require 'date'
require 'forwardable'
require 'tflog/line_parser'
require 'tflog/parsers'
require 'tflog/log'
require 'tflog/method_accessor'
require 'tflog/line'
require 'tflog/version'

module TFLog

end