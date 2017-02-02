# encoding: UTF-8
raise_unless user.unanunscript?
Unan.require_module 'page_cours'

class Unan
class Bureau

  # Cf. l'explication dans home.rb
  def missing_data
    @missing_data ||= begin
      nil # pour le moment
    end
  end

end #/Unan::Bureau
end #/Unan



upage = User::UPage.new(bureau.auteur, param(:pid).to_i) unless param(:pid).nil?
case param(:op)
when 'markvue'
  upage.set_vue
  # upage = User::UPage.new(bureau.auteur, param(:pid).to_i)
  bureau.auteur.reset_current_pday
  flash "Page marquée vue, vous pouvez à présent la lire."
when 'marklue'
  upage.set_lue
  # upage = User::UPage.new(bureau.auteur, param(:pid).to_i)
  bureau.auteur.reset_current_pday
when 'unmarklue'
  upage.set_a_relire
when 'addtdmperso'
  upage.set_in_tdm
  flash "Cette page a été ajoutée à votre table des matières personnelle."
end
