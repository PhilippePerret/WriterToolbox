# encoding: UTF-8
=begin

Le “Calendrier p-day” est le calendrier général de développement en p-day,
c'est-à-dire sur 365 jours (364), qui fait donc abstraction du rythme général
choisi.

=end

# Si la méthode `program` n'est pas définie, c'est que le calendrier
# est appelé hors programme (par exemple par l'administrateur). Il faut
# alors créer un programme fictif
unless respond_to?(:program)
  class ProvProgram
    attr_reader :rythme
    def initialize rythme
      @rythme = rythme
    end
  end
  def program
    @program ||= ProvProgram::new(rythme = 5)
  end
end

class Unan
class Program
class PDayMap

  DAY_HEIGHT  = 40.freeze
  DAY_WIDTH   = 60.freeze
  ROW_WIDTH   = (DAY_WIDTH * 14).freeze
  WEEK_WIDTH  = (DAY_WIDTH * 7).freeze
  WEEK_REAL_WIDTH = (WEEK_WIDTH - 6).freeze

  # Les données totales de toutes les étapes du calendrier
  # exprimé en jours-programme (p-day)
  require './data/unan/data/cal_pday'
  require './data/unan/data/listes'

  class << self

    def data_file_path
      @data_file_path ||= './objet/unan/lib/data/cal_pday.rb'
    end

    # {StringHTML} RETURN Le code HTML pour changer d'échelle,
    # c'est-à-dire de niveau d'affichage du plan
    def menu_echelle
      [
        ["1", "Vision d'ensemble"],
        ["2", "Vision médiane"],
        ["3", "Vision détaillée"]
      ].in_select(name:"niveau", class:'small exergue', onchange:"this.form.submit()", selected: param(:niveau))
    end

    # {StringHTML} RETURN Le code HTML du menu pour définir
    # le rythme
    def menu_rythme
      Unan::Program::RYTHMES.collect{|rid, rdata| [rdata[:value], "Rythme #{rdata[:hname]}"]
    }.in_select(name:'rythme', class:'small exergue', onchange:"this.form.submit()", selected: param(:rythme) || program.rythme)
    end

    # {StringHTML} RETURN Le code HTML du menu pour choisir le contenu
    # à faire apparaitre, entre "Titre", "Cours" ou "Description"
    def menu_content
      [
        ['titre',       "Titre des étapes"],
        ['description', "Description de l'étape"],
        ['cours',       "Aspect pédagogique/cours"]
      ].in_select(name:'content_type', class:'small exergue', onchange:"this.form.submit()", selected: param(:content_type))
    end

    # Définit (à l'aide du menu-select ci-dessus) le type de
    # contenu à afficher dans le tableau, entre le titre
    # de l'étape, sa description et l'aspect pédagogique
    # Note : les instances contiennent un raccourci pour
    # cette propriété de classe
    def content_type
      @content_type ||= param(:content_type) || 'titre'
    end

    # = main =
    #
    #
    # AFFICHAGE DU PLAN GÉNÉRAL DANS SA VERSION PAR JOUR OU
    # PAR DESCRIPTION/COURS
    #
    # {StringHTML} RETURN le code HTML des étapes construites
    # dans le niveau +niveau+ demandé
    def trace_whole_map niveau = 1
      case content_type
      when 'titre'
        trace_weeks +
        trace_pdays +
        PDAY_MAP.collect do |key, dkey|
          Unan::Program::PDayZone::new(dkey).trace(niveau)
        end.compact.join
      else
        PDAY_MAP.collect do |key, dkey|
          Unan::Program::PDayPlan::new(dkey).trace(niveau)
        end.compact.join
      end
    end

    # Les marques background des semaines
    def trace_weeks
      (0..1).collect do |idbl|
        left = idbl * WEEK_WIDTH
        (0..25).collect do |iquinz|
          top = iquinz * DAY_HEIGHT
          style="top:#{top}px;left:#{left}px;width:#{WEEK_REAL_WIDTH}px"
          "".in_div(class:'week', style:style)
        end.join
      end.join
    end

    def trace_pdays
      ijour = 0
      # Chaque rangée de quinzaine
      (0..25).collect do |irow|
        top = irow * DAY_HEIGHT
        # Chaque quinzaine
        (0..13).collect do |iday|
          left = iday * DAY_WIDTH
          "#{ijour += 1}".in_span(class:'numday').in_span(class:'day', style:"left:#{left}px;top:#{top}px;")
        end.join
      end.join
    end

  end # << self


  # ---------------------------------------------------------------------
  #   Unan::Program::PDayMap
  #   Instance PDayMap, un jour sur le plan
  # ---------------------------------------------------------------------

  attr_reader :index

  # +index+ L'index du jour, 1-start
  def initialize index
    @index = index
  end

  def top_px    ; @top_px     ||= "#{top}px"    end
  def left_px   ; @left_px    ||= "#{left}px"   end
  def right_px  ; @right_px   ||= "#{right}px"  end
  def bottom_px ; @bottom_px  ||= "#{bottom}px" end

  # {Fixnum} La hauteur du jour sur le plan, en pixels
  def top
    @top ||= (row * self.class::DAY_HEIGHT)
  end
  # {Fixnum} Le décalage horizontal sur le plan, en pixels
  def left
    @left ||= (column * self.class::DAY_WIDTH)
  end
  # {Fixnum} Le décalage horizontal du bord droit, en pixels
  def right
    @right ||= left + self.class::DAY_WIDTH
  end
  # {Fixnum} Le décalage vertical du bord bas, en pixels
  def bottom
    @bottom ||= top + self.class::DAY_HEIGHT
  end

  # La colonne du jour, 0-start
  def column
    @column ||= (index - 1) % 14
  end

  # La rangée du jour, 0-start
  def row
    @row ||= (index - 1) / 14
  end


