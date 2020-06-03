
{.experimental: "codeReordering".}
import strutils,strscans
import sequtils
import critbits
import sea/stopwords/en
import hashes
import sea/score/tfidf
import algorithm
import os

const SlideWidth = 3
const DataDir {.strdefine.} = ""

type Doc* = tuple[id:string, content: string, score: float]

iterator slide*(content:sink seq[string]): seq[string] =
  ## slide sequnce of string by window size `SlideWidth = 3`
  if content.len > SlideWidth:
    let maxLen = max(content.len - SlideWidth + 1, 1)
    var pos:int
    for i in 0..<maxLen:
      pos = i + SlideWidth
      yield content[i..<pos]
  else:
    yield content

proc ngrams2key*(ngrams:sink seq[string]): string = 
  ngrams.join(";")

proc saveDoc*(doc:string;):string =
  ## save document to storage
  result = $hash(doc)
  let dir = if DataDir.len > 0: DataDir else: getCurrentDir()
  let file = open(dir / "docs.txt", fmAppend)
  file.write(result & " " & doc & "\n")
  file.close

proc indexDocument*(tree:var CritBitTree[seq[string]]; doc:sink string,saveDoc = false) = 
  ## index ngrams to document ids
  var words = toSeq word(doc)
  var tokens = toSeq tokenlize(words)
  var seqOfNgrams = toSeq slide(tokens)
  var key:string
  let docId = if saveDoc: saveDoc(doc) else: $hash(doc)
  for ngrams in seqOfNgrams.mitems:
    key = ngrams2key(ngrams)
    discard containsOrIncl(tree,key,newSeq[string]())
    tree[key].add docId

proc getDoc(id:string):string = 
  let dir = if DataDir.len > 0: DataDir else: getCurrentDir()
  let file = open(dir / "docs.txt", fmRead)
  for line in file.lines:
    if line.startsWith(id):
      result = line[id.len ..< line.len]
      break

proc totalDocs():int =
  let dir = if DataDir.len > 0: DataDir else: getCurrentDir()
  let file = open(dir / "docs.txt", fmRead)
  for line in file.lines:
    inc result

proc retrieveDocumentIds*(tree:var CritBitTree[seq[string]];query:string):seq[string] = 
  ## retrieve document ids
  var queryWords = toSeq word(query)
  var tokens = toSeq tokenlize(queryWords)
  var seqOfNgrams = toSeq slide(tokens)
  var key:string
  for ngrams in seqOfNgrams.mitems:
    key = ngrams2key(ngrams)
    for mids in tree.valuesWithPrefix(key):
      for id in mids:
        if id notin result:
          result.add mids

proc retrieveDocuments*(ids:sink seq[string]):seq[Doc] {.noInit.}= 
  var score:float
  result = newSeqOfCap[Doc](ids.len)
  for id in ids.mitems:
    score = 0
    let doc = getDoc(id)
    let words = toSeq word(doc)
    for word in words:
      score += tfidf(word,words,ids.len,totalDocs())
    result.add (id:id,content:doc,score:score)
  result.sortedByIt((it.score)).reverse

    
iterator tokenlize*(doc:sink seq[string]):string = 
  for x in doc.mitems:
    if x notin StopWords:
      yield x

iterator word*(doc:sink string):string = 
  var idx = 0
  let docLen = doc.len
  var entry = ""
  while idx < docLen :
    if doc[idx] notin {' '} + Punctuation:
      entry.add doc[idx]
    else:
      if entry.len > 0:
        yield entry
      entry = ""
    inc idx
  if entry.len > 0:
      yield entry

when isMainModule:
  const Sentence = "Lorem ipsum dolor sit amet".split
  assert toSeq(slide(@Sentence)).len == 3
  let words = @["A", "crit", "bit", "tree", "is", "a", "form", "of", "radix", "tree", "or", "patricia", "trie"]
  assert toSeq(word(" (A crit bit tree is a form of radix tree or patricia trie.) ")) == words
  let tokens = @["A", "crit", "bit", "tree", "form", "radix", "tree", "patricia", "trie"]
  assert toSeq(tokenlize(words)) == tokens
  assert ngrams2key(@["A", "crit", "bit"]) == "A;crit;bit"
  const Doc1 = """Let’s jump into Rust by working through a hands-on project together! This chapter introduces you to a few common Rust concepts by showing you how to use them in a real program. You’ll learn about let, match, methods, associated functions, using external crates, and more! The following chapters will explore these ideas in more detail. In this chapter, you’ll practice the fundamentals.
  We’ll implement a classic beginner programming problem: a guessing game. Here’s how it works: the program will generate a random integer between 1 and 100. It will then prompt the player to enter a guess. After a guess is entered, the program will indicate whether the guess is too low or too high. If the guess is correct, the game will print a congratulatory message and exit.
  """
  const Doc2 = """Nim is a statically typed compiled systems programming language. It combines successful concepts from mature languages like Python, Ada and Modula.
  """
 
  var tree: CritBitTree[seq[string]]
  tree.indexDocument( escape(Doc1,"",""),true)
  tree.indexDocument( escape(Doc2,"",""),true)
  let ids = tree.retrieveDocumentIds("Nim")
  echo retrieveDocuments(ids)
  let ids2 = tree.retrieveDocumentIds("real program")
  echo retrieveDocuments(ids2)
