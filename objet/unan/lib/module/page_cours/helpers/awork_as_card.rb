# encoding: UTF-8
=begin

  Extension des classes :
    Unan::Program::AbsWork
    Unan::Program::PageCours
  pour l'affichage de la PAGE DE COURS dans le bureau

  Noter que ces méthodes découlent de la rationalisation de
  l'affichage du bureau, avec quelques méthodes qui gèrent
  les travaux.
=end
class Unan
class Program
class AbsWork

  # Méthodes, `as_card` et `as_card_relative` qui sont appelées
  # pour retourner le code des trois modes d'affichage d'une page à lire :
  #   - travaux à démarrer (donc ici : page à marquer vue)
  #   - travaux en cours (inachevés)
  #   - travaux récents
  #
  def as_card options
    options ||= Hash.new
    options.key?(:auteur) || options.merge!(auteur: user)

    upage = User::UPage.new(options[:auteur], item_id)
    upage.output_bureau( self )
  end
  # La carte relative est identique à la carte normale,
  # c'est à l'intérieur de la construction qu'on fait
  # la différence
  alias :as_card_relative :as_card
end #/AbsWork
end #/Program
end #/Unan


class User
class UPage

  # Instance Unan::Program::AbsWork du travail appelant
  # cette instance (appelant la méthode output_bureau)
  attr_reader :awork

  # Affichage de la page de cours pour le bureau. C'est juste un
  # résumé de la page, avec un lien pour la voir entièrement et
  # des boutons pour la marquer vue, lue et terminée.
  def output_bureau awork
    @awork = awork
    (
      titre_page        +
      resume_page       +
      infos_temporelles +
      boutons_page
    ).in_div(id: "work-#{id}", class:'work page')
  end

  # Donne les informations temporelles sur la page de cours,
  # donc la date de fin de lecture principalement et le nombre
  # de jour qu'il reste pour la lire.
  def infos_temporelles
    @awork.rwork.div_echeance
  end

  def infos_if_admin
    return '' unless user.admin? || OFFLINE
    "Page ##{id}".in_span(class:'tiny', style:'margin-right:1em')
  end

  def titre_page
    (
      (
        infos_if_admin +
        "#{lien_read}"
      ).in_div(class:'fright') +
      page_cours.titre
    ).in_div(class:'titre')
  end

  # Description de la page
  # Noter qu'il s'agit de la description enregistrée dans les
  # données absolues de la page.
  def resume_page
    (
      page_cours.description
    ).in_div(class:'description')
  end

  # Lien pour lire la page dans
  def lien_read
    return "" unless vue?
    " Lire la page ".in_a(href:"page_cours/#{id}/show?in=unan", class:'inwork', target:'_page_cours_')
  end


  def boutons_page
    # Suivant le status de la UPage, il faut présenter un bouton différent
    lien_marquer_page =
      if not_vue? # <= toute nouvelle page
        title = "Marquer cette page comme vue (elle restera à marquer lue quand vous l'aurez consultée entièrement)"
        "Marquer ce travail VU".in_a(class:'warning', title:title, href:"#{bureau.route_to_this}&pid=#{id}&awid=#{awork.id}&pday=#{awork.pday}&op=markvue")
      elsif not_lue? # <= page déjà prise en compte, mais pas encore lu deux fois
        title = "Marquer cette page comme lue"
        "Marquer la page lue".in_a(title:title, href:"#{bureau.route_to_this}&pid=#{id}&op=marklue")
      else
        title = "Remettre la page à lire ci-dessus."
        "Remettre à lire".in_a(title:title, href:"#{bureau.route_to_this}&pid=#{id}&op=unmarklue")
      end

    title = "Ajouter cette page de cours à votre table des matières personnelle"
    lien_to_tdm_perso = "Ajouter à TdM perso".in_a(title: title, href:"#{bureau.route_to_this}&pid=#{id}&op=addtdmperso")

    (
      (not_vue? ? '' : lien_to_tdm_perso) +
      lien_marquer_page
    ).in_div(class:'buttons')
  end

end #/UPage
end #/User
