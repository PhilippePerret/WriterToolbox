# encoding: UTF-8
class Unan
class Program
class AbsWork

  # Retourne true si le travail est de type tâche, i.e. aucun
  # des autres types défini ci-dessous.
  def task?
    @is_type_task ||= id_list_type == :tasks
  end

  def quiz?
    @is_type_quiz ||= id_list_type == :quiz
  end

  # Retourne true si ce travail concerne une page de cours
  def page_cours?
    @is_type_page_cours ||= id_list_type == :pages
  end

  # Retourne true si ce travail concerne un message forum
  def forum?
    @is_type_forum ||= id_list_type == :forum
  end


end #/AbsWork
end #/Program
end #/Unan
