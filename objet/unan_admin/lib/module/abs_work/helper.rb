# encoding: UTF-8
class Unan
class Program
class AbsWork

  def lien_edit atitre = nil, option = nil
    atitre ||= "Éditer abs-work ##{id}"
    options ||= Hash::new
    options.merge!(href:"abs_work/#{id}/edit?in=unan_admin")
    atitre.in_a(options)
  end

  def lien_delete atitre = nil, options = nil
    atitre ||= "Détruire abs-work ##{id}"
    options ||= Hash::new
    options.merge!(href:"abs_work/#{id}/delete?in=unan_admin")
    options.merge!(onclick:"if(confirm('Voulez-vous vraiment DÉTRUIRE DÉFINITIVEMENT ce travail-absolu ?')){return true}else{return false}")
    atitre.in_a(options)
  end

end #/AbsWork
end #/Program
end #/Unan
