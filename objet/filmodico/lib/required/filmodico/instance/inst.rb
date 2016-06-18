# encoding: UTF-8
class Filmodico

  include MethodesMySQL

  attr_reader :film_ref
  attr_reader :id

  def initialize film_ref = nil
    @film_ref = film_ref
    case film_ref
    when String then initialize_with_film_id
    when Fixnum then @id = film_ref
    else
      # C'est une création de film, ce doit être l'administrateur
      raise_unless_admin
    end
  end

  def initialize_with_film_id
    @film_id = film_ref
    @id = table.select(where:{film_id: @film_id}).first[:id]
  end

  def table
    @table ||= self.class::table_films
  end
end
