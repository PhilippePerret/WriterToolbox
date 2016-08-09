# encoding: UTF-8
=begin

  Méthodes pour les formulaires

    User#remplit_le_formulaire(<form ref>).avec(<data>).et_le_soumet
    User#remplit_et_soumet_le_formulaire(<form ref>).avec(<data>)

=end
# module ModuleFormLikeStepDefinition
  def on_remplit_le_formulaire(form)
    FormTest.new(form)
  end
  class User
    def remplit_le_formulaire(form)
      on_remplit_le_formulaire(form)
    end
  end

  class FormTest

    #
    attr_reader :form

    # Référence au formulaire, par exemple '#identifiant' (meilleure
    # référence)
    attr_reader :ref
    def initialize form, options = nil
      @form     = form
      @options  = options
    end

    # # Identifiant “jQuery” du formulaire, i.e. "form#<id>"
    # def jid
    #   @jid ||= "form##{id}"
    # end
    # def id
    #   @id ||= begin
    #     if ref.start_with?('#')
    #       ref[1..-1]
    #     else
    #       ref
    #     end
    #   end
    # end

    # Les données avec lesquelles il faut remplir le formulaire
    def avec dform
      # On remplit le formulaire avec les valeurs données
      dform.each do |field_ref, field_value|
        Field.new(form, field_ref, field_value).set
      end
      self
    end
    def et_le_soumet nom_bouton
      form.click_button(nom_bouton)
    end

    # ---------------------------------------------------------------------
    #   Class FormTest::Field
    #   ---------------------
    #   Un champ de formulaire
    #
    # ---------------------------------------------------------------------

    class Field
      # Le FormTest du formulaire contenant le champ
      attr_reader :form
      attr_reader :id, :data
      def initialize form, field_id, field_data
        @form = form
        @id   = field_id
        @data = field_data
      end
      def page; @page ||= form.page end
      def type
        @type ||= @data[:type] || :text
      end
      def value
        @value ||= @data[:value]
      end
      # La référence au champ
      def ref
        @ref ||= id || @data[:name]
      end
      # Méthode pour régler la valeur du champ en fonction de
      # son type
      def set
        case type
        when :text, :textarea then form.fill_in(ref, with: value)
        when :select    then form.select(value, from: ref)
        when :checkbox  then form.send(value ? :check : :uncheck, ref)
        when :radio     then form.choose(ref)
        else
          raise "Je ne sais pas encore traiter un champ de type #{type.inspect}."
        end
      end
    end

  end #/FormTest
# end #/RSpec
