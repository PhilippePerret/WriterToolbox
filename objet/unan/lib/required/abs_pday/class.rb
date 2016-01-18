# encoding: UTF-8
=begin

Class Unan::Program::AbsPDay

=end
class Unan
class Program
class AbsPDay
  class << self

    # Instances de AbsPDay déjà instanciées
    attr_reader :instances

    # Obtenir une instance AbsPDay, soit en l'instanciant, soit
    # en la prenant dans la table des instances déjà créées.
    def get abspday_id
      abspday_id = abspday_id.to_i
      @instances ||= Hash::new
      @instances[abspday_id] ||= new(abspday_id)
    end

  end # <<self
end # /AbsPDay
end # /Program
end # /Unan
