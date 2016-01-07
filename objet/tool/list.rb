# encoding: UTF-8
=begin

Pour l'affichage de la liste des outils

=end
require 'yaml'

# Pour obtenir le tarif du programme 1 an 1 script qui est
# utilisé dans les descriptions
require './objet/unan/lib/required/unan/class.rb'

class SiteHtml
class Tool
  class << self

    # La liste des outils comme une liste de description
    def output
      "<dl>" +
      list.collect do |tid, tdata|
        titre = tdata[:name]
        titre = titre.in_a(href:tdata[:home]) unless tdata[:home].nil?
        "<dt>#{titre}</dt>" +
        tdata[:description].split("\n").collect do |p|
          if p.match(/#\{/)
            p.gsub!(/#\{(.*?)\}/){ eval($1) }
          end
          "<dd>#{p}</dd>"
        end.join("\n")
      end.join("\n") +
      "</dl>"
    end

    # {Hash} Retourne la liste de tous les outils avec leur
    # description, tirée du fichier YAML
    def list
      @list ||= begin
        YAML.load_file(data_file.to_s).to_sym
      end
    end

    # {SuperFile} Fichier contenant les données
    def data_file
      @data_file ||= site.folder_objet + "tool/tool_list.yaml"
    end
  end # << self
end #/Tool
end #/SiteHtml
