# encoding: UTF-8
class SiteHtml
class Updates

  class << self


    # Création d'une nouvelle update dans la table
    def new_update data
      u = Update.new(data)
      u.create
    end

    # {BdD::Table} La table contenant l'historique des updates
    def table
      @table ||= site.db.create_table_if_needed('site_cold', 'updates')
    end

  end #<< self
end #/Updates
end #/SiteHtml
