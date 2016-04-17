# encoding: UTF-8
=begin

Ce module contient :

Toutes les méthodes de transformation des textes origignaux en
(Markdown/Kramdown) transformés en fichiers LaTex conformes grâce
à la class Cnarration::Translator où l'instance est en fait un
fichier qui sera transformé.

Class Cnarration::Translator
----------------------------
L'idée est de passer
=end
class Cnarration
class Translator

  # Instance {Cnarration::Livre} du livre auquel appartient
  # le fichier courant
  attr_reader :livre

  # {String} Le path de la source
  attr_reader :path

  # {Symbol} Format de sortie
  attr_reader :output_format

  # Initialisation du fichier à transformer
  def initialize livre, path, output_format = :latex
    @livre = livre
    @path = path
    @output_format = output_format
  end

  # Pour le suivi des opérations
  def suivi; @suivi ||= livre.suivi end

  # = main =
  #
  # Méthode principale transformant le fichier Markdown
  # en fichier LaTex
  #
  # +output_format+ {Symbol} peut définir le format de sortie
  # s'il n'a pas été défini à l'instanciation du translator
  def translate output_format = nil

    return false unless page_id == 15 # pour ne traiter que cette page

    suivi << "*** Traitement de #{handler} (index: #{tdm_index})"

    # Charger si nécessaire les librairies en fonction du
    # format de sortie voulu.
    @output_format = output_format unless output_format.nil?
    self.class::load_librairies_if_needed(output_format)

    # === Les 3 phases de la correction ===

    pre_corrections

    kramdown

    post_corrections

    # === / 3 phases de la correction ===


    finalise_content

    suivi << "    -> Production fichier #{output_format}\n" +
             "       #{file_dest.to_s.in_span(class:'tiny')})"
    write_file_dest

    return true
  end


  # Kramdownage du fichier (suivant le format de sortie désiré)
  def kramdown
    suivi << "    -> kramdown du fichier"
    # debug "content dans kramdown : #{content}\n\n\n"
    options = {
      auto_ids:false,
      # html_to_native:true,
      remove_block_html_tags: false,
      header_offset: 1 # Pour commencer à \subsection si c'est ##
      }
    @content = Kramdown::Document.new(content, options).send(kramdown_method)
  end
  def kramdown_method
    @kramdown_method ||= "to_#{output_format}".to_sym
  end

  # On écrit le code translaté du fichier dans le
  # fichier latex de destination
  def write_file_dest
    file_dest.write content
  end


  # {String} Contenu du fichier qui sera translaté puis
  # finalement écrit dans le fichier latex final
  def content
    @content ||= sfile.read
  end

  # {Cnarration::Page} Instance de la page du fichier
  # courant translaté
  def page
    @page ||= Cnarration::Page::get(page_id.to_i)
  end

  # {Fixnum} ID de la page correspondant au fichier
  # Pour le suivi et également pour connaitre le placement
  # du fichier dans la table des matières.
  def page_id
    @page_id ||= begin
      pid = Cnarration::table_pages.select(where:"handler = '#{handler}' AND livre_id = #{livre.id}").keys.first
      raise "Impossible d'obtenir l'ID de la page source de path : #{path} (avec le handler '#{handler}')" if pid.nil?
      pid
    end
  end

  # {Fixnum} Index de la page dans la table des matières
  # du livre courant
  def tdm_index
    @tdm_index ||= livre.tdm.pages_ids.index(page_id)
  end

  # {String} Le path relatif dans le dossier du livre
  def handler
    @handler ||= relpath[0..-4]
  end

  def relpath
    @relpath ||= path.sub(/^#{livre.folder}\//,'')
  end
  # {String} Le path du fichier markdown source
  def sfile
    @sfile ||= SuperFile::new(path)
  end

end #/Translator
end #/Cnarration
