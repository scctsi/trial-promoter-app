#!/usr/bin/env ruby.exe
begin
  load File.expand_path('../spring', __FILE__)
rescue LoadError => e
  raise unless e.message.include?('spring')
end
require_relative '../config/boot'
require 'rake'
Rake.application.run
