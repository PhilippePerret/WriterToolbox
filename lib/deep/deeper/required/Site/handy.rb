# encoding: UTF-8

def redirect_to route
  site.redirect_to route
end


# ---------------------------------------------------------------------
#   Barrières de protection des vues et modules
# ---------------------------------------------------------------------
class ErrorUnidentified < StandardError; end
class ErrorNoAdmin < StandardError; end

# Barrière anti non-identifié
# Cf. RefBook > Protection.md
def raise_unless_identified
  raise ErrorUnidentified unless user.identified?
end
# Barrière anti non-administrateur
# Cf. RefBook > Protection.md
def raise_unless_admin
  raise ErrorNoAdmin unless user.admin?
end
