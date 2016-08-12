# encoding: UTF-8
class Unan
class Bureau

  # Enregistrement des données du projet.
  # Noter qu'elles ne seront pas enregistrées "as-is". Pour le +type+,
  # il sera transformé en bit et la propriété sharing sera mise en
  # préférences.
  def save_projet
    data_projet = Hash.new
    data_projet.merge!(titre:   dinp[:titre])         unless dinp[:titre].empty?
    data_projet.merge!(resume:  dinp[:resume])        unless dinp[:resume].empty?
    data_projet.merge!(type:    dinp[:type].to_i)     unless dinp[:type].to_i == 0
    data_projet.merge!(sharing: dinp[:pref_sharing].to_i)  unless dinp[:pref_sharing].to_i == 0
    user.projet.set(data_projet)
    flash "Données du projet enregistrées."
  end

  def dinp
    @dinp ||= param(:projet)
  end

  # Cf. l'explication dans home.rb
  def missing_data
    @missing_data ||= begin
      errors = Array::new
      errors << "le titre"    if user.projet.titre.nil_if_empty.nil?
      errors << "le résumé"   if user.projet.resume.nil_if_empty.nil?
      errors << "le support"  if user.projet.type == 0
      errors << "le partage"  if user.preference(:sharing, 0) == 0
      errors.pretty_join.nil_if_empty
    end
  end

end #/Bureau
end #/Unan

case param(:operation)
when 'bureau_save_projet'
  bureau.save_projet
end
