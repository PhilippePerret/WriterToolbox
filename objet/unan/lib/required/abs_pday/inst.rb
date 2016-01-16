# encoding: UTF-8
=begin

Données absolues d'un jour-programme (p-day)

=end
class Unan
class Program
class AbsPDay

  include MethodesObjetsBdD

  # ID du P-Day absolu, qui sert aussi d'indice du jour 1-start.
  # Par exemple, le 12e jour porte l'ID 12
  attr_reader :id

  def initialize pday_id
    @id = pday_id
  end

end
end
end
