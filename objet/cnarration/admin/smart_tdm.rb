# encoding: utf-8
#
# Module permettant d'éditer de façon intelligente les TDM
# de la collection Narration, avec un indication maximum des
# informations.
#

require './objet/cnarration/lib/required/constants.rb'

class STdm


  # IDentifiant du livre de la table des matières courante
  attr_reader :livre_id

  def initialize livre_id
    @livre_id = livre_id.to_i

  end
  def output
    items.collect do |iid|
      Item.new(self, iid).as_li
    end.join('')
  end
  def items
    @items ||= begin
                 table_tdms.get(livre_id)[:tdm].split(',').collect{|e| e.to_i}
               end
  end
  def table_tdms
    @table_tdms ||= site.dbm_table(:cnarration, 'tdms')
  end
  def table_narration
    @table_narration ||= site.dbm_table(:cnarration, 'narration')
  end

  # -----------------------------------------------------
  # Les éléments de la table des matières, qui peuvent être
  # des pages, des sous-chapitres ou des chapitres.
  # --------------------------------------------------------
  class Item

    # Instance STdm de la table des matières qui contient
    # cet élément
    attr_reader :tdm
    attr_reader :id
    def initialize tdm, id
      @tdm = tdm
      @id = id
    end

    def as_li
      (
        div_infos +
        "[#{id}]".in_span(class: 'iid') +
        titre.in_span(class: 'ititre')
      ).in_div(class: "#{type}")
    end

    # ---------------------------------------------------------------------
    #   ÉLÉMENTS VISUELS
    # ---------------------------------------------------------------------

    # Le div contenant les informations sur la page ou le chapitre
    #
    # Noter une grande différence : pour la page, ce sont les informations
    # concernant effectivement cette page. En revanche, pour les chapitres
    # et les sous-chapitres, ce sont des informations sur les pages que
    # contient ce chapitre ou sous-chapitre
    def div_infos
      case type
      when :page
        div_infos_page
      when :sous_chapitre
        ''
      when :chapitre
        ''
      end
    end

    # DIV DES INFOS DE LA PAGE
    def div_infos_page
      (
        btn_voir_page +
        btn_edit_data +
        btn_edit_text +
        div_developpement
      ).in_div(class: 'iinfos')
    end

    def btn_edit_data
      img = '<img src="view/img/pictos/btn_data.png" title="Éditer les données" />'
      img.in_a(href: "page/#{id}/edit?in=cnarration", target: :new)
    end
    def btn_edit_text
      img = '<img src="view/img/pictos/btn_edit_sans_bord.png" title="Éditer le texte" />'
      img.in_a(href: "site/open_file?path=#{URI::escape path}", target: :new)
    end
    def btn_voir_page
      img = '<img src="view/img/pictos/oeil2_16.png" title="Lire la page/le titre" />'
      img.in_a(href: "page/#{id}/show?in=cnarration", target: :new)
    end

    # Le div qui indique le niveau de développement de la
    # page. C'est un DIV qui contient un div au-dessus pour le
    # blanc et un div en dessous pour la couleur, qui dépend du
    # niveau de développement
    def div_developpement
      ccolor =
        if developpement >= 8
          'da'
        elsif developpement >= 5
          'do'
        else
          'dw'
        end
      dh = developpement * 2
      (
        ''.in_div(class: ccolor, style: "height:#{dh}px")
      ).in_div(class: 'divdev', title: "Niveau de développement : #{developpement}/10")
    end

    # ---------------------------------------------------------------------
    #   Les données
    # ---------------------------------------------------------------------
    def titre
      @titre ||= data[:titre]
    end
    def options
      @options ||= data[:options]
    end
    def handler
      @handler ||= data[:handler]
    end

    # ----------------------------------------------------------
    # Data volatiles
    # ----------------------------------------------------------

    def path
      @path ||= File.join('.', 'data', 'unan', 'pages_cours', 'cnarration', Cnarration::LIVRES[tdm.livre_id][:folder], "#{handler}.md")
    end
    def type
      case options[0].to_i
      when 1 then :page
      when 2 then :sous_chapitre
      when 3 then :chapitre
      end
    end

    # Niveau de développement
    def developpement
      @developpement ||= options[1].to_i(11)
    end

    # ---------------------------------------------------------------------

    # Les données complètes de la table
    def data
      @data ||= table.get(id)
    end
    def table
      @table ||= tdm.table_narration
    end
  end
end #/STdm
