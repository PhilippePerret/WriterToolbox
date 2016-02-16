# encoding: UTF-8
class ::String

  def formate_balises_crochets
    str = self
    str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){ lien.mot($1.to_i, $2.to_s) }
    str.gsub!(/FILM\[(.*?)\]/){ lien.film($1.to_s) }
    return str
  end

end #/String
