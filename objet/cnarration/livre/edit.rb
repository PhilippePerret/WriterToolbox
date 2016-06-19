# encoding: UTF-8
class Cnarration
class Livre

  # = main =
  #
  # Retourne le code de la table des matières éditable
  def editable_tdm
    items = if pages_et_titres_in_tdm.empty?
      "--- DÉLIMITEUR DÉBUT---".in_li('data-id' => "0") +
      "--- DÉLIMITEUR FIN---".in_li('data-id' => "0")
    else
      pages_et_titres_in_tdm.collect do |pid, ipage|
        ipage.titre.in_li('data-id' => pid, class:"niv#{ipage.type}")
      end.join
    end
    items.in_ul(id:'editable_tdm', class:'livre_tdm')
  end

  # = main =
  #
  # Retourne les pages et titre hors tdm
  def pages_et_titres_out
    items = if pages_et_titres_out_tdm.empty?
      "--- DÉLIMITEUR DÉBUT---".in_li('data-id' => "0") +
      "--- DÉLIMITEUR FIN---".in_li('data-id' => "0")
    else
      pages_et_titres_out_tdm.collect do |pid, ipage|
        ipage.titre.in_li('data-id' => pid, class:"niv#{ipage.type}")
      end.join
    end
    items.in_ul(id:'pages_et_titres_out', class:'livre_tdm')
  end

  # Retourne la liste des pages et titre de la table des matières
  # du livre courant.
  def pages_et_titres_in_tdm
    @pages_et_titres_tdm ||= begin
      h = {}
      ids_pages_et_titres_in.each{ |pid| h.merge!(pid => Cnarration::Page::get(pid)) }
      h
    end
  end
  def pages_et_titres_out_tdm
    @pages_et_titres_out_tdm ||= begin
      h = {}
      ids_pages_et_titres_out.each{ |pid| h.merge!(pid => Cnarration::Page::get(pid)) }
      h
    end
  end


  def ids_pages_et_titres_in
    @ids_pages_et_titres_in ||= Cnarration::Livre.ids_tdm_of_livre( id )
  end
  def ids_pages_et_titres_out
    @ids_pages_et_titres_out ||= begin
      ids = Cnarration.table_pages.select(where:{livre_id: id}, colonnes:[]).collect{|h| h[:id]}
      if ids_pages_et_titres_in.empty?
        ids
      else
        ids.reject!{ |pid| ids_pages_et_titres_in.include?(pid)}
      end
    end
  end

end #/Livre
end #/Cnarration
