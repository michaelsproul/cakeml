name: cakeml-semantics-ffi
version: 1.0
description:
author: CakeML Developers
license: MIT
requires: base
requires: hol-base
show: "Data.Bool"
show: "Function"

ffi {
  interpretation: "../../../HOL-ot/src/opentheory/hol4.int"
  article: "ffi.ot.art"
}

simple {
  import: ffi
  interpretation: "../../../HOL-ot/src/opentheory/hol4.int"
  article: "simpleIO.ot.art"
}

main {
  import: ffi
  import: simple
}

