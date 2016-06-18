# encoding: UTF-8
raise_unless_admin
site.require_objet 'unan'

# Pour le check des données
(site.folder_deeper_module + 'data_checker.rb').require

class UnanAdmin
class Program
class AbsPDay

  include DataChecker

  class << self

    def save_pday
      pday_id = param(:pday)[:id].to_i
      unless pday_id == 0
        UnanAdmin::Program::AbsPDay::new(pday_id).save
      else
        error "L'ID du P-Day ne peut être nil (c'est l'indice du jour-programme, de 1 à 365)."
      end
    end

  end # << self

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------
  attr_reader :id
  def initialize pday_id
    @id = pday_id
  end

  def save
    debug data_in_param
    check_if_data_valide || return
    data2save = @data_in_param
    data2save.merge!(id: id, updated_at: NOW)
    if new?
      data2save.merge!(created_at: NOW)
      debug data2save.pretty_inspect
      Unan::table_absolute_pdays.insert( data2save )
      flash "Données du P-Day ##{id} créées."
    else
      Unan::table_absolute_pdays.set( id, data2save )
      flash "Données du P-Day ##{id} actualisées."
    end
  end

  def new?
    if @is_new === nil
      @is_new = Unan::table_absolute_pdays.count(where:"id = #{id}") == 0
    end
    @is_new
  end

  def data_in_db
    @data_in_db ||= begin
      Unan::table_absolute_pdays.get(id)
    end
  end

  def data_in_param
    @data_in_param ||= param(:pday)
  end
  # Définir les données du check
  def definition_values
    {
      titre:          {type: :string, hname:"titre",        defined:true},
      description:    {type: :string, hname:"description",  defined:false},
      works:          {type: :string, hname:"travaux",      defined:false},
      minimum_points: {type: :fixnum, hname:"minimum de points"}
    }
  end


  # ---------------------------------------------------------------------
  #   Méthodes d'enregistrement
  # ---------------------------------------------------------------------
  def check_if_data_valide
    result = data_in_param.check_data( definition_values )
    if false == result.ok
      # erreurs par propriété dans result.errors ({Hash})
      error "Il y a des erreurs dans les données"
      error result.errors.collect { |k,v| v[:err_message].in_div }.join
    end

    # => Les données sont valides, on poursuit les tests de validité
    @data_in_param = result.objet # pour obtenir les données épurées

    # Les ID des travaux doivent exister
    expect_travaux_existent || ( return false )

    return true # tout est OK
  end

  def expect_travaux_existent
    errors = Array::new
    data_in_param[:works] = data_in_param[:works].nil_if_empty
    unless data_in_param[:works].nil?
      data_in_param[:works].split(' ').each do |wid|
        errors << "#{wid} n'est pas un identifiant de travail (pas un nombre)" unless wid.numeric?
        wid = wid.to_i
        errors << "Le travail (AbsWork) d'identifiant #{wid} n'existe pas" unless travail_existe?(wid)
      end
    end
    if errors.count == 0
      return true
    else
      error "ERREUR DANS LA DONNÉE DES TRAVAUX"
      error errors.collect { |err| err.in_div }.join
    end
  end

  # Return TRUE si le travail d'identifiant +wid+ existe.
  # false dans le cas contraire.
  def travail_existe? wid
    @all_works_ids ||= Unan::table_absolute_works.select( colonnes:[:id] ).collect{|h|h[:id]}
    @all_works_ids.include? wid
  end

end #/AbsPDay
end #/Program
end #/UnanAdmin

if param(:operation) == 'save_absolute_pday'
  UnanAdmin::Program::AbsPDay::save_pday
end
