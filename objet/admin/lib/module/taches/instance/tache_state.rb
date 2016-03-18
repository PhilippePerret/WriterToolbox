# encoding: UTF-8
class Admin
class Todolist
class Tache

  def ended?
    state == 9
  end
  alias :complete? :ended?

end #/Tache
end #/Todolist
end #/Admin
