# encoding: UTF-8
class Forum
class Sujet

  def lien_write_post titre = "écrire", params = nil
    params ||= Hash::new
    params.merge!( href: "post/#{id}/create?in=forum&sid=#{id}")
    titre.in_a( params )
  end

  def lien_read titre = "Lire", params = nil
    params ||= Hash::new
    params.merge!(href:"sujet/#{id}/read?in=forum")
    titre.in_a( params )
  end

  def lien_edit titre = "edit", params = nil
    return "" if user.grade < 7
    params ||= Hash::new
    params.merge!( href: "sujet/#{id}/edit?in=forum")
    titre.in_a( params )
  end

  def lien_destroy titre = "destroy", params = nil
    return "" if user.grade < 8
    titre.in_a(href:"sujet/#{id}/destroy?in=forum", onclick:"if(confirm('Voulez-vous vraiment détruire ce sujet ?')){return true}else{return false}")
  end

end # /Sujet
end # /Forum
