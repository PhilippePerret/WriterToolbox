# encoding: UTF-8
=begin

  Module de traitement d'un film enregistré dans un dossier temporaire pour
  l'user courant.

=end

def chantier
  @chantier ||= site.current_route.instance
end

# Raccourci
def film
  @film ||= chantier.film
end

case param(:operation)
when 'set_define_brins'
  # Enregistrement des brins
  AnalyseBuild.require_module 'save_brins'
  chantier.save_brins_of_scenes
else
  # Définition des brins (MAIS PAS ENREGISTREMENT)
  AnalyseBuild.require_module 'define_brins'
  chantier.define_brins
end
