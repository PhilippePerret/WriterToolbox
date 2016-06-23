# encoding: UTF-8
=begin

  Extension pour les messages et textes


=end
class User
class CurrentPDay

  # Grande table contenant les messages en fonction du retard
  # et du fait qu'on se trouve au début, au milieu ou à la fin
  # du programme.
  def data_messages
    @data_messages ||= YAML::load_file(_('texte/messages_retards.yaml'))
  end

end #/CurrentPDay
end #/User
