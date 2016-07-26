# encoding: UTF-8


# site.require_module('quiz')
#
# class Quiz
#   def suffix_base; 'biblio' end
# end
#
# Quiz.new(1).database_create;

# site.require_objet 'cnarration'
# table = site.dbm_table(:cnarration, 'narration')
# table.select(where:"options LIKE '_9%'").each do |row|
#   opts = row[:options]
#   opts[1] = 'a'
#   debug "options : #{opts} pour #{row[:id]}"
#   table.update(row[:id], options: opts)
# end
