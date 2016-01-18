# encoding: UTF-8
=begin

Permet de changer le P-Day de Benoit

=end

# ---------------------------------------------------------------------
# METTRE LE P-DAY DE BENOIT À :

PDAY = 1


# ---------------------------------------------------------------------

require './lib/required'
site.require_objet 'unan'

benoit = User::new(2)

puts "P-Day courant de benoit (:current_pday) : #{benoit.get_var(:current_pday)}"

benoit.set_var(:current_pday, PDAY)

puts "P-Day mis à #{benoit.get_var(:current_pday)}"
