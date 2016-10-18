# encoding: UTF-8
=begin
Module appelé pour sauver la table des matières
du livre courant. L'enregistre et redirige vers la page d'édition
de la table des matières.
=end

# Le livre dont il faut actualisation la table des matières
def livre
  @livre ||= Cnarration::Livre.new(site.current_route.objet_id)
end

# {String} La nouvelle liste de pages et titres du livre dans l'ordre
def liste_ids
  @liste_ids ||= param(:ids).split('-').join(',')
end
def old_liste_ids
  @old_liste_ids ||= livre.tdm.pages_ids
end

def tdm_exist?
  Cnarration.table_tdms.count(where: {id: livre.id}) > 0
end

def data_tdm
  @data_tdm ||= begin
    d = {}
    d.merge!( tdm: liste_ids, updated_at:NOW )
    d
  end
end
# flash "Liste : #{data_tdm.inspect}"
if tdm_exist?
  # # Quand la table des matières existe, il faut faire une autre
  # # opération qui consiste à retirer la définition de @livre_id pour
  # # les pages éventuellement retirées.
  # # NON : il ne faut pas retirer le 'livre_id' de la page, pour qu'elle
  # # reste associée au livre. Car on peut vouloir la remettre plus tard
  # # De plus, si elle est retirée complètement du livre, elle disparait
  # # des radars.
  # checkedstring = ",#{liste_ids},"
  # pages_out = Array.new
  # pages_old = Array.new
  # old_liste_ids.each do |pid|
  #   if checkedstring.index(",#{pid},")
  #     pages_old << pid
  #   else
  #     pages_out << pid
  #   end
  # end
  # pages_out.each do |pid|
  #   Cnarration.table_pages.update(pid, {livre_id: nil})
  # end
  Cnarration.table_tdms.update( livre.id, data_tdm )
  flash "Table des matières du livre ##{livre.id} actualisée."
else
  Cnarration.table_tdms.insert( data_tdm.merge(id: livre.id) )
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
