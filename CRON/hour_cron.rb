# encoding: UTF-8
=begin
Module qui doit être appelé toutes les heures par le cron-job.

NOTE : Il doit être exécutable.

=end

THIS_FOLDER = File.dirname(__FILE__)
require File.join(THIS_FOLDER, 'lib', 'required.rb')
