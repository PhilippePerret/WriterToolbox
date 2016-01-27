# encoding: UTF-8
=begin
Méthode d'instance de calcul des points pour le questionnaire
=end
class Unan
class Quiz

  def note_sur_20_for note = nil
    note ||= auteur_points
    return nil if [1,7].include?(type)
    return nil if note.nil?
    return nil if max_points.to_i == 0 # nil et zéro
    [note, max_points].sur_vingt(1)
  end

  def auteur_points
    @auteur_points ||= begin
      res = auteur.table_quiz.select(where:"quiz_id = #{id}", order:"created_at DESC", limit:1, colonnes:[:points]).values.first
      raise "Les données pour ce questionnaire sont introuvables…" if res.nil?
      res[:points]
    end
  end

  # Le nombre de points au-dessus (positif) de la moyenne
  # ou en dessous (négatif)
  def ecart_moyenne
    @ecart_moyenne ||= (auteur_note_sur_vingt - moyenne_minimum).round(2)
  end

  # La note sur 20 de l'user pour ce questionnaire, en fonction
  # de @auteur_points, le nombre de points de l'user pour ce
  # questionnaire, qui est pris soit dans le calcul courant si
  # l'user vient de faire le questionnaire, soit dans sa table
  # quiz.
  def auteur_note_sur_vingt
    @auteur_note_sur_vingt ||= note_sur_20_for(auteur_points)
  end

  # L'indice du jour courant pour l'auteur courant
  def auteur_pday_courant
    @auteur_pday_courant ||= auteur.program.current_pday(:nombre).freeze # => p.e. 36
  end

  # Note moyenne dynamique
  # ----------------------
  # Tous les deux mois programme, il faut ajouter un points.
  # Donc il faut avoir 12 pendant les 2 premiers mois, 13 les
  # mois 3-4, 14 les mois 5-6, 15 les mois 7-8, 16 les mois 8-9,
  # 17 les mois 10-11 et 18 le dernier mois.
  def moyenne_minimum
    @moyenne_minimum ||= 12 + auteur_pday_courant / 60
  end

end #/Quiz
end #/Unan
