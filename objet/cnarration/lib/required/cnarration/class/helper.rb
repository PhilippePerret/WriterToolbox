# encoding: UTF-8
class Cnarration

  DATA_ONGLETS = {
    "Accueil"   => "cnarration/home",
    "Livres"    => "livre/list?in=cnarration",
    "Recherche" => 'cnarration/search'
  }

  extend MethodesMainObjets

  class << self

    def titre_h1 sous_titre = nil
      t = "Collection Narration".in_h1
      t << sous_titre.in_h2 unless sous_titre.nil?
      t << onglets # Dans MethodesMainObjets
      t
    end

    def data_onglets
      donglets = Hash::new
      donglets.merge!(DATA_ONGLETS)
      if user.admin?
        donglets.merge!(
          "New page"          => "page/edit?in=cnarration",
          "[ADMINISTRATION]"  => "admin/dashboard?in=cnarration",
          "Synchro"           => "cnarration/synchro"
          )
      end
      donglets
    end

    # Retourne le texte type de nom +nom+
    #
    # Ce texte doit se trouver dans un fichier de nom
    # +nom+ dans le dossier des textes type de narration :
    #   ./data/unan/texte_type/cnarration
    #
    # Le fichier peut être de plusieurs types différents mais
    # c'est le type Markdown qui est préféré.
    #
    # +options+
    #   :output_format    Format de sorte (:erb, :html ou :latex)
    #
    # TODO: Prendre en compte le format
    def texte_type nom, options = nil
      nom += ".md" unless nom.end_with?('.md')
      sf = (folder_textes_types+nom)
      case sf.extension
      when 'md'
        sf.kramdown
      when 'rb'
        require sf
      when 'txt', 'html'
        sf.read
      end
    end
    def folder_textes_types
      @folder_textes_types ||= site.folder_data+"unan/texte_type/cnarration"
    end
  end #/ << self
end #/Cnarration
