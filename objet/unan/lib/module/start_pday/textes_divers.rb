# encoding: UTF-8
=begin
Définition de textes différents pour dire les choses dans les mails, pour
créer de la variété et entretenir l'illusion d'intelligence artificielle.
=end
class Unan

  # On met en identifiant un texte générique et ensuite on met des
  # phrases "synonymes" qui peuvent lui être subsitutée
  MESSAGES = {
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
    ]
  }

end # /Unan
