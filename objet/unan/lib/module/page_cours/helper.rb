# encoding: UTF-8
=begin

Méthodes d'helper de Unan::Program::PageCours

=end
class Unan
class Program
class PageCours

  # = main =
  #
  # Méthode appelée par la fenêtre show.erb pour afficher
  # une page de la collection Narration, quand elle est
  # lue par une page de cours du programme UNAN.
  #
  # Elle peut être appelée soit directement, s'il s'agit d'une
  # page de la collection narration, soit indirectement si
  # c'est une page de cours (après avoir passé par la méthode
  # `output`)
  #
  # La méthode ajoute une lecture à la page de cours.
  # Mais noter qu'elle ne doit pas la marquer lue pour autant,
  # une page pouvant être lue par fragment ou relue pendant plusieurs
  # jours avant d'être marquée explicitement "lue" par l'apprenti.
  #
  # {String} Retourne le code HTML de la page en fonction
  # de son type (extension)
  #
  def read
    if user.admin?
      lien_edit_page_cours = "Éditer la page cours UNAN ##{id}".in_a(href: "page_cours/#{id}/edit?in=unan_admin", target: :new)
      flash "Administrateur, cette page du programme UNAN redirige vers une page de la collection.<br>#{lien_edit_page_cours}"
    end

    # Pour ajouter une lecture à la page
    # Mais on s'assure que l'user courant suivent bien le programme
    # car il peut s'agir d'un administrateur contrôlant la page ou
    # visitant comme un autre user
    user.unanunscript? && begin
      User::UPage.new(user, self.id).add_lecture
    end

    if narration?
      # Pour une page-cours faisant référence à un titre ou
      # une page narration
      redirect_to "page/#{narration_id}/show?in=cnarration"
      site.require_objet 'cnarration'
      npage = Cnarration::Page.get(narration_id)
      site.instance_variable_set("@objet", npage)
      return Vue.new('cnarration/page/show.erb').output

      # Ça, ça marche, mais ça n'affiche que la page, pas les
      # boutons de navigation et autre.
      # npage.output
    else
      # Pour une page-cours ne faisant pas référence à une
      # page de la collection narration
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
  end

  def lien_show titre = nil, options = nil
    options ||= Hash.new
    options.merge!(show:true, titre:titre)
    link(options)
  end
  alias :lien_read :lien_show

  # Obtenir un lien pour afficher la page, l'éditer ou
  # la détruire
  # @usage
  #   page_cours.link(:edit)
  def link options = nil
    options ||= Hash.new
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


end #/PageCours
end #/Program
end #/Unan
