# encoding: UTF-8
class UnanAdmin
  class AbsEtape
    class << self


      # RETURN le code HTML pour le formulaire d'édition
      # d'une étape absolue
      def form_edition_etape for_creation = false
        Vue::new('unan_admin/lib/view/etape_form').output
      end


    end # << self
  end # /AbsEtape
end # /UnanAdmin
