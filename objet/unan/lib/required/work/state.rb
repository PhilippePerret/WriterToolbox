# encoding: UTF-8
class Unan
class Program
class Work


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


end #/Work
end #/Program
end #/Unan
