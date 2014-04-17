#!/usr/bin/env ruby

module Jekyll
  module Liquify
    def to_liquid
      Hash[self.members.map { |attr| [attr.to_s, send(attr)] }]
    end
  end

  module LogCapable
    def logger
      Jekyll.logger
    end
  end
end
