# encoding: UTF-8
class Unan
class Program
class Exemple

  def lien_edit atitre = nil, options = nil
    atitre ||= "Éditer l'exemple ##{id}"
    options ||= Hash.new
    options.merge!(href: "exemple/#{id}/edit?in=unan_admin")
    atitre.in_a(options)
  end

  def lien_delete atitre = nil, options = nil
    atitre ||= "Détruire l'exemple ##{id}"
    options ||= Hash.new
    options.merge!(href: "exemple/#{id}/edit?in=unan_admin")
    options.merge!(onclick:"if(confirm('Voulez-vous vraiment DÉTRUIRE DÉFINITIVEMENT cet exemple ?')){return true}else{return false}")
    atitre.in_a(options)
  end

end #/Exemple
end #/Program
end #/Unan
