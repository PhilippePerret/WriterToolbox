# encoding: UTF-8
class Evc

  # Méthode pour charger l'évènemencier YAML _evenemencier.yaml
  def import_yaml_evenemencier
    require 'yaml'
    code = yaml_path.read
    {
      '\xC3\xA9' => "é",
      '\xC3\xA8' => "è",
      '\xC3\xA0'  => 'à',
      '\xC3\xA7'  => 'ç',
      '\xE2\x80\x94'  => '“',
      '\xC2\xA0'  => ' ',
      '\xE2\x80'  => '…',
      '\xC3\xB4'  => 'ô',
      '\xC3\xAA'  => 'ê',
      '\x9C'      => '“',
      '\x9D'      => '”',
      '\xC3\xBB'  => 'û',
      '…“'        => '“',
      '…”'        => '”',
      '\xC3\xA2'  => 'â',
      '\xC3\xB9'  => 'ù',
      '\xC3\x80 ' => 'À',
      '\xA6'      => ''
    }.each do |bad, bon|
      code.gsub!(/#{Regexp::escape bad}/, bon)
    end
    yaml_path.remove
    yaml_path.write code

    ycode = YAML::load_file( yaml_path.to_s )
    # debug "data_yaml: #{data_yaml.pretty_inspect}"


    # On met les data en forme
    liste_temps_traited = Hash::new
    code_evc = ycode[:items].sort_by{|h| h['temps']}.collect do |hev|
      tps = hev['temps']
      if liste_temps_traited[tps]
        next nil
      else
        liste_temps_traited.merge!(tps => true)
      end
      "#{tps} | #{hev['duree']} | #{hev['resume']}"
    end.compact.join("\n")

    # On enregistre les données dans le fichier evc.
    evc_path.write code_evc

  end

  def yaml_path
    @yaml_path ||= SuperFile::new(File.join(folder, "_evenements.yml"))
  end
  def evc_path
    @evc_path ||= SuperFile::new( File.join(folder,"evenements.evc") )
  end

end #/Evc
