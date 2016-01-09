# encoding: UTF-8
class UnanAdmin
  class AbsWork
    class << self


      # RETURN le code HTML pour le formulaire d'édition
      # d'une étape absolue
      def form_edition_travail for_creation = false
        Vue::new('unan_admin/lib/view/work_form').output
      end


    end # << self
  end # /AbsWork
end # /UnanAdmin
