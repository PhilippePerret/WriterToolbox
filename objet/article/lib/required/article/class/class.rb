# encoding: UTF-8
class Article

  extend MethodesMainObjets

  class << self

    def titre ; @titre ||= 'LE Blog de la Boite' end

    def data_onglets
      @data_onglets ||= {
        "Article courant" => 'article/show',
        "Liste articles"  => 'article/list'
      }
    end

    # Dossier contenant les textes des articles
    def folder_textes
      @folder_textes ||= folder_lib + 'texte'
    end

  end #/<< self
end #/Article
