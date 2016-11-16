# encoding: UTF-8
=begin

  Module permettant le dépot d'une analyse, de ses fichiers

=end

# Note : en fait, tous les modules de dépôt, parsing, construction,
# seront appelés les uns après les autres pour procéder au traitement
# complet des fichiers fournis.
AnalyseBuild.require_module 'depot'

def chantier
  @chantier ||= AnalyseBuild.current
end

# Raccourci
def film
  @film ||= chantier.film
end

# Méthode principale qui dépose et traite les fichiers
# de collecte.
#
# Ce code a été mis dans une fonction pour pouvoir ressortir
# plus facilement (avec le return)
#
def depose_et_traite_fichiers
  Analyse::Depot.submit_file || return
  AnalyseBuild.require_module 'parse'
  chantier.parse || return
  AnalyseBuild.require_module 'developpe_data'
  chantier.developpe_data || return
  AnalyseBuild.require_module 'build'
  chantier.build_all_fichiers || return
end

case param(:operation)
when 'deposer_fichier'
  depose_et_traite_fichiers
when 'rebuild_fichiers'
  AnalyseBuild.require_module 'build'
  chantier.build_all_fichiers
end
