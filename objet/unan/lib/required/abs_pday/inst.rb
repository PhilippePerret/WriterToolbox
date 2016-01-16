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

  def titre       ; @titre      ||= get(:titre)       end
  def works       ; @works      ||= get(:works)       end
  def works_ids   ; @works_ids  ||= works.split(' ')  end

  # La table "absolute_works" dans la base de données du programme
  def table
    @table ||= Unan::table_absolute_pdays
  end

end
end
end
