# encoding: UTF-8
=begin
Extension de la class SuperFile pour le traitement avec les
analyse.
=end
class SuperFile

  def deyamelize
    # YAML::parse(read)
    # YAML::load(read)
    Psych.load_file(self.to_s).to_sym
  end

  def yaml_content
    @yaml_content ||= self.deyamelize
  end

end
