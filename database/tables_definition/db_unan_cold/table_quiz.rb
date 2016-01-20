# encoding: UTF-8
def schema_table_unan_cold_quiz
  @schema_table_unan_cold_quiz ||= {
    id:         {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    titre:  {type:"VARCHAR(255)", constraint:"NOT NULL"},

    questions: {type:"BLOB"}

  }
end
