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
    type_chose = {'page':1, 'chapitre':3, 'sous-chapitre':2}[chose]

    rien =  portionline.shift # "narration"

    # On décompose les données
    data_chose = portionline.join(' ')
    dchose = Hash::new
    data_chose.scan(/([a-z]+)\[(.*?)\]/).to_a.each do |paire|
      dchose.merge!( paire.first.to_sym => paire.last)
    end

    # Le livre
    livre_id = dchose[:in].numeric? ? dchose[:in].to_i : Cnarration::SYM2ID[dchose[:in].to_sym]
    raise "Le livre est mal défini (ID ou nom du dossier)" if livre_id.nil?

    # On met les données dans les paramètres pour simuler la
    # création
    param(epage: {
      id:           nil,
      livre_id:     livre_id,
      titre:        dchose[:titre],
      handler:      dchose[:handler],
      description:  dchose[:description],
      type:         type_chose.to_s,
      nivdev:       "0"
    })

    # Noter que la procédure est strictement la même pour
    # les pages comme pour les titres
    (Cnarration::folder+'page/edit.rb').require
    ipage = Cnarration::Page::save_page
    flash "#{chose_cap} created successfully."

    if chose == 'page'
      ipage.create_page # pour créer le fichier physique (s'il n'existe pas)
      flash "Fichier créé (#{ipage.path})"
    end


    if dchose[:after]
      # Si :after a été défini, c'est un ID de page après lequel il faut
      # insérer la nouvelle chose, page ou titre
      tdm = Cnarration::table_tdms.get(livre_id)[:tdm]
      after_id = dchose[:after].to_i
      offset_after = tdm.index(after_id) || -1
      debug "tdm avant : #{tdm}"
      tdm = tdm[0..offset_after] + [ipage.id] + tdm[offset_after..-1]
      debug "tdm après : #{tdm}"
      Cnarration::table_tdms.update(livre_id, tdm: tdm)
      flash "#{chose_cap} ajoutée à table des matières du livre ##{livre_id}"
    else
      # Il faut un lien pour éditer la table des matières du livre
      sub_log "Éditer la table des matières du livre".in_a(href:"livre/#{livre_id}/edit?in=cnarration", target:"_blank")
    end

    ""
  end

end #/Console
end #/Admin
end #/SiteHtml
