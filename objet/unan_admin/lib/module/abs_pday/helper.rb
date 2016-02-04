# encoding: UTF-8
class Unan
class Program
class AbsPDay

  def lien_edit titre = nil, options = nil
    titre ||= "Éditer le jour-programme #{id}"
    options ||= Hash::new
    options.merge!(href:"abs_pday/#{id}/edit?in=unan_admin")
    titre.in_a(options)
  end

  def lien_show titre = nil, options = nil
    titre ||= "Visualiser le jour-programme #{id}"
    options ||= Hash::new
    options.merge!(href:"abs_pday/#{id}/show?in=unan")
    titre.in_a(options)
  end

  def lien_delete titre = nil, options = nil
    titre ||= "Détruire le jour-programme #{id}"
    options ||= Hash::new
    onclick = "if(confirm('Etes-vous certain de vouloir DÉTRUIRE ce Jour-Programme ?…')){return true}else{return false}"
    options.merge!(href:"abs_pday/#{id}/delete?in=unan_admin", onclick:onclick)
    titre.in_a(options)
  end

end #/AbsPDay
end #/Program
end #/Unan
