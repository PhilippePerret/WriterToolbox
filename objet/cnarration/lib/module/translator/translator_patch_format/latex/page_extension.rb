# encoding: UTF-8
=begin

Extension de la classe Cnarration::Page pour la translation en LaTex

=end
class Cnarration
class Page

  # Pour faire référence à cette page en LaTex.
  # Utilisé dans le \label{} et dans les \ref{} our \pageref
  # Cette référence, qui doit être unique dans le livre, est
  # composée à l'aide du handler (qui est forcément propre à
  # la page) et l'identifiant (car les titres n'ont pas de handler)
  def latex_ref
    @latex_ref ||= begin
      refs = handler.nil? ? Array::new : handler.split('/')
      refs << id.to_s
      refs.join('-').gsub(/_/,'-')
    end
  end

end #/Page
end #/Cnarration
