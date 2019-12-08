# encoding: UTF-8
class User

  def grade_humain
    @grade_humain ||= GRADES[grade][:hname].formate_balises_erb
  end

  # Cette méthode peut être surclassée dans
  # ./lib/app/required/user/helper.rb
  def htype
    "utilisa#{f_trice}"
  end

end #/User
