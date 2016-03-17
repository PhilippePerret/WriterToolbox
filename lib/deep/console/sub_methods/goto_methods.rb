# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  def goto_section section_name
    # Pour ajouter des descriptions (nouveaux paramètres) au manuel,
    # les ajouter dans le fichier ./lib/deep/console/help.rb
    redirection = case section_name
    when "accueil", "home"          then '/'
    when "sceno", "scenodico"       then 'scenodico/home'
    when "dico", "dictionnaire"     then 'scenodico/list'
    when "nouveau_mot"              then 'scenodico/edit'
    when "filmo", "filmodico"       then 'filmodico/home'
    when "nouveau_film"             then 'filmodico/edit'
    when "analyses", "analyse"      then 'analyse/home'
    when "narration", "cnarration"  then 'cnarration/home'
    when 'new_page_narration'       then 'page/edit?in=cnarration'
    when 'livres_narration'         then 'livre/list?in=cnarration'
    when 'forum'                    then 'forum/home'
    when 'unanunscript', '1a1s', 'unan'     then 'unan/home'
    when 'unan_admin', 'admin_unan' then 'unan_admin/dashboard'
    # Noter que pour les méthodes ci-dessous, c'est en appelant une
    # méthode "unan new <truc>" que cette méthode est appelée
    when 'unan_new_pday'                        then 'abs_pday/edit?in=unan_admin'
    when 'unan_new_work', 'unan_new_travail'    then 'abs_work/edit?in=unan_admin'
    when 'unan_new_page', 'unan_new_page_cours' then 'page_cours/edit?in=unan_admin'
    when 'unan_new_qcm', 'unan_new_quiz'        then 'quiz/edit?in=unan_admin'
    when 'unan_new_question'                    then 'question/edit?in=unan_admin/quiz'
    when 'unan_new_exemple'                     then 'exemple/edit?in=unan_admin'
    else
      error "La section `#{section_name}` est inconnue où je ne sais pas comment m'y rendre."
      nil
    end
    redirect_to redirection unless redirection.nil?
    ""
  end
end #/Console
end #/Admin
end #/SiteHtml
