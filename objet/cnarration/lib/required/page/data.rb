# encoding: UTF-8
class Cnarration
class Page

  def titre     ; @titre      ||= get(:titre)     end
  def options   ; @options    ||= get(:options)   end
  def livre_id  ; @livre_id   ||= get(:livre_id)  end
  def handler   ; @handler    ||= get(:handler)   end

  # ---------------------------------------------------------------------
  #   Données volatiles
  # ---------------------------------------------------------------------
  def livre
    @livre ||= Cnarration::Livre::get(livre_id)
  end

  # Contenu du fichier d'origine
  def content
    @content ||= path.read
  end

  # Le type symbole de la page, :page, :chapitre ou :sous_chapitre
  def stype
    @stype ||= [nil, :page, :sous_chapitre, :chapitre][type]
  end
  # Le type humain
  def htype
    @htype ||= [nil, "page", "sous-chapitre", "chapitre"][type]
  end

end #/Page
end #/Cnarration
