# encoding: UTF-8
=begin

Instances Unan
--------------
Gestion d'un programme en particulier
C'est donc le programme suivi par un user inscrit et à jour de ses paiements.

=end
class Unan
class Program

  def initialize id
    @id = id
  end

  # Pour ERB
  def bind; binding() end

  # Procédure d'abandon du programme
  def abandonne
    opts    = options.split('')
    opts[2] = 1
    set(options: opts.join(''))
    user.reset_program
  end


end #/Program
end #/Unan
