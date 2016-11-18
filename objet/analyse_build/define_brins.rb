# encoding: UTF-8
=begin

  Module de traitement d'un film enregistré dans un dossier temporaire pour
  l'user courant.

=end
AnalyseBuild.require_module 'define_brins'

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
  chantier.save_brins_of_scenes
else
  # Définition des brins (MAIS PAS ENREGISTREMENT)
  chantier.define_brins
end
