#!/usr/bin/env ruby

begin
  require 'rubygems'
  gem 'ai_sys'
  require 'ai_sys'
rescue LoadError
  require_relative "../lib/ai_sys"
end

if __FILE__ == $PROGRAM_NAME
  ais = AiSys.new
  ais.sub("cat", "animal")
  ais.ind("pj", "cat")
  ais.sub("dog", "wolf")
  ais.sub("wolf", "animal")
  ais.val("pj", "birthdate", "1999-05-20")
  puts "repo: #{ais.repo.inspect}"
end
