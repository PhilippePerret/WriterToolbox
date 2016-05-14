  # 
  # # Retourne le libellé à donner à ce test
  # #
  # # Noter qu'on ajoute le nom par défaut (nom générique du
  # # test) sauf si +no_default_name+ est true
  # def libelle no_default_name = false
  #   if test_libelle.nil?
  #     default_name
  #   else
  #     libe = test_libelle
  #     libe += "(TEST #{default_name})".in_div(class:'defname') unless no_default_name
  #     libe
  #   end
  # end
  #
  # # Méthode pour ajouter un message au test courant.
  # # Noter que c'est toujours un message de succès qui peut être enregistré
  # # ici puisqu'une failure interrompt le cas
  # def add_success message
  #   @messages << [self.file, self, message]
  # end
  #
  # def add_failure message
  #   @messages << [self.file, self, message]
  #   @has_failed = true
  # end
  #
  # def tline     ; @tline ||= options[:line]   end
  #
  # def success?  ; !failed?            end
  # def failed?   ; @has_failed == true end
  #
  #
  # # Pour parser le dernier argument envoyé à la méthode
  # # de test
  # def analyse_options
  #   opts = @options
  #   case opts
  #   when NilClass
  #     # Rien à faire
  #     return
  #   when Fixnum
  #     @test_line = opts
  #   when String
  #     # Si le dernier argument est un string, c'est le libellé
  #     # à donner au test.
  #     @test_libelle = opts
  #   when Hash
  #     @test_libelle = opts[:libelle]  if opts.has_key?(:libelle)
  #     @test_line    = opts[:line]     if opts.has_key?(:line)
  #   end
  # end
