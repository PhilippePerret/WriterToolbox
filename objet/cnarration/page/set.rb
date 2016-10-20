# encoding: UTF-8
=begin
  Module administrateur permettant de modifier les données
  d'une page par l'url
=end

# Seul un administrateur peut atteindre ce module
raise_unless_admin

property  = param(:prop)
value     = param(:val)
page      = Cnarration::Page.new(site.current_route.objet_id.to_i)

# flash "Je dois mettre la propriété #{property} à la valeur #{value} pour la page #{page.titre}"

begin

  # On fait les tests pour être sûr que l'administrateur peut
  # faire ce qu'il veut faire, sauf pour un grand manitou
  unless false # user.manitou?
    case property
    when 'nivdev'
      # Pour modifier le niveau de développement, il faut
      if page.developpement != ( value.to_i - 1 )
        raise "Vous ne pouvez qu'incrémenter le niveau de développement d'une valeur."
      end
    end
  end

# ---------------------------------------------------------------------
# Si on passe ici c'est que tout est OK
# ---------------------------------------------------------------------


  case property
  when 'nivdev'
    opts = page.options
    opts[1] = value
    page.set(options: opts)
    flash "Le niveau de développement de la page “#{page.titre}” est passé à #{value}."
    case value.to_i
    when 7
      flash "Merci de votre première lecture et correction."
    when 9
      flash "Merci de votre dernière lecture et correction."
    end
  end


rescue Exception => e
  debug e
  error e.message
end

# À la fin, on retourne forcément à la page actuelle
redirect_to :last_page
