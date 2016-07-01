# encoding: UTF-8

class Unan
  class << self
    # On surclasse la méthode locale pour qu'elle aille lire les
    # informations en online
    def table_programs
      @table_programs ||= site.dbm_table(:unan, 'programs', online = true)
    end
  end
end
