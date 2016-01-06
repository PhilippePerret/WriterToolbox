# encoding: UTF-8
class Forum
  class Sujet

    # Destruction du sujet
    # En fait, on ne fait que mettre son premier bit à 1
    def destroy
      if user.grade < 8
        error "Vous n'avez pas le grade suffisant pour détruire un sujet, mon vieux…"
      else
        set(options: (options[0]="1";options))
        flash "Sujet “#{name}” détruit."
      end
      redirect_to :last_page
    end
  end
end
