# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  def goto_section section_name
    # Pour ajouter des descriptions (nouveaux paramètres) au manuel,
    # les ajouter dans le fichier ./lib/deep/console/help.rb
    case section_name
    when "accueil", "home"          then redirect_to '/'
    when "sceno", "scenodico"       then redirect_to 'scenodico/home'
    when "nouveau_mot"              then redirect_to 'scenodico/edit'
    when "filmo", "filmodico"       then redirect_to 'filmodico/home'
    when "nouveau_film"             then redirect_to 'filmodico/edit'
    when "analyses", "analyse"      then redirect_to 'analyse/home'
    when "narration", "cnarration"  then redirect_to 'cnarration/home'
    when 'new_page_narration'       then redirect_to 'page/edit?in=cnarration'
    when 'livres_narration'         then redirect_to 'livre/list?in=cnarration'
    when 'forum'                    then redirect_to 'forum/home'
    when 'unanunscript', '1a1s', 'unan'     then redirect_to 'unan/home'
    when 'unan_admin', 'admin_unan' then redirect_to 'unan_admin/dashboard'
    # Noter que pour les méthodes ci-dessous, c'est en appelant une
    # méthode "unan new <truc>" que cette méthode est appelée
    when 'unan_new_pday'                        then redirect_to 'abs_pday/edit?in=unan_admin'
    when 'unan_new_work', 'unan_new_travail'    then redirect_to 'abs_work/edit?in=unan_admin'
    when 'unan_new_page', 'unan_new_page_cours' then redirect_to 'page_cours/edit?in=unan_admin'
    when 'unan_new_qcm', 'unan_new_quiz'        then redirect_to 'quiz/edit?in=unan_admin'
    when 'unan_new_question'                    then redirect_to 'question/edit?in=unan_admin/quiz'
    when 'unan_new_exemple'                     then redirect_to 'exemple/edit?in=unan_admin'
    else
      error "La section `#{section_name}` est inconnue où je ne sais pas comment m'y rendre."
    end

    ""
  end
end #/Console
end #/Admin
end #/SiteHtml
