# encoding: UTF-8
=begin

Méthodes d'helper de Unan::Program::PageCours

=end
class Unan
class Program
class PageCours

  # Obtenir un lien pour afficher la page, l'éditer ou
  # la détruire
  def link options = nil
    options ||= Hash::new
    options[:titre] ||= "#{titre}"
    route = "page_cours/#{id}/" + case true
    when options[:edit] || options[:edition]    then "edit?in=unan_admin"
    when options[:delete] || options[:destroy]  then "destroy?in=unan_admin"
    else "read?in=unan"
    end
    options[:titre].in_a(href:route, class: options[:class])
  end
  alias :lien :link

end #/PageCours
end #/Program
end #/Unan
