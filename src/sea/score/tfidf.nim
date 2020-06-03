import sequtils
import math 

proc tf*(word:string, words: sink seq[string]):float = 
  ## Term Frequency
  let c = count(words, word)
  c / words.len

proc docsContains*(word:string, docs:sink seq[seq[string]]):int = 
  for doc in docs:
    if word in doc:
      inc result

proc idf*(word:string, docs:sink seq[seq[string]]):float = 
  ## Inverse Document Frequency
  log10(len(docs) / (1 + docsContains(word, docs)))

proc idf*(word:string,docsContains:int,allDocs:int ):float = 
  ## Inverse Document Frequency
  log10(allDocs / (1 + docsContains))

proc tfidf*(word:string, words: sink seq[string], docs:sink seq[seq[string]]):float =
  tf(word, words) * idf(word, docs)

proc tfidf*(word:string, words: sink seq[string], docs:int,allDocs:int):float =
  tf(word, words) * idf(word, docs,allDocs)