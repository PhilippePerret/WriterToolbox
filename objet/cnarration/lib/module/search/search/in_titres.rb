# encoding: UTF-8
class Cnarration
class Search

  # = main =
  #
  # Méthode qui recherche le texte dans les titres de la
  # base de données
  #
  def search_in_titres
    unless regular?
      # Recherche non régulière
      searched_slashed = searched.gsub(/'/, "\\'")
      request_data = {
        where:    "titre LIKE '%#{searched_slashed}%'",
        colonnes: [:titre, :options]
      }
      request_data.merge!(nocase: true) unless exact?
      table_pages.select( request_data ).each do |pid, pdata|
        ipage = Cnarration::Page::get(pid)
        next if ipage.page? && ipage.developpement < developpement_minimum
        # Sinon, on prend la page
        add_found_in_titre ipage
      end
    else
      # Recherche régulière
      debug "-> recherche régulière dans les titres"
      debug "   reg_searched : #{reg_searched.inspect}"
      Cnarration::table_pages.select(colonnes:[:titre, :handler, :livre_id, :options]).each do |pid, pdata|
        ipage = Cnarration::Page::get(pid)
        next if ipage.page? && ( ipage.developpement < developpement_minimum )
        debug "   - check de #{pdata[:titre]}"
        unless pdata[:titre].match(reg_searched).nil?
          debug "    Trouvé !"
          add_found_in_titre ipage
        end
      end
    end
  end


  def add_found_in_titre ipage
    @result[:nombre_founds]     += 1
    @result[:nombre_in_titres]  += 1

    gfile = @result[:by_file][ipage.id]
    gfile || begin
      gfile = ::Cnarration::Search::SFile::new(self, ipage.id)
      gfile.page_titre    = ipage.titre
      gfile.livre_id      = ipage.livre_id
      gfile.relative_path = "#{ipage.relative_affixe}.md"
      @result[:by_file].merge!( ipage.id => gfile)
    end

    ifound = ::Cnarration::Search::Found::new( self, ipage.titre )
    ifound.in_titre   = true
    ifound.text_line  = ipage.titre

    # Dans un titre, le poids d'un found est de 5
    gfile.occurrences += ifound.iterations
    gfile.weight      += 5 * ifound.iterations
    gfile.founds_in_titres << ifound

  end

end #/Search
end #/Cnarration
