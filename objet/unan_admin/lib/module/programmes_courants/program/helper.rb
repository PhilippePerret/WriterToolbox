# encoding: UTF-8
class Unan
class Program


  # = main =
  #
  # Méthode principale pour afficher la ligne d'aministration
  # du programme
  #
  def as_admin_line
    (
      buttons_administration +
      span_pseudo +
      span_current_pday +
      span_duree_pause
    ).in_li(class: 'program')
  end

  def span_pseudo
    auteur.pseudo.in_span(class: 'pseudo')
  end
  def span_current_pday
    "#{current_pday}".in_span(class: 'cpday')
  end
  def span_duree_pause
    "#{pause_duration}".in_span(class: 'pausedur')
  end

  # Les boutons pour administrer le programme
  def buttons_administration
    (
      (pause? ? bouton_unpause : bouton_pause)
    ).in_div(class: 'buttons')
  end

  def bouton_pause
    'Pause'.in_a(href: "unan_admin/#{id}/programmes_courants?op=mettre_en_pause", class: 'btn mini')
  end
  def bouton_unpause
    'Restart'.in_a(href: "unan_admin/#{id}/programmes_courants?op=sortir_de_pause", class: 'btn mini')
  end

end#/Program
end#/UnanAdmin
