# encoding: UTF-8
=begin

  Extension de la classe User pour le programme
  ÉCRIRE UN FILM/ROMAN EN UN AN

=end
class User

  def program
    @program ||= begin
      site.require_objet 'unan'
      begin
        raise "ID NE DEVRAIT PAS ÊTRE NIL DANS User#program" if self.id.nil?
      rescue Exception => e
        debug e.message
        debug e.backtrace.join("\n")
      end
      Unan::Program::get_current_program_of(self.id)
    end
  end

end
