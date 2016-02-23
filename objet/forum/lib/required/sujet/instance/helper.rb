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



  def div_infos_sujet
    (
      bouton_suivre_or_not  +
      info_nombre_messages  +
      info_nombre_vues      +
      info_nombre_followers +
      info_dates_sujet      +
      info_creator
    ).in_div(class:'infos_sujet')
  end

  def bouton_suivre_or_not
    if followed_by?(user.id)
      "Ne plus suivre".in_a(href:"sujet/#{id}/unfollow?in=forum", class:'btn tiny')
    else
      "Suivre".in_a(href:"sujet/#{id}/follow?in=forum", class:'btn tiny')
    end
  end
  def info_dates_sujet
    (
      "créé le&nbsp;".in_span(class:'libelle') +
      "#{created_at.as_human_date(false)}"
    ).in_span(class:'date')
  end
  def info_creator
    (
      " par&nbsp;".in_span(class:'libelle') +
      "<strong>#{creator.pseudo}</strong> (#{creator.grade_humain})".in_span
    ).in_span(class:'creator')
  end
  def info_nombre_messages
    (
      "mess:".in_span(class:'libelle') +
      "#{count || 0}".in_span
    ).in_span(class:'count')
  end
  def info_nombre_vues
    (
      "vues:".in_span(class:'libelle') +
      "#{views || 0}".in_span
    ).in_span(class:'views')
  end
  def info_nombre_followers
    (
      "suiveurs:".in_span(class:'libelle') +
      "#{followers.count}".in_span
    ).in_span(class:'followers')
  end

end # /Sujet
end # /Forum
