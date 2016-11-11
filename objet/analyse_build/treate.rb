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
when 'parser_chantier'
  chantier.parse
when 'build_evenemencier'
  AnalyseBuild.require_module 'build_events'
  chantier.build_events
end
