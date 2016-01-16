# encoding: UTF-8
class Unan
class Program
class Work

  attr_reader :id

  # ---------------------------------------------------------------------
  #   Data bdd
  # ---------------------------------------------------------------------
  def abs_work_id ; @abs_work_id ||= get(:abs_work_id) end

  # ---------------------------------------------------------------------
  #   Data volatile
  # ---------------------------------------------------------------------
  # {Unan::Program::AbsWork} Le travail absolu auquel fait référence
  # ce travail d'auteur.
  def abs_work
    @abs_work ||= Unan::Program::AbsWork::new(abs_work_id)
  end



end #/Work
end #/Program
end #/Unan
