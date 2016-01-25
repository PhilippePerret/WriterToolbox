# encoding: UTF-8
=begin
Méthodes d'instance de retour pour le questionnaire qui vient
d'être rempli.

Note : Peut-être serait-il bon de mettre ce fichier ailleurs, pour
pouvoir ne le charger que lorsque c'est indispensable.
=end
class Unan
class Quiz

  # = main =
  #
  # Méthode principale qui construit le retour à afficher
  # pour l'utilisateur après sa soumission du questionnaire.
  #
  # Ce retour est composé principalement de deux choses : l'affichage
  # des résultats avec les bonnes réponses en vert et les mauvaises en
  # rouge et l'affichage des raisons des résultats.
  # Il comprend également tous les textes par rapport à ces
  # résultats.
  #
  def build_output
    texte_per_quiz_type     +
    texte_per_ecart_moyenne +
    detail_bonnes_reponses
  end

  # Retourne le questionnaire avec les bonnes réponses mises
  # en exergue ainsi que l'explication des choix.
  # Note : Seulement pour le type quiz et validation d'acquis
  # Note : On utilise le moteur de fabrication du questionnaire modulé
  # avec les réponses de l'utilisateur.
  def detail_bonnes_reponses
    return "" if type_validation == :renseignements
    "Veuillez trouver ci-dessous le détail de vos bonnes et mauvaises réponses.".in_div(class:'small italic')+
    build
  end

  # Le texte ne fonctionne du type de questionnaire et du résultat
  # général de l'auteur.
  def texte_per_quiz_type
    t = Array::new
    case type_validation
    when :renseignements
      # Pour les prises de renseignement et les sondages
      t << "Merci #{user.pseudo} pour vos réponses."
      t << "Ce questionnaire vous fait gagner %{nombre_points} points." % {nombre_points: quiz_points}
    when :simple_quiz
      t << "Merci pour vos réponses."
      t << "Ce questionnaire vous fait gagner %{nombre_points} points." % {nombre_points: quiz_points}
    when :validation_acquis
      t << "Merci pour vos réponses."
      if questionnaire_valided?
        # Le nombre de points est suffisant pour considérer les
        # notions comme acquises, on peut passer à la suite.
        t << "Vous avez réussi ce questionnaire."
      else
        # Le nombre de points n'est pas suffisant pour valider
        # les acquis. Que faut-il faire ?
        t << "Malheureusement, vos points sont insuffisants pour valider vos acquis pour le moment. "+
        "Ce questionnaire est reprogrammé pour vous pour dans quelques jours pour vous laisser le temps de combler vos lacunes concernant vos réponses erronées."
        # TODO Il faut reprogrammer le questionnaire pour dans quelques
        # jours-programme.
      end
    end

    t.collect{|p|p.in_p}.join
  end

  # Le texte en fonction de la note et de l'écart par rapport
  # à la moyenne du questionnaire (rappel : la moyenne n'est pas
  # 10, elle part de 12 et varie avec le temps).
  def texte_per_ecart_moyenne
    return "" if type_validation == :renseignements
    t = Array::new
    texte_moyenne = if ecart_moyenne == 0
      "Vous avez pile la moyenne de #{moyenne_minimum}"
    else
      s = ecart_moyenne != 1 ? "s" : ""
      if ecart_moyenne < 0
        "Cependant, votre"
      else
        "Votre"
      end +
      " note est de <strong>#{user_note_sur_vingt}</strong> et "+
      "vous avez donc #{ecart_moyenne} point#{s} " +
      (ecart_moyenne > 0 ? "au-dessus" : "en dessous") +
      " de la moyenne (qui est actuellement de #{moyenne_minimum} pour les questionnaires)."
    end
    t << texte_moyenne.in_p


    t << case true
    when user_note_sur_vingt < 5
      "<strong>C'est pour le moins une catastrophe</strong>. " +
      "Si vous n'avez aucun projet sérieux concernant votre écriture, alors pas de doute : ce questionnaire est cohérent avec vos ambitions. "+
      "En revanche, si vous fomentez l'espoir de devenir un jour auteur#{user.f_e}, il est impératif que vous changiez définitivement d'attitude et que vous vous mettiez à travailler ardemment !"
    when user_note_sur_vingt < 10
      "<strong>C'est loin d'être convainquant</strong>. "+
      "Une note sous la moyenne n'est jamais une bonne chose. "+
      "Nous espérons que vous en conviendrez et que vous prendrez la décision de travailler plus sérieusement afin de parvenir à des résultats quelque peu meilleurs."
    when user_note_sur_vingt < 12 # de 10 à 12
      "<strong>C'est honorable</strong>. ".+
      "Vous avez la moyenne et c'est pour le moins honorable. " +
      "Cependant, nous vous conseillons de ne pas viser la moyenne si vous souhaitez réellement parvenir à quelque chose dans votre écriture. En effet, ce ne sont jamais les artistes dans la moyenne qui parviennent à vivre de leur métier. " +
      "Bon courage à vous !"
    when user_note_sur_vingt < 15 # de 12 à 15
      "<strong>C'est bien</strong>. "+
      "On ne peut pas affirmer que ce soit excellent, mais cette note entre 12 et 15 témoigne d'un certain acquis. "+
      "Il vous faut cependant travailler encore pour vous élever à un niveau digne d'un auteur qui ne serait plus simple apprenti."
    when user_note_sur_vingt < 18 # de 15 à 18
      "<strong>C'est très bien</strong>. " +
      "Sans être excellente, cette note n'en est pourtant pas moins le signe que vous commencez à savoir de quoi vous parlez. "+
      "Les travaux futurs devraient vous permettre de parvenir à l'excellence. Accrochez-vous !"
    when user_note_sur_vingt < 20
      "<strong>C'est vraiment très bien</strong>." +
      "Vous êtes passé#{user.f_e} à deux doigts de l'excellence."
    when user_note_sur_vingt == 20
      "<strong>C'est tout simplement excellent</strong>." +
      "Il n'y a rien à dire, vous avez brillamment exécuté ce questionnaire, les notions sont parfaitement acquises ou les opérations clairement menées. Cela présage du meilleur pour la suite, félicitation à vous !"
    end

    return t.collect{|p| p.in_p}.join
  end

end #/Quiz
end #/Unan
