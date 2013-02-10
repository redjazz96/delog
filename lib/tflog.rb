lib_path = File.expand_path("../", __FILE__)
$: << lib_path unless $:.include? lib_path

require 'set'
require 'datetime'
require 'forwardable'
require 'tflog/log'
require 'tflog/method_accessor'
require 'tflog/line_parser'
require 'tflog/parsers'
require 'tflog/line'
require 'tflog/version'

module TFLog

end