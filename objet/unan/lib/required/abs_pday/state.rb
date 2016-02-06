# encoding: UTF-8
=begin
Extension des méthodes d'instance de AbsPDay pour les états
=end
class Unan
class Program
class AbsPDay

  def exist?
    @is_existe ||= table.count(where:{id: id}) > 0
  end

end #/AbsPDay
end #/Program
end #/Unan
