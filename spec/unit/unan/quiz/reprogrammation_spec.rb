=begin
Test de la reprogrammation d'un questionnaire, lorsqu'il est de
type validation des acquis et que la note n'est pas suffisante
=end
describe 'Reprogrammation d’un questionnaire à un jour ultérieur' do
  before(:all) do
    @start_time = Time.now.to_i
    site.require_objet 'unan'
    Unan::require_module 'quiz'
    @program  = get_any_program
    @quiz     = Unan::Quiz::new(1)
  end

  let(:start_time) { @start_time }
  let(:program) { @program  }
  let(:quiz) { @quiz }

  describe 'reprogrammer_questionnaire' do
    # Note : puisque la méthode va "cloner" le travail qui a généré
    # le questionnaire à reprogrammer, il faut en créer un ici.
    before(:all) do
      @work = Unan::Program::Work::new( @program, 10 )
      @work.create
      @quiz.instance_variable_set('@work', @work)
    end
    it 'répond' do
      expect(quiz).to respond_to :reprogrammer_questionnaire
    end
    context 'sans argument' do
      it 'reprogramme le questionnaire 15 jours plus tard' do
        old_futurs = program.works.select{|hw| hw[:created_at] > start_time}
        nombre_prece_works = program.works.reject{|hw| hw[:created_at] > start_time}
        # puts "nombre_futur_works : #{nombre_futur_works.inspect}"
        # puts "nombre_prece_works : #{nombre_prece_works.inspect}"
        quiz.reprogrammer_questionnaire # <== test
        program.instance_variable_set('@works', nil)
        new_futurs = program.works.select{|hw| hw[:created_at] > start_time}
        newwork = new_futurs.last
        # puts "new_futurs : #{new_futurs.inspect}"
        expect(new_futurs.count).to eq old_futurs.count + 1
        expect(newwork[:created_at]).to be >= (start_time+7.days - 100)
      end
    end
    context 'avec un argument définissant le nombre de jours' do
      it 'reprogramme le questionnaire pour ce nombre de jours' do
        quiz.reprogrammer_questionnaire(60) # <== test
        program.instance_variable_set('@works', nil)
        new_futurs = program.works.select{|hw| hw[:created_at] > start_time}
        newwork = new_futurs.sort_by{|h|h[:created_at]}.last
        expect(newwork[:created_at]).to be >= (start_time+58.days-100)
      end
    end
  end


end
