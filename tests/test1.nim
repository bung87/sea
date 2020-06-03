# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import critbits
import strutils
import sea
test "simple test":
  const Doc1 = """Let’s jump into Rust by working through a hands-on project together! This chapter introduces you to a few common Rust concepts by showing you how to use them in a real program. You’ll learn about let, match, methods, associated functions, using external crates, and more! The following chapters will explore these ideas in more detail. In this chapter, you’ll practice the fundamentals.
  We’ll implement a classic beginner programming problem: a guessing game. Here’s how it works: the program will generate a random integer between 1 and 100. It will then prompt the player to enter a guess. After a guess is entered, the program will indicate whether the guess is too low or too high. If the guess is correct, the game will print a congratulatory message and exit.
  """
  const Doc2 = """Nim is a statically typed compiled systems programming language. It combines successful concepts from mature languages like Python, Ada and Modula.
  """
 
  var tree: CritBitTree[seq[string]]
  tree.indexDocument( escape(Doc1,"",""),true)
  tree.indexDocument( escape(Doc2,"",""),true)
  let ids = tree.retrieveDocumentIds("Nim")
  check retrieveDocuments(ids).len == 1
  let ids2 = tree.retrieveDocumentIds("real program")
  check retrieveDocuments(ids2).len == 1
