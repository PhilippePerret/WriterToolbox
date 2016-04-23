# encoding: UTF-8
class Unan
class Program
class Work

  def task?
    @is_type_task ||= abs_work.task?
  end
  def quiz?
    @is_type_quiz ||= abs_work.quiz?
  end
  def page_cours?
    @is_page_cours ||= abs_work.page_cours?
  end

  # Retourne true si le travail est terminé. On peut
  # aussi utiliser completed?
  def ended?
    @is_ended ||= ended_at != nil
  end
  # Return true si le travail est terminé, false dans le cas
  # contraire
  def completed?
    status == 9
  end

  # Return TRUE si le travail est en dépassement de temps, i.e.
  # s'il aurait dû être fini avant
  def depassement?
    depassement > 0
  end

  # {Fixnum} Nombre de secondes de dépassement
  # Note : c'est en secondes pour comparer à x.days
  def depassement
    @depassement ||= NOW - (self.created_at + self.duree_relative)
  end

  # Return true si le travail a été démarré par l'auteur
  # Noter que le chrono tourne même quand le travail n'a pas été
  # démarré.
  def started?
    status > 0
  end

end #/Work
end #/Program
end #/Unan
