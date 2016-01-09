# encoding: UTF-8
class UnanAdmin
  class AbsWork
    class << self
      def bind;binding()end

      # Méthode appelée pour créer un nouveau travail
      # absolu
      def create
        flash "Création d'un travail (données absolues)"
      end

      # Méthode appelée lors de l'édition d'un travail
      # absolu (défini ou non)
      def edit

      end

    end # << self
  end # /AbsWork
end # /UnanAdmin
