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

end #/Page
end #/Cnarration
