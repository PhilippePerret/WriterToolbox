

# Pour ajouter une ancre vers une partie de la page
#
# Utiliser options[:titre] pour modifier le titre qui, par défaut,
# est un doigt pointant vers "voir"
#
# OBSOLÈTE : Ce texte n'apparaitra que sur le web, pas dans la version
# papier. MAINTENANT : il n'apparait sur le web que s'il n'y a pas
# d'options définies.
#
# Mettre le code entre balise RUBY_ .... _RUBY comme pour tout code
# qui doit être évalué au tout début de la construction de la page.
#
def goto_ancre(ancre, options = nil)
  if options.nil?
    options = Hash.new
    lnk = "#{DOIGT}voir".in_a(anchor: ancre)
    options[:titre] = "<webonly> (#{lnk})</webonly>"
  else
    options[:titre] ||= " (#{DOIGT}voir)"
    options[:titre] = options[:titre].in_a(anchor: ancre)
    options[:after_text] && begin
      options[:titre] += " #{options[:after_text]}"
    end
    options[:before_text] && begin
      options[:titre] = "#{options[:before_text]} " + options[:titre]
    end
  end
  options[:titre]
end
alias :voir_ancre :goto_ancre
alias :ancre_vers :goto_ancre
