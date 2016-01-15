# encoding: UTF-8
class Unan
class Bureau

  def save_travail
    flash "Je sauve les données travail"
  end

  # cf. l'explication dans le fichier home.rb
  def missing_data
    @missing_data ||= begin
      nil # pour le moment
    end
  end

end # /Bureau
end # /Unan

case param :operation
when 'bureau_save_travail'
  bureau.save_travail
end
