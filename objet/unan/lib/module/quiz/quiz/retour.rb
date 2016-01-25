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
  #
  def build_output

    # TODO Voir en fonction du type de questionnaire ce qu'il faut
    # dire à l'utilisateur. Par exemple, si c'est une simple prise
    # de renseignement, il n'y a rien à faire d'autre que de le remercier.
    # En revanche, si c'est un questionnaire de validation des acquis, à
    # l'opposé, il faut refuser le questionnaire s'il ne comporte pas le
    # nombre de points suffisant (au moins 12 sur 20 ?)


    # 3 cas principaux :
    #   1. C'est un simple questionnaire, sans nécessité de points
    #   2. C'est un quiz qu'on évalue pour 1/ donner des points et
    #      2/ attribuer une note sur 20.
    #   3. C'est une validation d'acquis qu'il faut absolument
    #      réussir (question : qu'est-ce que ce veut dire "réussir"
    #      la moyenne n'est pas suffisante.)
    #      Au début, il faut 10 (la moyenne), puis, un point de plus
    #      tous les deux mois-programme.
    #
    # Quel texte en fonction des trois cas ?
    #   1. On remercie simplement l'auteur d'avoir rempli le
    #      questionnaire.
    #   2. On donne un texte suivant le résultat, sans plus
    #      On donne quand même les bonnes réponses.
    #   3. On donne un texte suivant le résultat, mais en
    #      considérant qu'il est impératif de réussir ce
    #      questionnaire.
    #      On donne quand les bonnes réponses.
    #      On donne des indications pour savoir comment améliorer
    #      son score.


    return texte_per_quiz_type + developped_texte + detail_bonnes_reponses
  end

  # Retourne le questionnaire avec les bonnes réponses mises
  # en exergue ainsi que l'explication des choix.
  # Note : Seulement pour le type quiz et validation d'acquis
  # Note : On utilise le moteur de fabrication du questionnaire modulé
  # avec les réponses de l'utilisateur.
  def detail_bonnes_reponses
    return "" if type_validation == :renseignements
    build(corrections: true)
  end

  # Le texte ne fonctionne du type de questionnaire et du résultat
  # général de l'auteur.
  def texte_per_quiz_type
    t = Array::new
    case type_validation
    when :renseignements
      # Pour les prises de renseignement et les sondages
      t << "Merci pour vos réponses."
      t << "Ce questionnaire vous fait gagner %{nombre_points} points." % quiz_points
      developped_texte = ""
    when :simple_quiz
      t << "Merci pour vos réponses."
      t << "Ce questionnaire vous fait gagner %{nombre_points} points." % quiz_points
      developped_texte = texte_per_ecart_moyenne
    when :validation_acquis
      t << "Merci pour vos réponses."
      if questionnaire_valided?
        # Le nombre de points est suffisant pour considérer les
        # notions comme acquises, on peut passer à la suite.
        t << "Vous avez réussi ce questionnaire."
      else
        # Le nombre de points n'est pas suffisant pour valider
        # les acquis. Que faut-il faire ?
        t << "Malheureusement, vos points sont insuffisants pour valider vos acquis pour le moment."
        # TODO Il faut reprogrammer le questionnaire pour dans quelques
        # jours-programme.
      end
      developped_texte = texte_per_ecart_moyenne
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
      "Vous avez #{ecart_moyenne} point" +
      (ecart_moyenne > 0 ? "au-dessus" : "en dessous") +
      "de la moyenne (qui est de #{moyenne_minimum})"
    end
    t << texte_moyenne.in_p


    t << case true
    when user_note_sur_vingt < 5
      "<strong>Une catastrophe</strong>."
    when user_note_sur_vingt < 10
      "<strong>Loin d'être convainquant</strong>."
    when user_note_sur_vingt < 12
      "<strong>Honorable</strong>".+
      "Voilà ce qu'on peut dire de ce résultat."
    when user_note_sur_vingt < 15
      "<strong>Bien</strong>."+
      "Voilà ce qu'on peut affirmer de ce résultat."
    when user_note_sur_vingt < 18
      "<strong>Très bien</strong>."
    when user_note_sur_vingt < 20
      "<strong>Vraiment très bien</strong>." +
      "Vous êtes passé#{user.f_e} à deux doigts de l'excellence."
    when user_note_sur_vingt == 20
      "C'est tout simplement excellent</strong>." +
      "Il n'y a rien à dire, vous avez brillamment exécuté ce questionnaire, les notions sont parfaitement acquises ou les opérations clairement menées. Cela présage du meilleur pour la suite, félicitation à vous !"
    end

    return t.collect{|p| p.in_p}.join
  end

end #/Quiz
end #/Unan
