# encoding: UTF-8
class Unan
class Program
class AbsWork

  # Les types non tâches TYPES_NOT_TASK sont définis dans les
  # liste de data

  def type_task?
    @is_type_task ||= ( false == TYPES_NOT_TASK.include?(type_w) )
  end

end #/AbsWork
end #/Program
end #/Unan
