# encoding: UTF-8
=begin

Pour consulter le programme UN AN jour après jour

=end

# Il faut charger tous les modules du programme normal
site.require_objet 'unan'
Unan::require_module 'abs_pday'
Unan::require_module 'abs_work' # WORK !!! NOT PDAY
UnanAdmin::require_module( 'abs_pday' )
UnanAdmin::require_module( 'abs_work' )

# Il faut aussi la feuille de style de show.css du work
page.add_css( Unan::folder + "abs_work/show.css" )

# Le "p-day" courant
def ipday
  @ipday ||= Unan::Program::AbsPDay::get(param(:pday) || 1)
end

class Unan
class DAD # Pour D(ay) A(fter) D(ay)
class << self


  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def total_points_upto
    totpoints_hier = 0
    (1..(ipday.id - 1)).each do |ij|
      totpoints_hier += points_of(ij)
    end
    sitoutreussi = "(si tout réussit)".in_span(style:"font-size:0.75em")
    pointsdujour = points_of(ipday.id)
    totpoints = (totpoints_hier + pointsdujour).to_s.in_span(class:'bold')
    pointsdujour = pointsdujour == 0 ? "#{pointsdujour} points".in_span(class:'warning bold') : "#{pointsdujour} points"
    "Total des points #{sitoutreussi} : #{totpoints} = #{totpoints_hier} + #{pointsdujour} ce jour."
  end

  def points_of ij
    @works_per_pday ||= works_per_pday
    @points_per_work ||= begin
      h = {}; Unan::table_absolute_works.select(colonnes:[:points]).each do |wdata|
        h.merge! wdata[:id] => wdata[:points].to_i
      end; h
    end

    # if ij == 1
    #   debug "@works_per_pday : #{@works_per_pday.inspect}"
    #   debug "@points_per_work : #{@points_per_work.inspect}"
    # end

    # Pour calculer le nombre de points max gagnés au cours
    # du jour +ij+
    nb = 0
    (@works_per_pday[ij]||[]).each do |wid|
      nb += @points_per_work[wid]
    end
    # debug "ij=#{ij} / nb = #{nb}"
    return nb
  end

  def works_per_pday
    res = Unan::table_absolute_pdays.select(colonnes:[:works])
    h = {}; res.each do |pdata|
      next if pdata[:works].nil?
      h.merge! pdata[:id] => pdata[:works].split.collect{|i| i.to_i}
    end; h
  end

  # ---------------------------------------------------------------------
  #   Helper méthods
  # ---------------------------------------------------------------------

  # Formulaire pour choisir un jour précis
  def menu_jours
    (1..366).collect do |ijour|
      ijour_s = ijour.rjust(3,"0")
      "#{ijour_s}".in_option(selected: param(:pday) == "#{ijour}" )
    end.join.in_select(id:"pday", name:"pday", onchange:"this.form.submit()").in_form(action:"")
  end

  def lien_works_map
    "Carte des travaux".in_a(href:'abs_work/map?in=unan_admin', target:'_blank')
  end
  def lien_pdays_map
    "Carte des p-days".in_a(href:'abs_pday/map?in=unan_admin', target:'_blank')
  end
  def checkbox_fenetre_fixe
    "Fenêtre fixe".in_checkbox(checked:true, onchange:"UI.bloquer_la_page(this.checked)",class:'small')
  end

end #/<< self DAD
end #/DAD
end #/Unan


class Unan
class Program

class AbsPDay


  # RETURN un hash ordonné avec :
  #   clé : ID du work
  #   valeur :
  #     :instance     L'instance Unan::Programm::AbsWork de l'instance
  #     :pday_indice  L'indice du pday absolu qui porte ce travail
  #
  # Méthode retournant les travaux
  # qui se poursuivent sur le jour courant. Par exemple, un travail
  # commencé deux jours plus tôt et durant trois jours se poursuit
  # sur le jour courant.
  #
  # Pour procéder à l'opération, on part du jour courant et on
  # remonte jusqu'au départ (car un travail peut durer plusieurs
  # mois)
  def continuing_works

    @works_per_pday   = Unan::DAD::works_per_pday
    @durees_per_work  = Unan::Program::Work::durees_per_work

    @continuing_works = Hash::new

    return @continuing_works if id == 1

    # On boucle sur tous les jours avant le jour courant
    # debug "Recherche des travaux perdurant sur le jour #{id}"
    (1..(id-1)).each do |ij|
      debug "Test du jour #{ij}"
      diff_jours = (id - ij).freeze
      # debug "   Différence de jours avec le jour #{id} : #{diff_jours}"
      ij_works = @works_per_pday[ij] || []
      next if ij_works.empty?
      # Des works existent, on regarde s'ils peuvent perdurer
      # jusqu'au jour courant.
      # debug "   Test des travaux : #{ij_works.join}"
      ij_works.each do |wid|
        wduree = @durees_per_work[wid]
        # debug "   Durée du travail #{wid} : #{wduree}"
        # Si la durée du travail est supérieure ou égale à la
        # différence de jours entre le pday courant et le pday
        # testé, alors ce travail dure encore sur ce jour.
        if wduree >= diff_jours
          # debug "   = IL FAUT LE PRENDRE"
          # Donnée qui sera retournée
          @continuing_works.merge!(
            wid => {
              instance:     Unan::Program::AbsWork::get(wid),
              pday_indice:  ij,
              diff:         diff_jours,
              reste:        diff_jours - wduree
            }
          )
        end
      end
    end
    return @continuing_works
  end

end #/PDay

class Work
class << self

  # Méthode qui relève et renvoie toutes les durées de
  # tous les travaux. C'est un Hash avec simplement en
  # clé l'ID du work et en valeur la durée en nombre de
  # jours
  #
  # Note : La méthode ne doit s'appeler qu'une seule fois
  # @usage :    @durees_per_works ||= Unan::Program::Work::durees_per_work
  def durees_per_work
    h = Hash::new
    Unan::table_absolute_works.select(colonnes:[:duree]).each do |wdata|
      h.merge! wdata[:id] => wdata[:duree]
    end
    return h
  end

end #/<< self
end #/Work

class AbsPDay

  def edit_buttons
    return "" unless user.admin?
    (
      lien_edit("[Edit P-Day #{id}]")
    ).in_div(class:'fright tiny')
  end

end #/AbsPDay
end #/Program
end #/Unan
