# encoding: UTF-8
class FilmAnalyse
class Manuel
  class << self
    def bind; binding() end

    attr_reader :var

    # Retourne le texte d'un texte-type du dossier :
    # ./objet/analyse/manuel/texte_type/
    # +var+ Un hash qui permet de transmettre des variables au texte
    # type.
    # Si on a par exemple vars = {mon_nom: "Philippe Perret"}
    # On a dans le texte-type : "Ceci est <%= var[:mon_nom] %>"
    # (noter le singulier dans le texte)
    def texte_type relpath, vars = nil
      @var = vars
      (folder_texte_type + "#{relpath}.erb").deserb(self)
    end


    # Retourne le code HTML pour la page de chemin relatif +relpath+
    # dans +of+ qui peut être :consultation ou :redaction
    # Ce code contient le code de la page d'aide surmonté d'un lien
    # pour revenir à la table des matières.
    def page of, relpath
      Page.new(relpath, of).output
    end

    # Affichage de la table des matières propre à +of+ qui peut
    # être :consultation (manuel pour la consultation des analyses)
    # ou :redaction (manuel pour la rédaction des analyses)
    def table_of_content of
      man_folder = of.to_s
      map = data_manuel of
      # Boucle sur chaque catégorie
      # La clé correspond au nom du sous-dossier dans man_folder
      # La valeur +cdata+ contient le titre de la catégorie (:titre)
      # et les items (:items) qu'elle contient. Ces données se trouvent
      # définies dans : ./objet/analyse/lib/data/manuel_tdms.rb
      map.collect do |cid, cdata|
        cdata[:titre].in_h3 +
        cdata[:items].collect do |affixe, ditem|
          href = "manuel/#{man_folder}?in=analyse&manp=#{cid}/#{affixe}"
          data_lien = {href: href}
          data_lien.merge!(class:'small') if ditem[:smaller]
          ditem[:titre].in_a(data_lien).in_li
        end.join
      end.join.in_ul(class:'list_pages tdm')
    end

    # Retourne les données du manuel +of+ qui peut être soit
    # :consultation pour le manuel de consultation des analyse soit
    # :redaction pour le manuel de rédaction des analyses
    def data_manuel of
      load_data
      case of.to_sym
      when :consulter
        DATA_MANUEL_CONSULTATION
      else
        DATA_MANUEL_REDACTION
      end
    end

    def load_data
      data_tdm_file.require
    end

    def data_tdm_file
      @data_tdm_file ||= site.folder_objet+'analyse/manuel/DATA_TDMS.rb'
    end

    def folder_texte_type
      @folder_texte_type ||= FilmAnalyse::folder_manuel+'texte_type'
    end

  end #/<<self

  # Une page de manuel
  class Page

    # "consulter" ou "rediger"
    attr_reader :manuel_folder

    attr_reader :relpath
    attr_reader :subfolder
    attr_reader :affixe

    def initialize of, relpath
      @manuel_folder = of.to_s
      @relpath = relpath
      @subfolder, @affixe = relpath.split('/').collect{|e| e.to_sym}
    end

    # Code de sortie de la page, avec son titre
    def output
      titre + content
    end

    # Contenu de la page
    def content
      case type
      when :erb
        path_as_erb.deserb
      when :markdown
        site.require_module 'kramdown'
        path_as_markdown.kramdown
      else
        error "Type #{type} inconnu."
      end
    end

    # Le type (:erb ou :markdown ou MD) en fonction du fichier
    def type
      @type = begin
        if path_as_markdown.exist?
          :markdown
        elsif path_as_erb.exist?
          :erb
        else
          :unknown
        end
      end
    end

    def path_as_markdown
      @path_as_md ||= folder + "#{relpath}.md"
    end
    def path_as_erb
      @path_as_erb ||= folder + "#{relpath}.erb"
    end
    def folder
      @folder ||= FilmAnalyse::folder_manuel+manuel_folder
    end

    # Titre de la page, avec le lien pour revenir à la
    # table des matières
    def titre
      # debug "subfolder: #{subfolder.inspect} / affixe: #{affixe.inspect}"
      ( lien_tdm + map[subfolder][:items][affixe][:titre] ).in_h3
    end

    def lien_tdm
      @lien_tdm ||= "Table des matières".in_a(href:"manuel/#{manuel_folder}?in=analyse").in_div(class:'fright tiny')
    end

    # Map : données de la table des matières de la page
    def map
      @map ||= FilmAnalyse::Manuel::data_manuel(manuel_folder)
    end

  end
end #/Manuel
end #/FilmAnalyse
