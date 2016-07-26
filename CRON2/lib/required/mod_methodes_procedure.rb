# encoding: UTF-8
#
# Module de méthode pour les procédures
#
module MethodesProcedure

  # On redéfinit la méthode log pour qu'elle soit "transparente" mais
  # ajoute des tabulations aux messages
  alias :top_log :log
  def log mess, args = nil
      top_log "\t\t#{mess}", args
  end

end
