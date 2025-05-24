{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TupleSections #-}

module Etna.Lib.TH (mkStrategies, mkMain) where

import Etna.Lib.Types (ExpArgs (..), Result)
import Language.Haskell.TH

mkStrategies :: Q Exp -> [Name] -> Q [Dec]
mkStrategies code = foldr (combine . go) (return [])
  where
    go :: Name -> Q [Dec]
    go name =
      let test = mkName $ propToTest $ nameBase name
       in [d|$(varP test) = $(code) $(varE name)|]

    combine :: Q [Dec] -> Q [Dec] -> Q [Dec]
    combine qds qds' = do
      ds <- qds
      ds' <- qds'
      return (ds ++ ds')

mkMain :: IO [String] -> IO [String] -> Q [Dec]
mkMain ims ips = do
  ms <- runIO ims
  ps <- runIO ips
  let mps = concatMap (\m -> map (m,) ps) ms
  [d|
    main :: IO ()
    main = do
      args <- getArgs
      let ExpArgs file trials workload strategy mutant prop label timeout =
            parseExpArgs (head args)
          test = fromJust $ lookup (strategy, prop) mmap
      run file trials (workload, label, mutant, prop) timeout test

    mmap :: [((String, String), IO Result)]
    mmap = $(listE (map mkPair mps))
    |]
  where
    mkPair :: (String, String) -> Q Exp
    mkPair (m, p) = do
      t <- lookupName m (propToTest p)
      [|((m, p), $(varE t))|]

    lookupName pre suf = do
      let name = pre ++ "." ++ suf
      mv <- lookupValueName name
      case mv of
        -- TODO: might want more flexible behavior here
        Nothing -> error ("could not find:" ++ name)
        Just v -> return v

propToTest :: String -> String
propToTest = ("test_" ++) . tail . dropWhile (/= '_')