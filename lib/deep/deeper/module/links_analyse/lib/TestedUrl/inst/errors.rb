# encoding: UTF-8
=begin

=end
class TestedPage

  # Méthode principale pour indiquer que la page est invalide
  def set_invalide
    @is_valide = false
    self.class.add_invalide route
    say "#{RETRAIT}# INVALIDE"
    say "#{RETRAIT}# LAST REFERER : #{call_froms.last}"
  end

  # Consigner une erreur dans @errors
  def error err
    @errors << err
  end


end #/TestedPage
