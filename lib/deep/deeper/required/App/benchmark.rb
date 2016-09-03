# encoding: UTF-8
=begin
  Ensemble de méthode pour "benchmarker" l'application.
  L'idée est d'enregistrer chaque fois le temps d'arriver dans les
  méthodes et d'enregistrer le compte rendu dans un fichier log

  Ce fichier log est remplacé à chaque chargement de page, ou peut être
  conservé si App::KEEP_BENCHMARK_LOG est à true

  @usage

    Note : les "<-", "->" etc. sont purement conventionnel, ils
    n'interviennent pas dans le programme.

    app.benchmark '-> ma méthode'  # entrée dans une méthode
    app.benchmark '<- sortie d'une méthode' # sortie d'une méthode
    app.benchmark '--> appel_methode' # appel d'une méthode
    app.benchmark '<-- appel_method'  # retour de la méthode

    DÉMARRAGE

      Il vaut mieux laisser le benchmark fonctionner de lui-même
      grâce à un fichier ./.start_time qui est enregistré au lancement
      de l'application.

      Mais on peut cependant utiliser :

        app.benchmark_start

      … si on ne veut que benchmarker un point précis du programme
      Tous les autres serton alors évités du rapport.

    FIN

      app.benchmark_fin

      La méthode écrit le rapport dans le fichier ./debug_benchmark.log
      si demandé.

    ÉCRITURE DU RAPPORT

      app.report

      La méthode est automatiquement appelée en fin de processus si
      App::BENCHMARK_ON n'est pas mis à false

=end
class App

  # Mettre à TRUE pour obtenir le rapport de benchmark, sinon à
  # false
  BENCHMARK_ON = true

  # Pour savoir s'il faut conserver où détruire le fichier log à
  # chaque chargement.
  KEEP_BENCHMARK_LOG = false

  # +time+ est précisé par exemple si on doit appeler la méthode
  # autre part qu'à l'endroit où on veut prendre le temps
  def benchmark method_name, time = nil
    @benchmark ||= Benchmark.new(self)
    @benchmark.add(method_name, time)
  end

  def benchmark_start
    @benchmark ||= Benchmark.new(self)
    @benchmark.set_start
  end
  def benchmark_fin
    BENCHMARK_ON || return
    @benchmark.report
  end

  class Benchmark
    # {App} L'application
    attr_reader :app
    attr_reader :list

    def initialize app
      @app  = app
      @list = Array.new
    end

    # Pour ne commencer le rapport de benchmark qu'à
    # partir de ce temps
    def set_start
      @from_time = Time.now.to_f
    end
    def from_time; @from_time || 0 end


    def add method_name, time = nil
      App::BENCHMARK_ON || return
      @list << [method_name, time || Time.now.to_f]
    end

    # Le temps de lancement du programme. À l'appel du fichier index,
    # un fichier ./.start_time est enregistré avant tout autre
    # processus pour écrire le temps.
    # Si ce fichier n'a pas pu être écrit, on prend le premier
    # temps enregistré
    def start_time
      @start_time ||= begin
        if File.exist?('./.start_time')
          File.open('./.start_time','wb'){|f| f.read}.to_f
        else
          list.first[1]
        end
      end
    end
    # Méthode qui affiche le rapport final dans un fichier
    def report
      code =  "=== BENCHMARK DU #{NOW.as_human_date(true, true, ' ', 'à')} ===\n"
      code += "=== Index start : #{start_time} (#{Time.at(start_time)})\n\n"
      current_time = start_time
      code +=
        list.collect do |method_name, time|
          time > from_time || next
          t = time - start_time
          time_from_start = ("%.6f" % t).rjust(10)
          t = time - current_time
          elapsed_time    = ("%.6f" % t).rjust(10)
          current_time = time.to_f
          method_name.ljust(30) + ' ' + elapsed_time + ' ' + time_from_start
        end.compact.join("\n")
      File.open(logfile,'wb'){|f| f.write code }
    end
    # Le fichier qui contiendra le benchmark. Il est détruit à
    # chaque chargement de page si App::KEEP_BENCHMARK_LOG est false
    def logfile
      @logfile ||= begin
        f = File.join('.','debug_benchmark.log')
        App::KEEP_BENCHMARK_LOG && File.unlink(f) if File.exist?(f)
        f
      end
    end

  end #/Benchmark
end #/App
