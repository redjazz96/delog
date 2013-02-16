module Delog::Parsers::Addins
  module DateTime

    # This method is evaluated in the context of the block.
    def self.bind
      unless has_key?(:date_match_to)
        set :date_match_to => "[0-9]{2}\\/[0-9]{2}\\/[0-9]{4}\\s\\-\\s[0-9]{2}\\:[0-9]{2}\\:[0-9]{2}"
      end

      unless has_key?(:date_format)
        set :date_format => "%m/%d/%Y - %H:%M:%S"
      end

      on %r{(?<time>
        #{date_match_to}
      )}x do |m|
        set :time => DateTime.strptime(m.time, time_format).to_time.utc
      end
    end

    def self.whitelist

    end

  end
end
