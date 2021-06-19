require "../lib/ai_sys.cr"

  ais = AiSys.restore
  ais.sub("cat", "animal")
  ais.ind("pj", "cat")
  ais.sub("dog", "wolf")
  ais.sub("wolf", "animal")
  ais.rel("date", "animal", "birthday") # this should update the animal class
  ais.val("pj", "birthday", "1999-05-20") # this should update the ind. called pj!
  ais.save
