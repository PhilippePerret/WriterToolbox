# encoding: UTF-8
=begin
Module appelé pour sauver la table des matières
du livre courant. L'enregistre et redirige vers la page d'édition
de la table des matières.
=end

# Le livre dont il faut actualisation la table des matières
def livre
  @livre ||= Cnarration::Livre::new(site.current_route.objet_id)
end
# La nouvelle liste de pages et titres du livre dans l'ordre
def liste_ids
  @liste_ids ||= param(:ids).split('-').collect{|pid| pid.to_i}
end

def tdm_exist?
  Cnarration::table_tdms.count(where:{id: livre.id}) > 0
end

def data_tdm
  @data_tdm ||= begin
    d = Hash::new
    d.merge!( tdm: liste_ids, updated_at:NOW )
    d
  end
end
# flash "Liste : #{data_tdm.inspect}"
if tdm_exist?
  Cnarration::table_tdms.update(livre.id, data_tdm )
  flash "Table des matières du livre ##{livre.id} actualisée."
else
  Cnarration::table_tdms.insert(data_tdm.merge(id: livre.id))
  flash "Table des matières créée pour le livre ##{livre.id}."
end

# Si les Identifiants de pages et titres avaient été mis en
# session (pour accélérer le calcul des pages avant/après) alors
# il faut initialiser cette variable pour qu'elle tienne compte
# des changements
if app.session["cnarration_tdm#{livre.id}"]
  app.session["cnarration_tdm#{livre.id}"] = nil
end

# On retourne à l'édition de la table des matières
redirect_to "livre/#{site.current_route.objet_id}/edit?in=cnarration"
