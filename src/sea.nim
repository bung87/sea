
{.experimental: "codeReordering".}
import strutils,strscans
import sequtils
import critbits
import sea/stopwords/en
import hashes

const SlideWidth = 3


iterator slide*(content:sink seq[string]): seq[string] =
  ## slide sequnce of string by window size `SlideWidth = 3`
  let maxLen = max(content.len - SlideWidth + 1, 1)
  var pos:int
  for i in 0..<maxLen:
      pos = i + SlideWidth
      yield content[i..<pos]

proc ngrams2key*(ngrams:sink seq[string]): string = 
  ngrams.join(";")

proc saveDoc*(doc:string;):string =
  ## save document to storage
  result = $0

proc indexDocument*(tree:var CritBitTree[seq[string]]; doc:sink string) = 
  ## index ngrams to document ids
  var words = toSeq(word(doc))
  var tokens = toSeq(tokenlize(words))
  var seqOfNgrams = toSeq slide(tokens)
  var key:string
  for ngrams in seqOfNgrams.mitems:
    key = ngrams2key(ngrams)
    discard containsOrIncl(tree,key,@[])
    tree[key].add $hash(doc)

proc retrieveDocument*(tree:var CritBitTree[seq[string]];query:string) = 
  var words = toSeq(word(query))
  var tokens = toSeq(tokenlize(words))
  var seqOfNgrams = toSeq slide(tokens)
  var key:string
  var ids:seq[string]
  for ngrams in seqOfNgrams.mitems:
    key = ngrams2key(ngrams)
    if tree.hasKey(key):
      ids.add tree[key]

iterator tokenlize*(doc:sink seq[string]):string = 
  for x in doc.mitems:
    if x notin StopWords:
      yield x

iterator word*(doc:sink string):string = 
  var idx = 0
  let docLen = doc.len
  var entry = ""
  while idx < docLen:
    if doc[idx] notin {' '} + Punctuation:
      entry.add doc[idx]
    else:
      if entry.len > 0:
        yield entry
      entry = ""
    inc idx

when isMainModule:
  const Sentence = "Lorem ipsum dolor sit amet".split
  assert toSeq(slide(@Sentence)).len == 3
  let words = @["A", "crit", "bit", "tree", "is", "a", "form", "of", "radix", "tree", "or", "patricia", "trie"]
  assert toSeq(word(" (A crit bit tree is a form of radix tree or patricia trie.) ")) == words
  let tokens = @["A", "crit", "bit", "tree", "form", "radix", "tree", "patricia", "trie"]
  assert toSeq(tokenlize(words)) == tokens
  assert ngrams2key(@["A", "crit", "bit"]) == "A;crit;bit"