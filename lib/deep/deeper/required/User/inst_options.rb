# encoding: UTF-8
class User

  # Index d'options : 0
  # Bit administrateur
  # 0:Simple user - 1:Administrateur - 2:Super - 4:Grand Manitou
  def admin?    ; get_option(:admin) & 1 > 0 end
  def super?    ; get_option(:admin) & 2 > 0 end
  def manitou?  ; get_option(:admin) & 4 > 0 end
  def set_admin bit_admin
    raise_unless_admin # seul un administrateur peut faire ça
    set_option(:admin, get_option(:admin)|bit_admin)
  end

  # Index d'options : 1
  # {Fixnum} Grade forum de l'user (0 à 9)
  def grade ; @grade ||= get_option(:grade) end
  def set_grade new_grade ; set_option(:grade, new_grade) end

  # Retourne un Array à deux éléments dont le premier est
  # l'index de l'option de clé +key_option+ (par exemple :admin, :grade)
  # et le second est le nom de la variable d'instance qui conserve
  # cette option. Par exemple '@grade' pour le grade de l'utilisateur.
  # Si +key_option+ est l'index lui-même (Fixnum) il est retourné
  # accompagné de la valeur nil pour le nom de variable.
  # Note : Cette méthode est utilisée par les méthodes set_option
  # et get_option.
  def option_index_and_inst_name key_option
    case key_option
    when Symbol
      case key_option
      when :admin then [0, nil]
      when :grade then [1, '@grade']
      end
    when Fixnum
      [key_option, nil]
    end
  end

  # Définir la valeur d'une option
  # +index+ Offset de l'option (0-start, de 0 à 31)
  # +value+ Valeur à lui donner, de 0 à 9
  def set_option key_option, value
    index, instance_var = option_index_and_inst_name(key_option)
    opts = options.dup || ("0"*32)
    opts[index] = value.to_s
    set( options: opts )
    # On renseigne la variable d'instance si elle existe
    instance_variable_set(instance_var, value) unless instance_var.nil?
  end

  def get_option key_option
    index, instance_var = option_index_and_inst_name(key_option)
    (options||"")[index].to_i
  end


end #/User