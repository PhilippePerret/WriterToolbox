# encoding: UTF-8
=begin


  RÉFLEXION
    IL faudrait un truc qui indique quand la page a été pour la première
    fois achevée. Ça serait une date d'achèvement, donc une colonne
    `completed_at`. Cette colonne serait définie la première fois que
    la page est marquée achevée.

=end

class Cnarration
class << self

  # = main =
  #
  # Méthode retournant la liste des dernières pages achevées.
  #
  # Si l'utilisateur est identifié, on indique les nouvelles
  # pages depuis sa derrnière connexion.
  #
  def liste_des_dernieres_pages
    build_liste_dernieres_pages
  end

  def build_liste_dernieres_pages
    last_date_connexion =
      if user.identified?
        required_delimitation_last_connexion = true
        app.session['date_last_connexion'].to_i
      else
        required_delimitation_last_connexion = false
        nil
      end

    clause = {
      where: 'completed_at IS NOT NULL',
      order: 'completed_at DESC',
      colonnes: [:id, :completed_at],
      limit:    50
    }


    liste_last_pages = Array.new
    les_last_pages = Cnarration.table_pages.select(clause)

    # On prend la date de la première page pour voir si
    # elle date d'avant la dernière connexion de l'user
    # Si c'est le cas, on lui met tout de suite une annonce pour lui
    # dire qu'il a lu toutes les pages
    first_date_last_page = les_last_pages.first[:completed_at]

    liste_last_pages <<
      if user.identified?
        if last_date_connexion.nil?
          'Lorsque vous vous reconnecterez, vous verrez les nouvelles pages.'
        else
          if first_date_last_page < last_date_connexion
            'Aucune page n’a été terminée depuis votre dernière connexion.'
          else
            'Les nouvelles pages non lues se trouvent au-dessus de la marque de votre dernière connexion.'
          end
        end
      else
        'En vous inscrivant, vous pourrez connaitre vos nouvelles pages non lues.'
      end.in_div(class: 'small italic cadre', style:'margin-bottom:2em')

    les_last_pages.each do |hpage|


      ipage = Cnarration::Page.new(hpage[:id])

      liste_last_pages << (
        ipage.span_date_completed +
        ipage.liens_edition_if_admin +
        ipage.titre.in_a(href: "page/#{ipage.id}/show?in=cnarration") +
        ipage.titre_livre_in_span
      ).in_li(class: 'lipage')

      # Si on atteint la dernière page non lue
      if required_delimitation_last_connexion && hpage[:completed_at] > last_date_connexion
        required_delimitation_last_connexion = false
        liste_last_pages << ('-'*20 + ' Dernière connexion ' + '-'*20).in_span(class: 'red small italic')
      end

    end

    liste_last_pages.join('').in_ul(id: 'last_pages', style: 'list-style:none;')
  end

end #/<< self

  # Cnarration::Page
  class Page
    def span_date_completed
      (completed_at.as_human_date(false, false)).in_span(class: 'date')
    end
    def titre_livre_in_span
      lien_livre = livre.titre.in_a(href: "livre/#{livre_id}/tdm?in=cnarration")
      " (#{lien_livre})".in_span(class: 'small')
    end
  end
end #/ Cnarration
