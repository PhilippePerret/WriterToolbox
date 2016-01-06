# encoding: UTF-8
class UnanAdmin
  class AbsEtape
    class << self
      def bind;binding()end

      # Méthode appelée pour créer une nouvelle étape
      # absolue
      def create
        flash "Création d'une étape absolue"
      end

      # Méthode appelée lors de l'édition d'une étape
      # absolue (définie ou non)
      def edit

      end

    end # << self
  end # /AbsEtape
end # /UnanAdmin
