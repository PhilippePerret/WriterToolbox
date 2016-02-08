# encoding: UTF-8
class Unan
class Aide
  class << self

    # Retourne un lien vers l'aide
    # Cf. le fichier du refbook Vues > Méthodes_LIENS.md
    def link_to relpath, titre = nil, options = nil
      data_link = case relpath
      when Symbol
        map_symbols_path.require
        hdata = SYMBOLS_MAP[relpath]
        hdata[:t] = titre unless titre.nil?
        hdata
      when String
        {t: titre, rp: relpath}
      else raise "Le premier argument de Unan::Aide::link_to doit être un String ou un Symbol (existant)"
      end

      attrs = { href: "#{data_link[:rp]}?in=unan/aide" }
      attrs.merge!(options) unless options.nil?
      data_link[:t].in_a( attrs )
    end

    # {SuperFile} Fichier contenant la définition des liens
    # symboliques pour l'aide, au cas où
    def map_symbols_path
      @map_symbols_path ||= site.folder_objet+'unan/aide/SYMBOLS_MAP.rb'
    end

    def load_data
      (site.folder_objet + 'unan/aide/DATA_TDM.rb').require
      # => DATA_TDM_AIDE
    end

  end # << self
end # /Aide
end # /Unan
