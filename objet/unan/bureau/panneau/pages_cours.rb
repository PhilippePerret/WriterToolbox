# encoding: UTF-8
raise_unless user.unanunscript?

Unan::require_module 'page_cours'

class Unan
class Bureau

  def reset_all

  end

  # Cf. l'explication dans home.rb
  def missing_data
    @missing_data ||= begin
      # TODO Indiquer avec cette méthode quand des pages auraient dû être lues,
      # ou marquées lues et que la date a été dépassée.
      nil # pour le moment
    end
  end

end #/Unan::Bureau
end #/Unan



upage = User::UPage::get(bureau.auteur, param(:pid).to_i) unless param(:pid).nil?
case param(:op)
when 'markvue'
  upage.set_vue
  bureau.reset_all
  flash "Page marquée vue, vous pouvez à présent la lire."
when 'marklue'
  upage.marquer_lue
when 'unmarklue'
  upage.remarquer_a_lire
when 'addtdmperso'
  upage.set_in_tdm
  flash "Cette page a été ajoutée à votre table des matières personnelle."
end
