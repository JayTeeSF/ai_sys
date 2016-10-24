#!/usr/bin/env ruby

begin
  require 'rubygems'
  gem 'ai_sys'
  require 'ai_sys'
rescue LoadError
  require_relative "../lib/ai_sys"
end

if __FILE__ == $PROGRAM_NAME
  ais = AiSys.restore
  ais.sub("cat", "animal")
  ais.ind("pj", "cat")
  ais.sub("dog", "wolf")
  ais.sub("wolf", "animal")
  # rel(birthday: name, animal: domain, date: range)
  ais.rel("animal", "birthday", "date") # this should update the animal class
  ais.val("pj", "birthday", "1999-05-20") # this should update the ind. called pj!
  ais.save
end
