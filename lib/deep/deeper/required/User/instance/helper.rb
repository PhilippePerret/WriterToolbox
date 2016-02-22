# encoding: UTF-8
class User

  def grade_humain
    @grade_humain ||= GRADES[grade][:hname]
  end
  
end #/User
