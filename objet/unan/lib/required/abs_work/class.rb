# encoding: UTF-8
class Unan
class Program
class AbsWork

  class << self

    # La table "absolute_works" dans la base de données du programme
    def table
      @table ||= Unan::table_absolute_works
    end

  end # << self

end # /AbsWork
end # /Program
end # /Unan
