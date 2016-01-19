# encoding: UTF-8
=begin
Définition de textes différents pour dire les choses dans les mails, pour
créer de la variété et entretenir l'illusion d'intelligence artificielle.
=end
class Unan

  # On met en identifiant un texte générique et ensuite on met des
  # phrases "synonymes" qui peuvent lui être subsitutée
  MESSAGES_TYPES = {
    il_y_a_du_nouveau_travail: [
      "il y a de nouveaux travaux pour ce nouveau jour-programme"
    ],
    # AVANT : nous espérons…
    # APRÈS : … dans votre travail, dans vos travaux
    que_vous_avez_bien: [
      "que vous avancez bien",
      "que vous avancez comme vous le voulez",
      "que vous ne rencontrez pas trop de difficulté",
      "que vos efforts sont productifs",
      "que vos efforts portent leurs fruits"
    ],
    bon_courage_pour_ce_travail: [
      "nous vous souhaitons bon courage pour ces travaux",
      "meilleurs vœux de réussite pour ces travaux"
    ],
    # Message affiché en introduction des travaux qui sont
    # en dépassement d'échéance
    depassement:[
      "Aïe… vous avez des travaux en retard.",
      "Malheureusement, vous n'êtes pas à jour des travaux à faire.",
      "Malheureusement, l'échéance de certains travaux n'est pas respectée.",
      "Attention, il vous reste des travaux à terminer."
    ],
    # Message quand l'auteur a plus de 5 travaux qui dépasse le niveau
    # d'avertissement 4, ce qui signifie qu'il est très mal, très en
    # retard
    trop_de_depassement:[
      "Vous êtes vraiment très en retard sur votre travail…",
      "Si vous vous laissez aller, vous ne serez pas en mesure d'achever votre projet.",
      "Ne croyez-vous pas qu'il serait temps de vous ressaisir ? Vous avez trop de travail en retard.",
      "Il va vous falloir maintenant une bonne dose de courage et d'effort pour rattraper le temps perdu."
    ]
    # Message qui est affiché lorsque tous les travaux de l'auteur
    # sont à jour, c'est-à-dire qu'il les a tous finis à temps (en tout
    # cas ceux qui devraient être finis)
    non_depassement: [
      "Tous vos travaux ont été exécutés dans les temps, bravo à vous ! :-)",
      "Tous vos travaux ont été exécutés à l'heure, super ! :-)",
      "Tous vos travaux sont à jour, c'est vraiment bien ! :-)"
    ]
  }

  # Renvoie un message au hasard dans un des messages ci-dessus
  # de clé +key+
  def self.choose_message(key)
    MESSAGES_TYPES[key][rand(MESSAGES_TYPES[key].count)]
  end

end # /Unan
