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
    'no_titre'          => {bit:2, hname:"Ne pas afficher le titre du questionnaire"},
    'desordre'          => {bit:3, hname:"Présenter les questions dans le désordre"},
    # de 4 à 9  = l'identifiant du questionnaire précédente (if any)
    # de 10 à 15 = l'identifiant du questionnaire suivant (if any)

    # Si le questionnaire est multi?, c'est-à-dire que l'utilisateur peut le
    # recommencer autant de fois qu'il le désire, mais cela ne lui rapporte
    # des points que la toute première fois où il le soumet.
    'multi'             => {bit:16, hname:"Possibilité de faire plusieurs fois le même questionnaire"}
  }

  # ---------------------------------------------------------------------
  #   Options
  #
  # Définir dynamiquement toutes les méthodes d'options
  # description?, no_titre? etc.
  # Cf. la constante OPTIONS définie ci-dessus
  # OPTIONS.each do |k, dk|
  #   define_method "#{k}?" do
  #     options[dk[:bit]].to_i == 1
  #   end
  # end
  def description?;       option_true?(0)   end
  def only_points_quiz?;  option_true?(1)   end
  def no_titre?;          option_true?(2)   end
  def desordre?;          option_true?(3)   end
  def multi?;             option_true?(16)  end

  # Méthode fonctionnelle servant à définir la valeur
  # des différents bit d'option (cf. ci-dessus)
  def option_true? bit
    options.nil? ? false : ( options[bit].to_i == 1 )
  end

  def previous_version_id
    @previous_version_id ||= begin
      vip = options[4..9].to_i
      vip = nil if vip == 0
      vip
    end
  end
  def set_previous_version quiz_id
    opts = "#{options}"
    opts = opts.ljust(9,"0")
    opts[4..9] = quiz_id.to_s.rjust(6,'0')
    instance_variable_set('@previous_version', nil)
    instance_variable_set('@previous_version_id', nil)
    set(options: opts)
  end
  def next_version_id
    @next_version_id ||= begin
      vip = options[10..15].to_i
      vip = nil if vip == 0
      vip
    end
  end
  def set_next_version quiz_id
    opts = "#{options}"
    opts = opts.ljust(16,"0")
    opts[10..15] = quiz_id.to_s.rjust(6,'0')
    instance_variable_set('@next_version', nil)
    instance_variable_set('@next_version_id', nil)
    set(options: opts)
  end

end #/Quiz
end #/Unan
