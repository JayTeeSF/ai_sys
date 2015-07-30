todo: 
   instead of:
   {category: "animal", subcategory: "cat"}
   perhaps we need to reference our concepts with URLs (i.e. point to
   a common source: wordnet, imagenet, opencyc, nell, freebase, wikipedia, etc...)

   {category: "http://xxxx/xxx", subcategory: "http://xxx/yyy"}
   where the (sub)category object has all the other details:
   { name: "cat", part-of-speech: "noun" }

##
see if we can re-write this to work with Crystal (vs. Ruby) to enable
faster (i.e. more efficient & reasonable) processing

##
consider switching to a JSON based pstore
(vs. marshal) this should enable interoperability
(i.e. use other programming languages to process various
"brain"-snapshots

###
clauses made-up of:
  1) facts: <head> <-- # (head with empty tail)
     p, q <--
  2) rules: <head> <-- <tail>
     r <-- q
  3) query: <-- <tail>
     <-- r

rails g scaffold clause type derived-literals, -literals
rails g scaffold  literal
