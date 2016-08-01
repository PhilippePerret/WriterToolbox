# encoding: UTF-8
=begin
Méthodes d'helper pour le forum
=end
class Forum
  # Rappel : C'est un SINGLETON

  include MethodesMainObjets

  # Pour écrire titre et sous-titre
  # @usage    <%= forum.titre_h1[("<sous titre>")] %>
  # +params+
  #     :onglets      Si true, on place les onglets sous le titre
  def titre_h1 sous_titre = nil, params = nil
    params ||= Hash::new
    t = "Le Forum".in_h1
    t << sous_titre.in_h2 unless sous_titre.nil?
    t << onglets # dans le module MethodesMainObjets
    # Pour le titre de la fenêtre
    page_title = "Forum"
    page_title += "#{site.title_separator}#{sous_titre}" if sous_titre
    page.title = page_title
    t
  end

  DATA_ONGLETS =  {
    "Soumettre"         => 'sujet/question?in=forum',
    "Messages"          => 'post/list?in=forum',
    "Sujets"            => 'sujet/list?in=forum'
  }

  def data_onglets
    hongs = DATA_ONGLETS
    if param(:forum_current_sujet)
      hongs.merge!("Revenir" => "sujet/#{param(:forum_current_sujet)}/read?in=forum")
    end
    if user.identified?
      hongs.merge!("Vos préférences" => 'user/preferences?in=forum')
    end
    if user.admin?
      hongs.merge!(
        "Administration" => "forum/dashboard"
      )
    end
    hongs
  end

end
