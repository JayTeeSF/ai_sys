#!/usr/bin/env ruby

begin
  require "rubygems"
  gem "ai_sys"
  require "ai_sys"
rescue LoadError
  require_relative "../lib/ai_sys"
end

if __FILE__ == $PROGRAM_NAME
  ais = AiSys.restore
  puts "** Making Cat a subclass of Animal **:"
  ais.sub("cat", "animal")
  puts "\n** Making PJ an individual Cat **:"
  ais.ind("pj", "cat")
  puts "\n** Making Dog a subclass of Wolf **:"
  ais.sub("dog", "wolf")
  puts "\n** Making Wolf a subclass of Animal **:"
  ais.sub("wolf", "animal")
  #ais.rel("date", "animal", "birthdate") # this should update the animal class
  puts "\n** Giving all Animal(s) the ability to have a birthdate **:"
  ais.rel("birthdate", "animal", "date") # this should update the animal class
  # ais.val("pj", "birthdate", "1999-05-20") # this should update the ind. called pj!
  puts "\n** SAVE **:"
  ais.save
  puts "\n** Giving PJ a specific birthdate **:"
  ais.val("birthdate", "pj", "1999-05-20") # this should update the ind. called pj!
  puts "\n** SAVE **:"
  ais.save
end
