# encoding: UTF-8
=begin
Méthodes d'helper pour le forum
=end
class Forum
  # Rappel : C'est un SINGLETON

  # Pour écrire titre et sous-titre
  # @usage    <%= forum.titre_h1[("<sous titre>")] %>
  # +params+
  #     :onglets      Si true, on place les onglets sous le titre
  def titre_h1 sous_titre = nil, params = nil
    params ||= Hash::new
    t = "Forum".in_h1
    t << onglets if params[:onglets]
    t << sous_titre.in_h2 unless sous_titre.nil?
    # Pour le titre de la fenêtre
    page_title = "Forum"
    page_title += "#{site.title_separator}#{sous_titre}" if sous_titre
    page.title = page_title
    t
  end

  # Pour afficher les onglets généraux
  # @usage:  <%= forum.onglets %>
  def onglets
    hongs = {
      "Nouvelle question" => 'sujet/question?in=forum',
      "Messages"          => 'post/list?in=forum',
      "Sujets"            => 'sujet/list?in=forum',
      "Vos préférences"   => 'user/preferences?in=forum'
    }

    if param(:forum_current_sujet)
      hongs.merge!("Revenir" => "sujet/#{param(:forum_current_sujet)}/read?in=forum")
    end

    hongs.
      collect{|tita, href| tita.in_a(href:href, class:'onglet')}.
      join('').
      in_div(id:"onglets", style:'margin:0!important')
  end

end
