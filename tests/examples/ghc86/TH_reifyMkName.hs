-- Trac #2339
{-# LANGUAGE TemplateHaskell #-}

module Foo where

import System.IO
import Language.Haskell.TH

type C = Int

$(do
  a <- reify $ mkName "C"
  runIO $ hPutStrLn stderr (show a)
  return []
  )

