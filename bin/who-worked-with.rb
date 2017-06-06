#!/usr/bin/env ruby

require 'nokogiri'

html = File.read "- Pivotal Allocations.html"

doc = Nokogiri::HTML html

table = doc.at_css ".table-report"

rows = table.xpath "./tbody/tr"

people = []

rows.each do |row|
  row.css("div.name > span").each do |name|
    people << name.inner_text.strip
  end
end

people = people.uniq.sort

puts people
