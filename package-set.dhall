let aviate_labs = https://github.com/aviate-labs/package-set/releases/download/v0.1.4/package-set.dhall sha256:30b7e5372284933c7394bad62ad742fec4cb09f605ce3c178d892c25a1a9722e

let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.7.3-20221102/package-set.dhall sha256:9c989bdc496cf03b7d2b976d5bf547cfc6125f8d9bb2ed784815191bd518a7b9
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  -- This is where you can add your own packages to the package-set
  additions =
    [{ name = "map_7_0_0"
  , repo = "https://github.com/ZhenyaUsenko/motoko-hash-map"
  , version = "v7.0.0"
  , dependencies = [ "base"]
  },
  { name = "map"
  , repo = "https://github.com/ZhenyaUsenko/motoko-hash-map"
  , version = "v7.0.0"
  , dependencies = [ "base"]
  },
  { name = "stablebuffer_0_2_0"
  , repo = "https://github.com/skilesare/StableBuffer"
  , version = "v0.2.0"
  , dependencies = [ "base"]
  },
  { name = "StableBuffer"
  , repo = "https://github.com/skilesare/StableBuffer"
  , version = "v0.2.0"
  , dependencies = [ "base"]
  },
  { name = "icrc1"
  , repo = "https://github.com/NatLabs/icrc1"
  , version = "7af28bbfa7d41a20297ff6e349ee0374f9d1b576"
  , dependencies = [ "base"]
  },
  {
    name = "httpparser",     
    repo = "https://github.com/skilesare/http-parser.mo",
    version = "v0.1.0",
    dependencies = ["base"]
  },
  {
       name = "itertools",
       version = "main",
       repo = "https://github.com/NatLabs/Itertools.mo",
       dependencies = ["base"] : List Text
    },{
       name = "StableTrieMap",
       version = "main",
       repo = "https://github.com/NatLabs/StableTrieMap",
       dependencies = ["base"] : List Text
    }] : List Package

let
  {- This is where you can override existing packages in the package-set

     For example, if you wanted to use version `v2.0.0` of the foo library:
     let overrides = [
         { name = "foo"
         , version = "v2.0.0"
         , repo = "https://github.com/bar/foo"
         , dependencies = [] : List Text
         }
     ]
  -}
  overrides =
    [] : List Package

in  aviate_labs # upstream # additions # overrides
