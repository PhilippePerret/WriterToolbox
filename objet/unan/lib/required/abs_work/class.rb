# encoding: UTF-8
class Unan
class Program
class AbsWork

  class << self

    # Instances déjà instanciées d'AbsWork
    attr_reader :instances

    def get wid
      wid = wid.to_i_inn
      @instances ||= Hash::new
      @instances[wid] ||= new(wid)
    end

    # Retourne true si le travail absolu d'ID +wid+ existe.
    def exist? wid
      table.count(where:{id: wid}) != 0
    end
    alias :exists? :exist?

    # La table "absolute_works" dans la base de données du programme
    def table
      @table ||= Unan::table_absolute_works
    end

  end # << self

end # /AbsWork
end # /Program
end # /Unan
