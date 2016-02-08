# encoding: UTF-8
=begin
Module d'aide pour le programme UN AN UN SCRIPT
=end
page.add_css(site.folder_objet+'unan/aide/home.css')
# => DATA_TDM_AIDE

class Unan
  DATA_SYM = {
    bureau:       {rp: "fonctionnement/bureau", t:"Centre de travail"},
    preferences:  {rp: "preferences/tdm", t:"Préférences"}
  }
  class << self
    def lien_aide relpath, titre = nil
      if relpath.instance_of?(Symbol)
        data_sym = DATA_SYM[relpath]
        relpath = data_sym[:rp]
        titre   ||= data_sym[:t]
      end
      Aide::link_to(relpath, titre || "[LIEN AIDE]")
    end
  end # / << self de Unan
class Aide
  class << self

    def link_to relpath, titre, options = nil
      options ||= Hash::new
      options.merge!(href: "bureau/home?in=unan&pid=#{relpath}&cong=aide")
      titre.in_a(options)
    end

    # Retourne le code HTML de la page d'aide demandé (son relpath est
    # contenu dans pid)
    def show_page
      relpath_page = param(:pid)
      (folder_aide+"#{relpath_page}.erb").deserb
    end

    # Surclassement de la méthode affichant le titre. Dans la section aide
    # générale, cette méthode affiche un titre dans h1 et h2, ici, on ne se
    # sert que de l'argument, qui est vraiment le titre
    def titre sous_titre
      sous_titre.in_h2
    end

    # Retourne le lien vers la table des matières générale du l'aide,
    # dans un div aligné à droite. Ce lien, en fait, ramène simplement à
    # la page d'accueil de l'aide du centre de travail.
    def link_to_tdm
      "Table des matières".in_a(href:'bureau/home?in=unan&cong=aide').in_div(class:'small right')
    end

    def folder_aide
      @folder_aide ||= site.folder_objet+'unan/aide'
    end

    def tdm
      load_data
      build_tdm # => retourne le code
    end
    def load_data
      (site.folder_objet + 'unan/aide/DATA_TDM.rb').require
      # => DATA_TDM_AIDE
    end
  end # /<< self
end #/Aide
end #/Unan
