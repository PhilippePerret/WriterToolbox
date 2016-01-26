# encoding: UTF-8
class Unan
class Quiz

  # Liste des options qui vont constituer la valeur de
  # la propriété `options` enregistrée.
  # Chaque option doit renvoyer à une méthode <option>? qui
  # retourne true si la valeur du bit est 1.
  OPTIONS = {
    'description'       => {bit:0, hname:"Afficher la description"},
    'only_points_quiz'  => {bit:1, hname:"Les questions n'apportent aucun point"},
    'no_titre'          => {bit:2, hname:"Ne pas afficher le titre du questionnaire"}
    # de 3 à 8  = l'identifiant du questionnaire précédente (if any)
    # de 9 à 14 = l'identifiant du questionnaire suivant (if any)
  }

  # ---------------------------------------------------------------------
  #   Options
  #
  # Définir dynamiquement toutes les méthodes d'options
  # description?, no_titre? etc.
  # Cf. la constante OPTIONS définie dans
  # OPTIONS.each do |k, dk|
  #   define_method "#{k}?" do
  #     options[dk[:bit]].to_i == 1
  #   end
  # end
  def description?
    options[0].to_i == 1
  end
  def only_points_quiz?
    options[1].to_i == 1
  end
  def no_titre?
    options.nil? ? false : ( options[2].to_i == 1 )
  end
  def previous_version_id
    @previous_version_id ||= begin
      vip = options[3..8].to_i
      vip = nil if vip == 0
      vip
    end
  end
  def set_previous_version quiz_id
    opts = "#{options}"
    opts = opts.ljust(9,"0")
    opts[3..8] = quiz_id.to_s.rjust(6,'0')
    instance_variable_set('@previous_version', nil)
    instance_variable_set('@previous_version_id', nil)
    set(options: opts)
  end
  def next_version_id
    @next_version_id ||= begin
      vip = options[9..14].to_i
      vip = nil if vip == 0
      vip
    end
  end
  def set_next_version quiz_id
    opts = "#{options}"
    opts = opts.ljust(15,"0")
    opts[9..14] = quiz_id.to_s.rjust(6,'0')
    instance_variable_set('@next_version', nil)
    instance_variable_set('@next_version_id', nil)
    set(options: opts)
  end

end #/Quiz
end #/Unan