end # /PDayMap

  class PDayCommon

    class << self
      # Les démarrages pour les prochains éléments s'ils ne sont
      # pas définis par un :start mais par une :duree
      def starts
        @starts ||= begin
          {
            1 => nil, 2 => nil, 3 => nil
          }
        end
      end
      # Consigne le décalage actuel
      # Note : Il est important de remettre à nil les
      # niveaux supérieurs
      def set_starts niveau, index_jour
        # debug "starts[#{niveau}] est mis à #{index_jour.inspect}"
        starts[niveau] = index_jour
        ((niveau + 1)..3).each do |iniveau|
          # debug "starts[#{iniveau}] est mis à nil"
          starts[iniveau] = nil
        end
      end

      def data_file
        @data_file ||= File.expand_path(Unan::Program::PDayMap::data_file_path)
      end

    end # << self

    attr_reader :data   # Données envoyées à l'initialisation
    attr_reader :start  # index du jour de départ
    attr_reader :end    # index du jour de fin
    attr_reader :duree  # La durée si l'élément n'est pas défini par
                        # :start et :end
    attr_reader :titre  # Titre de la zone
    attr_reader :description
    attr_reader :cours  # Aspect pédagogique de l'étape
    attr_reader :niveau # Le niveau d'importance de la zone
    attr_reader :sub    # Hash des sous-éléments de l'élément
    attr_reader :parent # L'élément parent (i.e. de niveau inférieur)
    attr_reader :line   # Ligne où est définie l'étape dans le fichier
                        # de données (utile pour l'édition)

    def initialize data, parent = nil
      # debug "\n\n*** Traitement de “#{data[:titre]}” (niveau #{data[:niveau]})"
      # debug "Un parent ? #{parent.nil? ? 'non' : 'OUI'}"
      @data   = data
      dispatch
      @parent = parent # si niveau > 1
    end

    # La durée humaine, soit exprimée en jours, soit exprimée
    # en semaine ou en mois
    # Noter que c'est la durée humaine réelle par rapport au
    # rythme choisi qui est affichée.
    def duree_humaine
      @duree_humaine ||= begin
        if nombre_jours > 14
          nombre_semaines = nombre_jours.to_f / 7
          if nombre_semaines < 4
            exacte = nombre_semaines == nombre_jours / 7
            "#{exacte ? '' : '~&nbsp;'}#{nombre_semaines.round} #{self.class::UNITE_SEMAINES}"
          else
            nombre_mois = nombre_semaines / 4
            "~&nbsp;#{nombre_mois.round} mois"
          end
        else
          "#{nombre_jours} #{self.class::UNITE_JOURS}"
        end
      end
    end

    # ---------------------------------------------------------------------

    # Dispatche les données de la zone. Permet de définir
    # start, end, titre, etc.
    def dispatch
      data.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    # Renvoie la constante de nom +name+ de Unan::Program::PDayMap
    def const name
      Unan::Program::PDayMap::const_get(name)
    end
    # ---------------------------------------------------------------------
    #   Propriétés volatiles
    # ---------------------------------------------------------------------
    def day_start
      @day_start ||= Unan::Program::PDayMap::new(start)
    end
    def day_end
      @day_end ||= Unan::Program::PDayMap::new( self.end )
    end

    def start
      @start ||= begin
        if self.class::starts[niveau].nil?
          if parent != nil
            parent.start
          else
            1
          end
        else
          self.class::starts[niveau]
        end
      end
    end

    def end
      @end ||= start + duree - 1
    end

    def rythme
      @rythme ||= param(:rythme).to_i_inn || program.rythme
    end

    def nombre_jours
      @nombre_jours ||= ((@end - @start + 1) * (5.to_f / rythme)).round
    end

  end # /PDayCommon (méthode commune, héritage)


  # ---------------------------------------------------------------------
  #   Unan::Program::PDayPlan
  #   Pour l'affichage des descriptifs ou des cours, sans
  #   dimensionnement
  # ---------------------------------------------------------------------
  class PDayPlan < PDayCommon
    UNITE_JOURS     = "jours"
    UNITE_SEMAINES  = "semaines"

    # = main =
    #
    # Méthode principale retournant le code à afficher
    # dans le plan
    def trace upto = 1
      div = (
        du_jour_au_jour +
        regle           +
        titre_mef       +
        contenu
      ).in_div(class:'step')

      # On actualise la valeur du prochain jour, dans le cas
      # où il ne serait pas défini (il n'est pas défini lorsque
      # l'élément est défini par sa durée)
      self.class::set_starts niveau, self.end + 1

      # On ajoute les sous-éléments ?

      return div
    end

    def du_jour_au_jour
      c = user.admin? ? lien_edition : ""
      c << "P-Jours #{day_start.index} à #{day_end.index} (#{duree_humaine})".in_div(class:'period')
    end

    def contenu
      intitule.in_div(class:'contenu')
    end

    # Reprise du titre pour savoir "où on se trouve"
    def titre_mef
      @titre_mef ||= begin
        titre.in_div(class:'titre')
      end
    end

    def regle
      @regle ||= begin
        "".in_span(style:"left:#{(start-1)*2}px;width:#{(duree+1)*2}px").in_div(class:'regle')
      end
    end

    def intitule
      @intitule ||= begin
        case Unan::Program::PDayMap::content_type
        when 'description'  then description
        when 'cours'        then cours
        end || titre
      end
    end

    # Lien pour éditer la donnée si c'est l'administrateur
    # Cela ouvre le fichier dans Atom à la bonne ligne
    def lien_edition
      @lien_edition ||= begin
        href = "atm://open?url=file://#{self.class::data_file}&line=#{line - 1}"
        "[edit]".in_a(href: href).in_div(class:'fright small')
      end
    end
  end
  # ---------------------------------------------------------------------
  #   Unan::Program::PDayZone
  #   Une zone, telle que définie dans PDAY_MAP
  # ---------------------------------------------------------------------
  class PDayZone < PDayCommon

    # Largeur des bordures des zones de map
    BORDER_WIDTH    = 4.freeze
    BORDER_WIDTH_PX = (BORDER_WIDTH.to_s + "px").freeze

    UNITE_JOURS     = "jrs"
    UNITE_SEMAINES  = "sems"

    class << self

    end # << self

    # ---------------------------------------------------------------------
    #   Méthodes de mise en forme
    # ---------------------------------------------------------------------

    # {StringHtml} Code HTML de la zone
    # ---------------------------------
    # Elle est souvent constituée de trois rangées, la première, la
    # dernière et les "rangées entre"
    # +upto+ Définition du niveau. Sert uniquement à savoir s'il
    # faut afficher le titre ou non. Si la zone possède le même niveau
    # que ce upto, on affiche son titre, sinon on ne l'affiche pas.
    def trace upto = 1
      @upto = upto
      div = first_row + rows_between + last_row +
            div_libelle
      # On actualise la valeur du prochain jour, dans le cas
      # où il ne serait pas défini (il n'est pas défini lorsque
      # l'élément est défini par sa durée)
      self.class::set_starts niveau, self.end + 1

      # On ajoute si nécessaire les sous-éléments au div principal
      # Noter qu'ils seront construits en dehors du div principal,
      # comme des éléments autonomes
      div << trace_sub_items
      # On retourne le code fabriqué
      return div
    end

    # Le libellé de l'élément, s'il faut le mettre
    def div_libelle
      return "" unless need_libelle?
      intitule.in_span.in_div(class:"dmap_libelle lev#{niveau}", style:style_libelle)
    end

    # Les DIVs des sous-éléments de l'élément, s'il y en
    # a
    def trace_sub_items
      return "" if niveau == @upto || false == sub_items?
      sub.collect do |subid, subdata|
        self.class::new( subdata, self ).trace( @upto )
      end.join
    end

    def need_libelle?
      @needs_libelle ||= begin
        @upto == niveau || false == sub_items?
      end
    end


    # Le style du libellé
    # On place le libellé dans la première rangée, sauf lorsque la
    # "rangée entre" est plus grande.
    def style_libelle
      @style_libelle ||= begin
        if nombre_rows > 2
          style_rows_between+"text-align:center;"
        elsif nombre_rows > 1 && width_last_row > width_first_row
          style_last_row
        else
          style_first_row
        end
      end
    end
    def intitule
      @intitule ||= "#{titre} (#{duree_humaine})"
    end

    # Code HTML pour la première rangée
    def first_row
      "".in_div(class:div_class, style: style_first_row)
    end
    def style_first_row
      @style_first_row ||= begin
        if nombre_rows == 1
          "border-width:#{border_first_row};top:#{day_start.top - 2}px;left:#{day_start.left - 4}px;width:#{width_first_row}px;height:#{height_first_row}px"
        else
          "border-width:#{border_first_row};top:#{day_start.top - 2}px;left:#{day_start.left - 4}px;width:#{width_first_row}px;height:#{height_first_row}px"
        end
      end
    end
    def border_first_row
      @border_first_row ||= begin
        if @upto == niveau || false == sub_items?
          if nombre_rows == 1
            BORDER_WIDTH_PX
          elsif nombre_rows > 2
            "#{BORDER_WIDTH_PX} 0 0 #{BORDER_WIDTH_PX}"
          else
            "#{BORDER_WIDTH_PX} 0 0 #{BORDER_WIDTH_PX}"
          end
        else
          "0"
        end
      end
    end
    def width_first_row
      @width_first_row ||= begin
        if nombre_rows == 1
          day_end.right - day_start.left - 4
        else
          const('ROW_WIDTH') - day_start.left - 4
        end
      end
    end
    def height_first_row
      @height_first_row ||= begin
        if nombre_rows == 1
          const('DAY_HEIGHT') - 2 - 4
        else
          const('DAY_HEIGHT') - 4
        end
      end
    end
    def last_row
      return "" if nombre_rows < 2
      "".in_div(class:div_class, style:style_last_row)
    end
    def style_last_row
      @style_last_row ||= begin
        "border-width:#{border_last_row};top:#{day_end.top - 2}px;left:-4px;width:#{width_last_row}px;height:#{const('DAY_HEIGHT') - 4}px"
      end
    end
    def width_last_row
      @width_last_row ||= begin
        day_end.left + const('DAY_WIDTH') - 4
      end
    end
    def border_last_row
      @border_last_row ||= begin
        if @upto == niveau || false == sub_items?
          "0 #{BORDER_WIDTH_PX} #{BORDER_WIDTH_PX} #{BORDER_WIDTH_PX}"
        else
          "0"
        end
      end
    end
    def rows_between
      return "" if nombre_rows < 3
      "".in_div(class:div_class, style:style_rows_between)
    end
    def style_rows_between
      @style_rows_between ||= begin
        "border-width:#{border_rows_between};left:-4px;width:#{width_rows_between}px;top:#{(row_start+1)*const('DAY_HEIGHT')-2}px;height:#{(nombre_rows - 2) * const('DAY_HEIGHT')}px;" #";" obligatoire en fin
      end
    end
    def width_rows_between
      @width_rows_between ||= const('ROW_WIDTH') - 4
    end
    def border_rows_between
      @border_rows_between ||= begin
        if @upto == niveau || false == sub_items?
          "0 #{BORDER_WIDTH_PX}"
        else
          "0"
        end
      end
    end

    def div_class
      @div_class ||= "dmap lev#{niveau - 1}"
    end

    def nombre_rows
      @nombre_rows ||= row_end - row_start + 1
    end

    def sub_items?
      @has_sub_items ||= sub != nil && sub.count > 0
    end

    def row_start
      @row_start ||= day_start.row
    end
    def row_end
      @row_end ||= day_end.row
    end

  end # /PDayZone


end # /Program
end # /Unan
