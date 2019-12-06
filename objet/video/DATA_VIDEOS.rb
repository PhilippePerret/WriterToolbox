# encoding: UTF-8
class Video

  # Les descriptions de chaque vidéo, en attendant de mettre tout
  # ça dans une base de données
  # Noter que c'est une méthode d'instance
  def description
    case id
    when 1, 2
      <<-HTML
      Cette vidéo fait partie d'un ensemble de screencasts de l'<a href='http://www.atelier-icare.net' target='_new'><strong>atelier Icare</strong></a> dont <a href="site/phil">Philippe Perret</a>, concepteur et pédagogue de cette Boite à outils, est l'auteur.
      HTML
    when 3, 4
      <<-HTML
      Cette vidéo fait partie d'un ensemble de tutoriels sur la mise en forme des documents dans LibreOffice, proposés à l'<a href='http://www.atelier-icare.net' target='_new'><strong>atelier Icare</strong></a> et dont <a href="site/phil">Philippe Perret</a>, concepteur et pédagogue de cette Boite à outils, est l'auteur.
      HTML
    else
      ""
    end
  end

  # Valeurs possible pour +level+:
  #   1:      Tout le monde
  #   2:      Seulement les inscrits
  #   3:      Seulement les abonnés
  DATA_VIDEOS = {

    1 => {
      id:           1,
      titre:        "Écriture organique (première partie)",
      ref:          'z8p2_EofjQs',
      type:         :youtube,
      date:         "Mars 2015",
      created_at:   1425164400,
      level:        1,
      next:         nil, # ID de vidéo suivante (si suite de vidéo)
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
      level:        1,
      next:         nil, # ID de vidéo suivante, si suite
      # Pour sitemap
      description:  "Tout savoir sur les raccourcis-claviers indispensables qu'il faut connaitre pour écrire mieux et plus vite.",
      date_inv:     "2015-07-01",
      priority:     0.6
    },

    3 => {
      id:           3,
      titre:        "Mise en forme des documents avec les styles dans LibreOffice 1/3",
      ref:          'iLttkbFeWt4',
      type:         :youtube,
      date:         "Mai 2017",
      created_at:   1494799200,
      level:        1,
      previous:     nil,
      next:         4, # ID de vidéo suivante
      # Pour sitemap
      description:  "Suite de plusieurs tutoriels sur l'utilisation des styles dans les traitements de texte pour obtenir facilement les meilleurs documents.",
      date_inv:     "2017-05-15",
      priority:     0.7
    },

    4 => {
      id:           4,
      titre:        "Mise en forme des documents avec les styles dans LibreOffice 2/3",
      ref:          'sB213Mcg15I',
      type:         :youtube,
      date:         "Mai 2017",
      created_at:   1494885600,
      level:        1,
      previous:     3,
      next:         5,
      # Pour sitemap
      description:  "Suite de plusieurs tutoriels sur l'utilisation des styles dans les traitements de texte pour obtenir facilement les meilleurs documents.",
      date_inv:     "2017-05-16",
      priority:     0.9
    },
    5 => {
      id:           5,
      titre:        "Mise en forme des documents avec les styles dans LibreOffice 3/3",
      ref:          'CZt60oPHmUQ',
      type:         :youtube,
      date:         "Mai 2017",
      created_at:   1496060242,
      level:        1,
      previous:     4,
      next:         nil, # TODO Mettre la troisième quand elle sera prête
      # Pour sitemap
      description:  "Suite de plusieurs tutoriels sur l'utilisation des styles dans les traitements de texte pour obtenir facilement les meilleurs documents.",
      date_inv:     "2017-05-29",
      priority:     0.9
    }

  }
end
