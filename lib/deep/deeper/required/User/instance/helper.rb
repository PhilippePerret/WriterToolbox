# encoding: UTF-8
class User

  def grade_humain
    @grade_humain ||= GRADES[grade][:hname].formate_balises_erb
  end

end #/User
