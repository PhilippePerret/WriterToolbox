# encoding: UTF-8
class Connexions
class Connexion
class << self
  # Retourne toutes les connexions sous la forme d'une liste
  # d'instances Connexions::Connexion
  def list_upto upto = Time.now.to_i
    get_in_table(upto).collect do |dcon|
      new(dcon[:route], dcon[:time], dcon[:ip])
    end
  end

  # Retourne la liste des connexions dans la table
  # 'connexions_per_ip' sous la forme d'une liste de Hash
  def get_in_table upto = Time.now.to_i
    whereclause = {
      where: "time < #{upto}"
    }
    site.dbm_table(:hot, 'connexions_per_ip').select(whereclause)
  end
end #/<< self
end #/Connexion
end #/Connexions
