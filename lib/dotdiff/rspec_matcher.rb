# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :match_image do |filename, opts = {}|
  match do |page_or_element|
    options = Hash(opts).merge(filename: filename, page: page)

    snapshot = DotDiff::Snapshot.new(options)
    comparer = DotDiff::Comparer.new(page_or_element, page, snapshot)

    result, @message = comparer.result
    result == true
  end

  failure_message do |page_or_element|
    "expected #{page_or_element.class} to match image but failed with: #{@message}"
  end
end
