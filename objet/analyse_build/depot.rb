# encoding: UTF-8
=begin

  Module permettant le dépot d'une analyse, de ses fichiers

=end
AnalyseBuild.require_module 'depot'

case param(:operation)
when 'deposer_fichier' then Analyse::Depot.submit_file
end
