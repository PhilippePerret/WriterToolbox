# encoding: UTF-8
raise_unless user.unanunscript? || user.admin?

Unan::require_module 'abs_pday'
Unan::require_module 'abs_work'

# Il faut aussi la feuille de style de show.css du work
page.add_css( Unan::folder + "abs_work/show.css" )
