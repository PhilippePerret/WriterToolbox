=begin

  En test d'intégration, on ne charge rien du site. Il faut donc créer
  une fausse class User pour gérer certaines choses, comme les tests
  des mails par exemple
=end
class User

  attr_reader :id, :pseudo, :patronyme, :mail, :sexe, :password, :cpassword

  def initialize hdata = nil
    hdata && hdata.each{|k,v| instance_variable_set("@#{k}",v)}
  end

end
