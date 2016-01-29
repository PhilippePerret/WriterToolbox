# encoding: UTF-8
class Forum
class Sujet

  def lien_read titre = "Lire", params = nil
    params ||= Hash::new
    params.merge!(href:"sujet/#{id}/read?in=forum")
    titre.in_a( params )
  end

  def lien_edit titre = "edit"
    return "" if user.grade < 7
    titre.in_a(href:"sujet/#{id}/edit?in=forum")
  end

  def lien_destroy titre = "destroy"
    return "" if user.grade < 8
    titre.in_a(href:"sujet/#{id}/destroy?in=forum", onclick:"if(confirm('Voulez-vous vraiment détruire ce sujet ?')){return true}else{return false}")
  end

end # /Sujet
end # /Forum
