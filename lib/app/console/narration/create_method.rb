# encoding: UTF-8
class SiteHtml
class Admin
class Console


  def creer_page_ou_titre_narration portionline
    site.require_objet 'cnarration'

    portionline = portionline.split(' ')
    chose = portionline.shift
    chose = case chose
    when 'page' then 'page'
    when /(sous-chapitre|sous_chapitre|schap)/ then 'sous-chapitre'
    when /(chapitre|chap)/ then 'chapitre'
    end

    chose_cap = chose.capitalize
    type_chose = {'page' => 1, 'chapitre' => 3, 'sous-chapitre' => 2}[chose]
    la_chose_cap = [
      "", "La page", "Le sous-chapitre", "Le chapitre"
    ][type_chose]

    rien =  portionline.shift # "narration"

    # On décompose les données
    dchose = Data::by_semicolon_in portionline.join(' ')

    # Le livre
    livre_id = dchose[:in].numeric? ? dchose[:in].to_i : Cnarration::SYM2ID[dchose[:in].to_sym]
    raise "Le livre est mal défini (ID ou nom du dossier symbolique) — taper `aide livres narration` pour une aide" if livre_id.nil?

    # On met les données dans les paramètres pour simuler la
    # création
    epage = {
      id:           nil,
      livre_id:     livre_id,
      titre:        dchose[:titre],
      description:  dchose[:description] || "",
      type:         type_chose.to_s,
      nivdev:       dchose[:niveau]||dchose[:dev]||"0"
    }
    if chose == 'page'
      epage.merge!(
        handler:      dchose[:handler]
      )
    end
    param( epage: epage )

    # Noter que la procédure est strictement la même pour
    # les pages comme pour les titres
    (Cnarration::folder+'page/edit.rb').require
    ipage = Cnarration::Page::save_page
    raise "#{la_chose_cap} devrait avoir un identifiant…" if ipage.id.nil?
    flash "#{chose_cap} created successfully."

    if chose == 'page'
      ipage.create_page # pour créer le fichier physique (s'il n'existe pas)
      flash "Fichier créé. Pour OUVRIR CE FICHIER, taper en console `ouvrir page narration #{ipage.id}`"
    end


    if dchose[:after]
      # Si :after a été défini, c'est un ID de page après lequel il faut
      # insérer la nouvelle chose, page ou titre
      tdm = Cnarration::table_tdms.get(livre_id)[:tdm]
      after_id = dchose[:after].to_i
      offset_after = tdm.index(after_id) || -1
      tdm_finale = Array::new
      if offset_after > 0
         tdm_finale += tdm[0..offset_after]
      end
      tdm_finale <<  ipage.id
      if offset_after < tdm.count
        tdm_finale += tdm[offset_after + 1..-1]
      end
      Cnarration::table_tdms.update(livre_id, tdm: tdm_finale)
      flash "#{chose_cap} ajouté/e à table des matières du livre ##{livre_id}. Vous pouvez taper `afficher table cnarration.tdms` pour voir la liste du livre ##{livre_id}."
    else
      # Il faut un lien pour éditer la table des matières du livre
      sub_log "Éditer la table des matières du livre".in_a(href:"livre/#{livre_id}/edit?in=cnarration", target:"_blank")
    end

    ""
  end

end #/Console
end #/Admin
end #/SiteHtml
