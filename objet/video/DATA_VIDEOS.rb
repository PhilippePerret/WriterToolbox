# encoding: UTF-8
class Video

  # Les descriptions de chaque vidéo, en attendant de mettre tout
  # ça dans une base de données
  # Noter que c'est une méthode d'instance
  def description
    case id
    when 1, 2
      <<-HTML
      Cette vidéo fait partie d'un ensemble de screencasts de l'<a href='http://www.atelier-icare.net' target='_new'><strong>atelier Icare</strong></a> dont Phil, concepteur et pédagogue de cette Boite à outils, est l'auteur.
      HTML
    else
      ""
    end
  end

  # Valeurs possible pour level:
  #   1:      Tout le monde
  #   2:      Seulement les inscrits
  #   3:      Seulement les abonnés
  DATA_VIDEOS = {

    # 3 => {
    #   id:     3
    #   titre:  "Écriture organique (seconde partie)",
    #   ref:    '',
    #   type:   :youtube,
    #   date:   "",
    #   level:  3
    # },

    1 => {
      id:           1,
      titre:        "Écriture organique (première partie)",
      ref:          'z8p2_EofjQs',
      type:         :youtube,
      date:         "Mars 2015",
      created_at:   1425164400,
      level:        1,
      # Pour sitemap
      description:  "Première vidéo d'un ensemble sur l'écriture de texte et de documents.",
      date_inv:     "2015-03-01",
      priority:     0.9
    },

    2 => {
      id:           2,
      titre:        "Les raccourcis-clavier indispensables",
      ref:          'XjaO9kcnGOU',
      type:         :youtube,
      date:         "Juillet 2015",
      created_at:   1436133600,
      level:        2,
      # Pour sitemap
      description:  "Tout savoir sur les raccourcis-claviers indispensables qu'il faut connaitre pour écrire mieux et plus vite.",
      date_inv:     "2015-07-01",
      priority:     0.6
    }

  }
end
