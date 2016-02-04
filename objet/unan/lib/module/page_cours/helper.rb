# encoding: UTF-8
=begin

Méthodes d'helper de Unan::Program::PageCours

=end
class Unan
class Program
class PageCours

  def lien_show titre = nil, options = nil
    options ||= Hash::new
    options.merge!(show:true, titre:titre)
    link(options)
  end
  alias :lien_read :lien_show

  # Obtenir un lien pour afficher la page, l'éditer ou
  # la détruire
  # @usage
  #   page_cours.link(:edit)
  def link options = nil
    options ||= Hash::new
    onclick = nil
    options[:titre] ||= "#{titre}"
    route = "page_cours/#{id}/" + case true
    when options[:edit]   || options[:edition]    then "edit?in=unan_admin"
    when options[:delete] || options[:destroy]
      onclick = "if(confirm('Etes-vous certain de vouloir detruire definitivement cette page ?')){return true}else{return false}"
      "destroy?in=unan_admin"
    when options[:open]   || options[:ouvrir]     then "open?in=unan_admin"
    else "show?in=unan"
    end
    attrs = { href:route, class:options[:class] }
    attrs.merge!(onclick: onclick) unless onclick.nil?
    options[:titre].in_a(attrs)
  end
  alias :lien :link

  # {String} Retourne le code HTML de la page en fonction
  # de son type (extension)
  def read
    case extension
    when 'erb'
      if fullpath_semidyn.exist?
        fullpath_semidyn.deserb(self)
      else
        flash "Il faudrait construire la page semi-dynamique de cette page, qui ne l'est pas encore."
        fullpath.deserb(self)
      end
    when 'html', 'htm'  then fullpath.read
    when 'txt', 'text'  then fullpath.read.to_html
    when 'tex'          then "[LaTex n'est pas encode traité comme page de cours]"
    end
  end

end #/PageCours
end #/Program
end #/Unan
