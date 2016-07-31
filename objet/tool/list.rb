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

    # La liste des outils comme une liste de description, avec au-dessus
    # des liens rapides vers tous les outils
    def output
      "<dl>" +
      list.collect do |tid, tdata|
        titre = tdata[:name]
        dd_rejoindre = if tdata[:home].nil?
          ""
        else
          lien_rejoindre = "-> rejoindre #{titre}".in_a(class:'small', href:tdata[:home])
          titre = titre.in_a(href:tdata[:home], class:'inherit')
          "<dd class='right'>#{lien_rejoindre}</dd>"
        end
        "<dt>#{titre}</dt>" +
        tdata[:description].split("\n").collect do |p|
          if p.match(/#\{/)
            p.gsub!(/#\{(.*?)\}/){ eval($1) }
          end
          "<dd>#{p}</dd>"
        end.join("\n") + dd_rejoindre
      end.join("\n") +
      "</dl>"
    end

    def bloc_liens_rapides
      (
        "<h4>Accès rapide</h4>" +
        list.collect do |tid, tdata|
          (tdata[:shortname] || tdata[:name]).in_a(class:'small block', href:tdata[:home])
        end.join
      ).in_div(id:"tools_quick_list", class:'border inline fright')
    end

    # {Hash} Retourne la liste de tous les outils avec leur
    # description, tirée du fichier YAML
    def list
      @list ||= YAML.load(data_file.read.deserb).to_sym
    end

    # {SuperFile} Fichier contenant les données
    def data_file
      @data_file ||= site.folder_objet + "tool/tool_list.yaml"
    end
  end # << self
end #/Tool
end #/SiteHtml
