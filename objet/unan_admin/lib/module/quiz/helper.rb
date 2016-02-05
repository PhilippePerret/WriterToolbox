# encoding: UTF-8
class Unan
class Quiz

  def lien_edit atitre = nil, options = nil
    atitre ||= "Éditer le quiz #{titre}"
    options ||= Hash::new
    options.merge!(href:"quiz/#{id}/edit?in=unan_admin", target: '_quiz_edition_')
    atitre.in_a(options)
  end

  def lien_delete atitre = nil, options = nil
    atitre ||= "Détruire le quiz #{titre}"
    options ||= Hash::new
    options.merge!(onclick: "if(confirm('Voulez-vous vraiment DÉTRUIRE DÉFINITIVEMENT ce quiz ?')){return true}else{return false}")
    options.merge!(href: "quiz/#{id}/delete?in=unan_admin")
    atitre.in_a(options)
  end

end #/Quiz
end #/Unan
