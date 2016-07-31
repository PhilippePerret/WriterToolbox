# encoding: UTF-8
=begin

  Fichier principal qui doit être appelé.

  La première partie contient des choses qui doivent être définies
  en fonction du site courant.

=end

require 'rspec-html-matchers'
require 'capybara/rspec'
include RSpecHtmlMatchers

require_relative 'lib/required'

TestedUrl.init
TestedUrl.run
TestedUrl.report

say TestedUrl.instances.first.html_status
