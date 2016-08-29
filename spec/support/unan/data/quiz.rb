# encoding: UTF-8
=begin

  Des valeurs qu'on peut enregistrer dans des résultats de quiz.

  La clé dans TEST_DATA_QUIZ correspond à l'id du quiz quiz_unan et la
  valeur est une liste Array de valeurs possibles.
  Il faut donc prendre une valeur par :

      TEST_DATA_QUIZ[<id du quiz voulu>][<indice d'un résultat>]

  Puis renseigner : :user_id et :created_at
  Puis enregistrer la valeur dans la table 'resultats' de 'boite-a-outils_quiz_unan'
  (site.dbm_table(:quiz_unan, 'resultats'))

  Avec User#set_pday_to ...
  -------------------------

    Mettre dans les options (2e argument) une donnée de la forme :

      quiz: [
        {resultats: TEST_DATA_QUIZ[8][0], pday: 5, awork_id: 25},
        {resultats: TEST_DATA_QUIZ[8][0], pday: 5, awork_id: 25},
      ]

      où
        :resultats      est une valeur récupérée ci-dessous, valide
        :pday           est le jour-programme de programmation du quiz (PAS le
                        jour où il a été exécuté)
        :awork_id       est l'identifiant du travail absolu de ce quiz

=end
reps8110= <<-DAT
{"15":{"qid":15,"type":"radio","is_good":null,"is_correct":true,"rep_index":2,"good_rep":2,"best_reps":null,"points":10,"upoints":10,"better_reps":[2,4]},"13":{"qid":13,"type":"radio","is_good":null,"is_correct":true,"rep_index":0,"good_rep":0,"best_reps":null,"points":10,"upoints":10,"better_reps":[0,4]},"20":{"qid":20,"type":"radio","is_good":null,"is_correct":true,"rep_index":3,"good_rep":3,"best_reps":null,"points":10,"upoints":10,"better_reps":[3]},"14":{"qid":14,"type":"radio","is_good":null,"is_correct":true,"rep_index":1,"good_rep":1,"best_reps":null,"points":10,"upoints":10,"better_reps":[1]},"21":{"qid":21,"type":"radio","is_good":null,"is_correct":true,"rep_index":0,"good_rep":0,"best_reps":null,"points":10,"upoints":10,"better_reps":[0]},"16":{"qid":16,"type":"radio","is_good":null,"is_correct":true,"rep_index":1,"good_rep":1,"best_reps":null,"points":10,"upoints":10,"better_reps":[1]},"18":{"qid":18,"type":"radio","is_good":null,"is_correct":true,"rep_index":2,"good_rep":2,"best_reps":null,"points":10,"upoints":10,"better_reps":[2]},"19":{"qid":19,"type":"radio","is_good":null,"is_correct":true,"rep_index":1,"good_rep":1,"best_reps":null,"points":20,"upoints":20,"better_reps":[1]},"23":{"qid":23,"type":"radio","is_good":null,"is_correct":false,"rep_index":2,"good_rep":1,"best_reps":null,"points":10,"upoints":0,"better_reps":[1]},"22":{"qid":22,"type":"radio","is_good":null,"is_correct":true,"rep_index":3,"good_rep":3,"best_reps":null,"points":10,"upoints":10,"better_reps":[3]},"17":{"qid":17,"type":"radio","is_good":null,"is_correct":true,"rep_index":2,"good_rep":2,"best_reps":null,"points":10,"upoints":10,"better_reps":[2]}}
DAT

TEST_DATA_QUIZ = {
  8 => [
    {user_id: nil, quiz_id: 8, reponses: reps8110, note: 18.3, points: 110, options: '00000000', created_at: nil}
  ]
}
