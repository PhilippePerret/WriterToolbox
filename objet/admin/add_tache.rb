# encoding: UTF-8
=begin

Module appelé par Ajax pour ajouter une tâche à l'aide du
widget

=end

# Seul un administrateur peut utiliser ce module
raise_unless_admin

site.require_module 'tache'

::Admin::Taches::create_tache_from_widget
