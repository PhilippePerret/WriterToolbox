# encoding: UTF-8
class Unan
class Program
class AbsWork


  # Retourne true si le travail est de type tâche, i.e. aucun
  # des autres types défini ci-dessous.
  def task?
    @is_type_task ||= data_type_w[:id_list] == :tasks
  end

  def quiz?
    @is_type_quiz ||= data_type_w[:id_list] == :quiz
  end

  # Retourne true si ce travail concerne une page de cours
  def page_cours?
    @is_type_page_cours ||= data_type_w[:id_list] == :pages
  end

  # Retourne true si ce travail concerne un message forum
  def forum?
    @is_type_forum ||= data_type_w[:id_list] == :forum
  end


end #/AbsWork
end #/Program
end #/Unan
