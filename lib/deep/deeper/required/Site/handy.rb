# encoding: UTF-8

def redirect_to route
  site.redirect_to route
end

# {String} Retourne la route courante en tant que string
# Attention, ça n'est pas `site.current_route` qui retourne
# une instance {SiteHtml::Route}.
def current_route
  if site.current_route.nil?
    nil
  else
    site.current_route.route
  end
end
alias :route_courante :current_route

# Pour détruire le code HTML de la page d'accueil suite à
# une nouvelle actualité pour contraindre à l'actualiser
def destroy_home
  site.destroy_home
end

def osascript script
  site.osascript script
end



# ---------------------------------------------------------------------
#   Barrières de protection des vues et modules
# ---------------------------------------------------------------------
class ErrorUnidentified < StandardError; end
class ErrorNoAdmin < StandardError; end
class SectionInterditeError < StandardError; end
class ErrorNotOwner < StandardError; end

# Barrière anti non-identifié
# Cf. RefBook > Protection.md
def raise_unless_identified
  # raise ErrorUnidentified unless user.identified?
  error 'Vous devez être identifié(e) pour rejoindre cette page.'
  redirect_to 'user/signin'
end
# Barrière anti non-administrateur
# Si l'user n'est pas identifié, on l'envoie plutôt à l'identification
# Sinon, il rejoint la page d'erreur normale.
# Cf. RefBook > Protection.md
def raise_unless_admin
  if user.identified?
    raise ErrorNoAdmin unless user.admin?
  else
    error 'Vous devez être identifié(e) pour rejoindre cette page.'
    redirect_to 'user/signin'
  end
end
# Barrière anti non quelque chose
# Cf. RefBook > Protection.md
def raise_unless condition, error_message = nil
  raise SectionInterditeError, error_message if false == condition
end
# Cf. RefBook > Protection.md
def raise_unless_owner message = nil
  return true if user.admin?
  raise ErrorNotOwner, message
end
