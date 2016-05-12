# encoding: UTF-8
=begin
Essai pour des tests particuliers
=end
def log mess
  SiteHtml::Test::log mess
end
class SiteHtml
class Test
  class << self

    attr_reader :failures
    attr_reader :success
    attr_reader :options

    def base_url
      if options[:online]
        site.distant_url
      else
        site.local_url
      end
    end

    def log mess; console.sub_log mess end

    # Jouer la suite de tests
    # +options+
    #   :dossier_test     Le dossier dans lequel jouer les tests
    #   :online           Si true, en online
    def run opts = nil
      @options = opts
      parse_options
      @failures           = Array::new
      @success            = Array::new
      infos[:start_time]  = Time.now
      Dir["#{folder_test_path}/**/*_spec.rb"].each do |p|
        infos[:nombre_files] += 1
        new(p).execute
      end
      infos[:end_time]      = Time.now
      display_resultat
      # debug "failures : #{failures.inspect}"
      # debug "success: #{success.inspect}"
      return "" # pour la console
    end

    def folder_test_path
      @folder_test_path ||= begin
        File.join(['.', 'test', options[:dossier_test]].compact)
      end
    end

    def display_resultat
      log resultat
    end

    def resultat
      @resultat ||= begin
        color = failures.empty? ? 'green' : 'red'
        s_failures = nombre_failures > 1 ? "s" : ""
        resume = "#{nombre_failures} failure#{s_failures} #{nombre_success} succès".in_span(class: color)

        (
          resume          +
          detail_failures +
          detail_success  +
          disp_infos_test
        )
      end
    end

    def disp_infos_test
      s_tests = infos[:nombre_tests] > 1 ? 's' : ''
      s_files = infos[:nombre_files] > 1 ? 's' : ''
      laps = (infos[:end_time] - infos[:start_time]).round(4)
      "<hr>" + (
        "#{infos[:nombre_tests]} test#{s_tests}"+
        " | durée : #{laps}" +
        " | folder: #{folder_test_path}" +
        " | #{infos[:nombre_files]} fichier#{s_files}" +
        " | "
      ).in_div(id:'test_infos')
    end

    def infos
      @infos ||= {
        start_time:   nil,
        end_time:     nil,
        nombre_files: 0, # Nombre de fichiers
        nombre_tests: 0
      }
    end

    def nombre_failures;  @nombre_failures  ||= failures.count  end
    def nombre_success;   @nombre_success   ||= success.count   end

    def detail_failures
      return "" if nombre_failures == 0
      "Failures".in_h4(class:'red') +
      failures.collect do |itest, test_name, test_line, erreur|
        (
          test_name.in_div(class:'tname err') +
          "File: #{itest.path}#{test_line ? ':'+test_line.to_s : ''}".in_div(class:'pfile') +
          erreur.to_s.in_div(class:'mess')
        ).in_div(class:'atest err')
      end.join("\n")
    end
    def detail_success
      return "" if nombre_success == 0
      "Succès".in_h4 +
      success.collect do |itest, test_name, test_line, notice|
        (
          test_name.in_div(class:'tname suc') +
          "File: #{itest.path}#{test_line ? ':'+test_line.to_s : ''}".in_div(class:'pfile') +
          notice.to_s.in_div(class:'mess')
        ).in_div(class:'atest suc')
      end.join("\n")
    end

    def parse_options
      @options ||= Hash::new

      debug "SiteHtml::Test::options : #{@options.pretty_inspect}"

    end

    def add_failure itest, test_name, line_test, message
      infos[:nombre_tests] += 1
      @failures << [itest, test_name, line_test, message]
    end
    def add_success itest, test_name, line_test, message
      infos[:nombre_tests] += 1
      @success << [itest, test_name, line_test, message]
    end
  end #/<<self
end #/SiteHtml
end #/Test
