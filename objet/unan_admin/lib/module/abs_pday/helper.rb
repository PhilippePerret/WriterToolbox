# encoding: UTF-8
class Unan
class Program
class AbsPDay

  def lien_edit atitre = nil, options = nil
    atitre ||= "Éditer le jour-programme #{id}"
    options ||= Hash::new
    options.merge!(href:"abs_pday/#{id}/edit?in=unan_admin")
    atitre.in_a(options)
  end

  def lien_show atitre = nil, options = nil
    atitre ||= "Visualiser le jour-programme #{id}"
    options ||= Hash::new
    options.merge!(href:"abs_pday/#{id}/show?in=unan")
    atitre.in_a(options)
  end

  def lien_delete atitre = nil, options = nil
    atitre ||= "Détruire le jour-programme #{id}"
    options ||= Hash::new
    onclick = "if(confirm('Etes-vous certain de vouloir DÉTRUIRE ce Jour-Programme ?…')){return true}else{return false}"
    options.merge!(href:"abs_pday/#{id}/delete?in=unan_admin", onclick:onclick)
    atitre.in_a(options)
  end

end #/AbsPDay
end #/Program
end #/Unan
