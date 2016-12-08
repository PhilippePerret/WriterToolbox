

# Pour ajouter une ancre vers une partie de la page
#
# Utiliser options[:titre] pour modifier le titre qui, par défaut,
# est un doigt pointant vers "voir"
#
# Ce texte n'apparaitra que sur le web, pas dans la version papier.
#
# Mettre le code entre balise RUBY_ .... _RUBY comme pour tout code
# qui doit être évalué au tout début de la construction de la page.
#
def goto_ancre(ancre, options = nil)
  options ||= Hash.new
  options[:titre] ||= "#{DOIGT}voir"
  '<onlyweb> (' + options[:titre].in_a(anchor: ancre) + ')</onlyweb>'
end
alias :voir_ancre :goto_ancre
alias :ancre_vers :goto_ancre
