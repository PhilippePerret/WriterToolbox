# encoding: UTF-8
=begin

  Module permettant le dépot d'une analyse, de ses fichiers

=end
AnalyseBuild.require_module 'depot'

def chantier
  @chantier ||= AnalyseBuild.current
end

# Raccourci
def film
  @film ||= chantier.film
end

case param(:operation)
when 'deposer_fichier'
  Analyse::Depot.submit_file
  AnalyseBuild.require_module 'parse'
  chantier.parse
  AnalyseBuild.require_module 'developpe_data'
  chantier.developpe_data
  AnalyseBuild.require_module 'build'
  chantier.build_all_fichiers
end
