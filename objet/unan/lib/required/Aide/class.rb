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
        hdata[:titre] = titre unless titre.nil?
      when String
        {titre: titre, relpath: relpath}
      else raise "Le premier argument de Unan::Aide::link_to doit être un String ou un Symbol (existant)"
      end

      attrs = { href: "#{data_link[:relpath]}?in=unan/aide" }
      attrs.merge!(options) unless options.nil?
      data_link[:titre].in_a( attrs )
    end

    # {SuperFile} Fichier contenant la définition des liens
    # symboliques pour l'aide, au cas où
    def map_symbols_path
      @map_symbols_path ||= Unan::folder_lib + 'data/aide_symbols_map.rb'
    end
  end # << self
end # /Aide
end # /Unan
