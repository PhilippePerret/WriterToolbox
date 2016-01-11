# encoding: UTF-8
=begin

@usage

  site.require 'form_tools'

=end
class Page
  class FormTools
    class << self

      # Définition et restitution du prefixe qui servira pour les
      # NAME et ID des champs d'édition
      def prefix
        @prefix
      end
      def prefix= value
        @prefix = value
      end

      # Définition de l'objet qui contient actuellement
      # les valeurs. Sert à donner une valeur aux champs si
      # elles ne sont pas définies dans le formulaire (3e donnée)
      # C'est un Hash ou un objet. Si c'est un hash, les propriétés
      # seront considérées comme des clés (objet[<prop>]) sinon, elles
      # seront considérées comme des méthodes-propriétés.
      def objet
        @objet
      end
      def objet= value
        # debug "objet mis à #{value.pretty_inspect}"
        @objet = value
      end
      def objet_hash?
        if @is_objet_hash === nil
          @is_objet_hash = !!objet.instance_of?(Hash)
        end
        @is_objet_hash
      end


      # ---------------------------------------------------------------------
      #   Les différents types de champ
      #   Méthodes à appeler à l'aide de la syntaxe :
      #     form.field_<tyle> "<libelle>", "<property>", selected[, options]
      # ---------------------------------------------------------------------

      def field_select libelle, prop, selected, options = nil
        Field::new(:select, libelle, prop, selected, options).form_row
      end

      def field_textarea libelle, prop, value, options = nil
        Field::new(:textarea, libelle, prop, value, options).form_row
      end

      # Un input-text
      def field_text libelle, prop, value, options = nil
        Field::new(:text, libelle, prop, value, options).form_row
      end

      # Un input-checkbox
      def field_checkbox libelle, prop, value, options = nil
        Field::new(:checkbox, libelle, prop, value, options).form_row
      end

      # Quand le code du champ est donné de façon brute
      # Note +options[:field]+ contient le code qui sera mis
      def field_raw libelle, prop, value, options
        Field::new(:raw, libelle, prop, value, options).form_row
      end

      # Une simple description du champ, qui sera mise en petit
      # et en italique
      # @usage : form.description("<la description>")
      def field_description description, options = nil
        (
          "".in_span(class:'libelle') +
          description.in_span(class:'value descfield')
        ).in_div(class:'form_row description')
      end

      # Le bouton submit
      def submit_button button_name, options = nil
        options ||= Hash::new
        (
          (options[:libelle]||"").in_span(class:'libelle') +
          button_name.in_submit(class:'btn').in_span(class:'value')
        ).in_div(class:'form_row right')
      end


    end # << self FormTools


    # ---------------------------------------------------------------------
    #   Instance Page::FormTools::Field
    #   -------------------------------
    #   Pour la construction d'un champ en particulier
    # ---------------------------------------------------------------------
    class Field

      # {Symbol} Le type de champ, parmi :text, :textarea, :select,
      # etc.
      attr_reader :type
      attr_reader :libelle
      attr_reader :property
      attr_reader :field_value
      attr_reader :raw_options
      # Gestionnaires d'évènement
      attr_reader :onchange
      attr_reader :onclick
      attr_reader :onsubmit

      # Instanciation
      # +prop+ {String} La propriété
      def initialize type, libelle, prop, default, opts
        @type           = type
        @raw_options    = opts
        @property       = prop
        @field_value    = set_field_value(prop, default)
        @libelle        = libelle

        # Les gestionnaires d'évènement
        unless opts.nil?
          @onchange = opts.delete(:onchange)
          @onclick  = opts.delete(:onclick)
          @onsubmit = opts.delete(:onsubmit)
        end
        # Pour supprimer le libellé et le mettre en label dans un
        # checkbox
        cb_label if type == :checkbox

      end

      # ---------------------------------------------------------------------
      #   Méthodes de données
      # ---------------------------------------------------------------------

      # Méthode qui essaie de définir la valeur à donner
      # au champ de données
      def set_field_value prop, defvalue
        # debug "[set_field_value] Recherche d'une valeur pour `#{prop}`"

        # Valeur qui peut se trouver dans les paramètres, tel
        # quel ou dans un prefix défini
        param_value = if Page::FormTools::prefix.nil?
          param(prop.to_sym)
        else
          (param(Page::FormTools::prefix)||Hash::new)[prop.to_sym]
        end

        # debug "[set_field_value] param_value : #{param_value.inspect}"

        # Valeur qui peut se trouver dans l'objet, si un objet
        # a été déterminé, qui peut être une instance ou un hash
        # Cf. la propriété `objet`
        objet_value = if Page::FormTools::objet != nil
          if Page::FormTools::objet_hash?
            Page::FormTools::objet[prop.to_sym]
          elsif Page::FormTools::objet.respond_to?(prop.to_sym)
            Page::FormTools::objet.send(prop.to_sym)
          else
            nil
          end
        end

        # debug "[set_field_value] objet_value  : #{objet_value.inspect}"
        # debug "[set_field_value] defvalue     : #{defvalue.inspect}"

        param_value || objet_value || defvalue || ""
      end

      # ---------------------------------------------------------------------
      #   Méthodes de construction
      # ---------------------------------------------------------------------

      # RETURN le code complet de la rangée
      def form_row
        (
          span_libelle +
          span_value
        )
        .in_div(class:'form_row')
      end

      # RETURN le code du libellé
      # -------------------------
      def span_libelle
        @span_libelle ||= begin
          libelle.to_s.in_span( class: options[:span_libelle_class] )
        end
      end

      # RETURN {StringHTML} le code du span contenant la
      # valeur, c'est-à-dire le champ d'édition
      def span_value
        @span_value ||= begin
          (
            text_before + field + text_after
          )
          .in_span(class: options[:span_value_class])
        end
      end

      # {StringHTML} Return le champ d'édition seul
      def field
        self.send( "field_#{type}".to_sym )
      end

      # ---------------------------------------------------------------------
      #   Méthodes renvoyant le champ d'édition en fonction du
      #   type
      # ---------------------------------------------------------------------

      def field_text
        field_value.to_s.in_input_text( field_attrs )
      end
      def field_textarea
        field_value.to_s.in_textarea( field_attrs )
      end
      def field_select
        case options[:values]
        when String, Hash, Array
          options[:values].in_select( field_attrs.merge( selected: field_value ) )
        else
          raise "Je ne sais pas comment traiter une donnée de class #{options[:values].class} dans `field_select` (attendu : un Hash, un Array ou un String)."
        end
      end
      def field_checkbox
        # Note : Pour un champ checkbox, le libellé sert de texte pour la
        # case à cocher, pas de libellé (qui est supprimé par défaut)
        cb_label.in_checkbox( field_attrs.merge(checked: field_value == 'on') )
      end

      def field_radio

      end
      def field_raw
        options[:field]
      end

      # ---------------------------------------------------------------------
      #   Méthodes de valeurs volatiles
      # ---------------------------------------------------------------------

      def field_attrs
        @field_attrs ||= begin
          h = { name:field_name, id:field_id, class:options[:class] }
          h.merge!(placeholder: options[:placeholder]) if options[:placeholder]
          h.merge!(onclick: onclick)    unless onclick.nil?
          h.merge!(onchange: onchange)  unless onchange.nil?
          h.merge!(onsubmit: onsubmit)  unless onsubmit.nil?
          h
        end
      end
      # Le texte avant le champ d'édition. Renvoie un string vide
      # si aucun texte avant n'est défini.
      def text_before
        @text_before ||= begin
          t = options.delete(:text_before).nil_if_empty
          t.nil? ? "" : t.in_span
        end
      end
      # Le texte après le champs d'édition. Renvoie un string vide
      # si aucun texte après n'est défini.
      def text_after
        @text_after ||= begin
          t = options.delete(:text_after).nil_if_empty
          t == nil ? "" : t.in_span
        end
      end

      # NAME du champ
      def field_name
        @field_name ||= (prefix ? "#{prefix}[#{property}]" : property)
      end
      # ID du champ
      def field_id
        @field_id ||= (prefix ? "#{prefix}_#{property}" : property)
      end
      # Raccourci pour le préfix du nom/id de champ
      # Il peut être défini par form.prefix = "<prefix>" avant la construction
      # des champs du formulaire
      def prefix  ; @prefix ||= Page::FormTools::prefix end

      def cb_label
        @cb_label ||= begin
          lib = libelle.to_s.freeze
          @libelle = options[:libelle] || ""
          lib
        end
      end
      # ---------------------------------------------------------------------
      #   Méthodes utilitaires
      # ---------------------------------------------------------------------

      # Options par défaut pour n'importe quelle rangée de formulaire
      def options
        @options ||= begin
          opts = raw_options || Hash::new
          opts[:libelle_class] ||= ['libelle']
          opts[:libelle_class] << opts[:libelle_width] if opts[:libelle_width]
          opts[:span_libelle_class] = opts.delete(:libelle_class).join(' ')
          opts[:span_value_class] ||= 'value'
          opts
        end
      end

    end # /Field
  end # /FormTools
end # /Page

def form
  @form ||= Page::FormTools
end
