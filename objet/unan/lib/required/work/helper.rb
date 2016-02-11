# encoding: UTF-8
class Unan
class Program
class Work

  # Type du travail au format humain (vient de abs_work)
  def human_type
    @human_type ||= abs_work.human_type_w
  end

  # Raccourci pour le titre du travail absolu
  def titre
    @titre ||= abs_work.titre
  end

end #/Work
end #/Program
end #/Unan
