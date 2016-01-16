# encoding: UTF-8
class Unan
class Bureau

  def save_projet
    flash "Je sauve les données projet"
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
