---
title: "Proof Theory Impressionism: Blurring the Curry-Howard Line"
venue: "Strangeloop 2018"
slides: "proof-theory-impressionism.pdf"
---

The Curry-Howard Correspondence is the observation that there exists a
correspondence between objects present in disparate formal
systems. Once such instance of this correspondence is the conspicuous
propositions-as-types notion, which draws correspondences between
logical propositions and types in a programming language.

<!--more-->

As another more specific instance, one could consider a program
written in a traditional programming language like Rust, and its
formal proof exercised in a language like Coq.

While this is a beautiful revelation in theory, in practice this line
begins to look more like an impenetrable wall as it divides proof from
program. This chasm prevents assurances that, beyond those that can
simply be "observed" by a human, an implementation faithfully abides
its proofs. The conventional solution to this problem is code
extraction. However, in cases like safety-critical system software
(e.g. avionics, medical devices, & autonomous vehicles), the languages
and platforms targeted by extraction tools simply aren't an
option. What if there was another way?

This talk explores some potential approaches to endow our production
language, mostly Rust in this case (w/ a dash of Haskell), with the
capabilities present in "provable" systems. These explorations will
include spaces like totality, type-level programming, and dependent
types. Ultimately drawing lines from the above explorations back to
how one might write such a thing in the language of a proof assistant.

$if(slides)$
* [Slides](/files/$slides$)
$endif$
$if(video)$
* [Video]($video$)
$endif$