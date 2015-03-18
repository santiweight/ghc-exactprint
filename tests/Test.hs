-- | Use "runhaskell Setup.hs test" or "cabal test" to run these tests.
module Main where

import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Utils

import GHC.Paths ( libdir )


import qualified Bag                   as GHC
import qualified DynFlags      as GHC
import qualified ErrUtils              as GHC
import qualified FastString    as GHC
import qualified GHC           as GHC
import qualified HscTypes              as GHC
import qualified Lexer                 as GHC
import qualified MonadUtils    as GHC
import qualified OccName       as GHC
import qualified Outputable            as GHC
import qualified RdrName       as GHC
import qualified SrcLoc                as GHC
import qualified StringBuffer          as GHC
-- import qualified Outputable    as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Data.IORef
import Control.Exception
import Control.Monad
import System.Directory
import System.FilePath
import System.IO
import System.Exit
import qualified Data.Map as Map

import Test.HUnit

-- import qualified Data.Map as Map

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  cnts <- runTestTT tests
  putStrLn $ show cnts
  if errors cnts > 0 || failures cnts > 0
     then exitFailure
     else return () -- exitSuccess

-- tests = TestCase (do r <- manipulateAstTest "examples/LetStmt.hs" "Layout.LetStmt"
--                      assertBool "test" r )

tests :: Test
tests = TestList
  [
    mkTestMod "LetStmt.hs"               "Layout.LetStmt"
  , mkTestMod "LetExpr.hs"               "LetExpr"
  , mkTestMod "ExprPragmas.hs"           "ExprPragmas"
  , mkTestMod "ListComprehensions.hs"    "Main"
  , mkTestMod "MonadComprehensions.hs"   "Main"
  , mkTestMod "FunDeps.hs"               "Main"
  , mkTestMod "ImplicitParams.hs"        "Main"
  , mkTestMod "RecursiveDo.hs"           "Main"
  , mkTestMod "TypeFamilies.hs"          "Main"
  , mkTestMod "MultiParamTypeClasses.hs" "Main"
  , mkTestMod "DataFamilies.hs"          "DataFamilies"
  , mkTestMod "Deriving.hs"              "Main"
  , mkTestMod "Default.hs"               "Main"
  , mkTestMod "ForeignDecl.hs"           "ForeignDecl"
  , mkTestMod "Warning.hs"               "Warning"
  , mkTestMod "Annotations.hs"           "Annotations"
  , mkTestMod "DocDecls.hs"              "DocDecls"
  , mkTestModTH "QuasiQuote.hs"          "QuasiQuote"
  , mkTestMod "Roles.hs"                 "Roles"
  , mkTestMod "Splice.hs"                "Splice"
  , mkTestMod "ImportsSemi.hs"           "ImportsSemi"
  , mkTestMod "Stmts.hs"                 "Stmts"
  , mkTestMod "Mixed.hs"                 "Main"
  , mkTestMod "Arrow.hs"                 "Arrow"
  , mkTestMod "PatSynBind.hs"            "Main"
  , mkTestMod "HsDo.hs"                  "HsDo"
  , mkTestMod "ForAll.hs"                "ForAll"
  , mkTestMod "PArr.hs"                  "PArr"
  , mkTestMod "ViewPatterns.hs"          "Main"
  , mkTestMod "BangPatterns.hs"          "Main"
  , mkTestMod "Associated.hs"            "Main"
  , mkTestMod "Move1.hs"                 "Move1"
  , mkTestMod "Rules.hs"                 "Rules"
  , mkTestMod "TypeOperators.hs"         "Main"
  , mkTestMod "NullaryTypeClasses.hs"    "Main"
  , mkTestMod "FunctionalDeps.hs"        "Main"
  , mkTestMod "DerivingOC.hs"            "Main"
  , mkTestMod "GenericDeriving.hs"       "Main"
  , mkTestMod "OverloadedStrings.hs"     "Main"
  , mkTestMod "RankNTypes.hs"            "Main"
  , mkTestMod "Existential.hs"           "Main"
  , mkTestMod "ScopedTypeVariables.hs"   "Main"
  , mkTestMod "Arrows.hs"                "Main"
  , mkTestMod "TH.hs"                    "Main"
  , mkTestMod "StaticPointers.hs"        "Main"
  , mkTestMod "DataDecl.hs"              "Main"
  , mkTestMod "Guards.hs"                "Main"
  , mkTestMod "RebindableSyntax.hs"      "Main"
  , mkTestMod "RdrNames.hs"              "RdrNames"
  , mkTestMod "Vect.hs"                  "Vect"
  , mkTestMod "Tuple.hs"                 "Main"
  , mkTestMod "ExtraConstraints1.hs"     "ExtraConstraints1"
  , mkTestMod "AddAndOr3.hs"             "AddAndOr3"
  , mkTestMod "Ann01.hs"                 "Ann01"
  , mkTestMod "StrictLet.hs"             "Main"
  , mkTestMod "Cg008.hs"                 "Cg008"
  , mkTestMod "T2388.hs"                 "T2388"
  , mkTestMod "T3132.hs"                 "T3132"
  , mkTestMod "Stream.hs"                "Stream"
  , mkTestMod "Trit.hs"                  "Trit"
  , mkTestMod "DataDecl.hs"              "Main"
  , mkTestMod "Zipper.hs"                "Zipper"
  , mkTestMod "Sigs.hs"                  "Sigs"
  , mkTestMod "Utils2.hs"                "Utils2"
  , mkTestMod "EmptyMostlyInst.hs"       "EmptyMostlyInst"
  , mkTestMod "EmptyMostlyNoSemis.hs"    "EmptyMostlyNoSemis"
  , mkTestMod "Dead1.hs"                 "Dead1"
  , mkTestMod "EmptyMostly.hs"           "EmptyMostly"
  , mkTestMod "FromUtils.hs"             "Main"
  , mkTestMod "DocDecls.hs"              "DocDecls"
  , mkTestMod "RecordUpdate.hs"          "Main"
  -- , mkTestMod "Unicode.hs"               "Main"
  , mkTestMod "B.hs"                     "Main"
  , mkTestMod "LayoutWhere.hs"           "Main"
  , mkTestMod "LayoutLet.hs"             "Main"
  , mkTestMod "LayoutIn1.hs"             "LayoutIn1"
  , mkTestMod "LayoutIn3.hs"             "LayoutIn3"
  , mkTestMod "LayoutIn4.hs"             "LayoutIn4"
  , mkTestMod "Deprecation.hs"           "Deprecation"
  , mkTestMod "Infix.hs"                 "Main"
  , mkTestMod "BCase.hs"                 "Main"
  , mkTestMod "AltsSemis.hs"             "Main"
  , mkTestMod "LetExprSemi.hs"           "LetExprSemi"
  , mkTestMod "WhereIn4.hs"              "WhereIn4"
  , mkTestMod "LocToName.hs"             "LocToName"
  , mkTestMod "IfThenElse1.hs"           "Main"
  , mkTestMod "IfThenElse2.hs"           "Main"
  , mkTestMod "IfThenElse3.hs"           "Main"

  , mkTestModChange changeLayoutLet2 "LayoutLet2.hs" "LayoutLet2"
  , mkTestModChange changeLayoutLet3 "LayoutLet3.hs" "LayoutLet3"
  , mkTestModChange changeLayoutLet3 "LayoutLet4.hs" "LayoutLet4"
  , mkTestModChange changeRename1    "Rename1.hs"    "Main"
  , mkTestModChange changeLayoutIn1  "LayoutIn1.hs"  "LayoutIn1"
  , mkTestModChange changeLayoutIn4  "LayoutIn4.hs"  "LayoutIn4"
  , mkTestModChange changeLocToName  "LocToName.hs"  "LocToName"

  ]

mkTestMain :: FilePath -> Test
mkTestMain fileName = TestCase (do r <- manipulateAstTest fileName "Main"
                                   assertBool fileName r )

mkTestMod :: FilePath -> String -> Test
mkTestMod fileName modName
  = TestCase (do r <- manipulateAstTest fileName modName
                 assertBool fileName r )

mkTestModChange :: (GHC.ParsedSource -> GHC.ParsedSource) -> FilePath -> String -> Test
mkTestModChange change fileName modName
  = TestCase (do r <- manipulateAstTestWithMod change fileName modName
                 assertBool fileName r )

mkTestModTH :: FilePath -> String -> Test
mkTestModTH fileName modName
  = TestCase (do r <- manipulateAstTestTH fileName modName
                 assertBool fileName r )

-- ---------------------------------------------------------------------

tt :: IO Bool
tt = do
{-
    manipulateAstTest "LetExpr.hs"               "LetExpr"
    manipulateAstTest "ExprPragmas.hs"           "ExprPragmas"
    manipulateAstTest "ListComprehensions.hs"    "Main"
    manipulateAstTest "MonadComprehensions.hs"   "Main"
    manipulateAstTest "FunDeps.hs"               "Main"
    manipulateAstTest "RecursiveDo.hs"           "Main"
    manipulateAstTest "TypeFamilies.hs"          "Main"
    manipulateAstTest "MultiParamTypeClasses.hs" "Main"
    manipulateAstTest "DataFamilies.hs"          "DataFamilies"
    manipulateAstTest "Deriving.hs"              "Main"
    manipulateAstTest "Default.hs"               "Main"
    manipulateAstTest "ForeignDecl.hs"           "ForeignDecl"
    manipulateAstTest "Warning.hs"               "Warning"
    manipulateAstTest "Annotations.hs"           "Annotations"
    manipulateAstTestTH "QuasiQuote.hs"          "QuasiQuote"
    manipulateAstTest "Roles.hs"                 "Roles"
    manipulateAstTest "Splice.hs"                "Splice"
    manipulateAstTest "ImportsSemi.hs"           "ImportsSemi"
    manipulateAstTest "Stmts.hs"                 "Stmts"
    manipulateAstTest "Mixed.hs"                 "Main"
    manipulateAstTest "Arrow.hs"                 "Arrow"
    manipulateAstTest "PatSynBind.hs"            "Main"
    manipulateAstTest "HsDo.hs"                  "HsDo"
    manipulateAstTest "ForAll.hs"                "ForAll"
    manipulateAstTest "BangPatterns.hs"          "Main"
    manipulateAstTest "Associated.hs"            "Main"
    manipulateAstTest "Move1.hs"                 "Move1"
    manipulateAstTest "TypeOperators.hs"         "Main"
    manipulateAstTest "NullaryTypeClasses.hs"    "Main"
    manipulateAstTest "FunctionalDeps.hs"        "Main"
    manipulateAstTest "DerivingOC.hs"            "Main"
    manipulateAstTest "GenericDeriving.hs"       "Main"
    manipulateAstTest "OverloadedStrings.hs"     "Main"
    manipulateAstTest "RankNTypes.hs"            "Main"
    manipulateAstTest "Existential.hs"           "Main"
    manipulateAstTest "ScopedTypeVariables.hs"   "Main"
    manipulateAstTest "Arrows.hs"                "Main"
    manipulateAstTest "TH.hs"                    "Main"
    manipulateAstTest "StaticPointers.hs"        "Main"
    manipulateAstTest "DataDecl.hs"              "Main"
    manipulateAstTest "Guards.hs"                "Main"
    manipulateAstTest "RdrNames.hs"              "RdrNames"
    manipulateAstTest "Vect.hs"                  "Vect"
    manipulateAstTest "Tuple.hs"                 "Main"
    manipulateAstTest "ExtraConstraints1.hs"     "ExtraConstraints1"
    manipulateAstTest "AddAndOr3.hs"             "AddAndOr3"
    manipulateAstTest "Ann01.hs"                 "Ann01"
    manipulateAstTest "StrictLet.hs"             "Main"
    manipulateAstTest "Cg008.hs"                 "Cg008"
    manipulateAstTest "T2388.hs"                 "T2388"
    manipulateAstTest "T3132.hs"                 "T3132"
    manipulateAstTest "Stream.hs"                "Stream"
    manipulateAstTest "Trit.hs"                  "Trit"
    manipulateAstTest "DataDecl.hs"              "Main"
    manipulateAstTest "Zipper.hs"                "Zipper"
    manipulateAstTest "Sigs.hs"                  "Sigs"
    manipulateAstTest "Utils2.hs"                "Utils2"
    manipulateAstTest "EmptyMostlyInst.hs"       "EmptyMostlyInst"
    manipulateAstTest "EmptyMostlyNoSemis.hs"    "EmptyMostlyNoSemis"
    manipulateAstTest "EmptyMostly.hs"           "EmptyMostly"
    manipulateAstTest "FromUtils.hs"             "Main"
    manipulateAstTest "DocDecls.hs"              "DocDecls"
    manipulateAstTest "RecordUpdate.hs"          "Main"
    -- manipulateAstTest "Unicode.hs"               "Main"
    manipulateAstTest "B.hs"                     "Main"
    manipulateAstTest "LayoutWhere.hs"           "Main"
    manipulateAstTest "Deprecation.hs"           "Deprecation"
    manipulateAstTest "Infix.hs"                 "Main"
    manipulateAstTest "BCase.hs"                 "Main"
    manipulateAstTest "LetExprSemi.hs"           "LetExprSemi"
    manipulateAstTest "LetExpr2.hs"              "Main"
    manipulateAstTest "LetStmt.hs"               "Layout.LetStmt"
    manipulateAstTest "LayoutLet.hs"             "Main"
    manipulateAstTest "ImplicitParams.hs"        "Main"
    manipulateAstTest "RebindableSyntax.hs"      "Main"
    manipulateAstTestWithMod changeLayoutLet3 "LayoutLet4.hs" "LayoutLet4"
    manipulateAstTestWithMod changeLayoutLet5 "LayoutLet5.hs" "LayoutLet5"
    manipulateAstTest "EmptyMostly2.hs"          "EmptyMostly2"
    manipulateAstTest "WhereIn4.hs"              "WhereIn4"
    manipulateAstTest "AltsSemis.hs"             "Main"
    manipulateAstTest "PArr.hs"                  "PArr"
    manipulateAstTest "Dead1.hs"                 "Dead1"
    manipulateAstTest "DocDecls.hs"              "DocDecls"
    manipulateAstTest "ViewPatterns.hs"          "Main"
    manipulateAstTest "LayoutLet2.hs"             "LayoutLet2"
    manipulateAstTest "FooExpected.hs"          "Main"
    manipulateAstTestWithMod changeLayoutLet2 "LayoutLet2.hs" "LayoutLet2"
    manipulateAstTest "LayoutIn1.hs"                 "LayoutIn1"
    manipulateAstTest "LayoutIn3.hs"                 "LayoutIn3"
    manipulateAstTestWithMod changeLayoutIn1  "LayoutIn1.hs" "LayoutIn1"
    manipulateAstTest "LocToName.hs"                 "LocToName"
    manipulateAstTest "Cg008.hs"                 "Cg008"
    -}
    -- manipulateAstTestWithMod changeLayoutIn4  "LayoutIn4.hs" "LayoutIn4"
    manipulateAstTestWithMod changeLayoutIn3  "LayoutIn3.hs" "LayoutIn3"
    -- manipulateAstTestWithMod changeLocToName  "LocToName.hs" "LocToName"
    -- manipulateAstTestWithMod changeLayoutLet3 "LayoutLet3.hs" "LayoutLet3"
    -- manipulateAstTestWithMod changeRename1    "Rename1.hs"  "Main"
    -- manipulateAstTest    "Rename1.hs"  "Main"
    -- manipulateAstTest "Rules.hs"                 "Rules"

{-
    manipulateAstTest "ParensAroundContext.hs"   "ParensAroundContext"
    manipulateAstTestWithMod changeWhereIn4 "WhereIn4.hs" "WhereIn4"
    manipulateAstTest "Cpp.hs"                   "Main"
    manipulateAstTest "Lhs.lhs"                  "Main"
    manipulateAstTest "Foo.hs"                   "Main"
-}

-- ---------------------------------------------------------------------

changeLayoutLet2 :: GHC.ParsedSource -> GHC.ParsedSource
changeLayoutLet2 parsed = rename "xxxlonger" [((7,5),(7,8)),((8,24),(8,27))] parsed

changeLocToName :: GHC.ParsedSource -> GHC.ParsedSource
changeLocToName parsed = rename "LocToName.newPoint" [((20,1),(20,11)),((20,28),(20,38)),((24,1),(24,11))] parsed

changeLayoutIn3 :: GHC.ParsedSource -> GHC.ParsedSource
changeLayoutIn3 parsed = rename "anotherX" [((7,13),(7,14)),((8,37),(8,38))] parsed

changeLayoutIn4 :: GHC.ParsedSource -> GHC.ParsedSource
changeLayoutIn4 parsed = rename "io" [((7,8),(7,13)),((7,28),(7,33))] parsed

changeLayoutIn1 :: GHC.ParsedSource -> GHC.ParsedSource
changeLayoutIn1 parsed = rename "square" [((7,17),(7,19)),((7,24),(7,26))] parsed

changeRename1 :: GHC.ParsedSource -> GHC.ParsedSource
changeRename1 parsed = rename "bar2" [((3,1),(3,4))] parsed

changeLayoutLet3 :: GHC.ParsedSource -> GHC.ParsedSource
changeLayoutLet3 parsed = rename "xxxlonger" [((7,5),(7,8)),((9,14),(9,17))] parsed

changeLayoutLet5 :: GHC.ParsedSource -> GHC.ParsedSource
changeLayoutLet5 parsed = rename "x" [((7,5),(7,8)),((9,14),(9,17))] parsed

rename :: (SYB.Data a) => String -> [Span] -> a -> a
rename newNameStr spans a
  = SYB.everywhere ( SYB.mkT   replaceRdr
                    `SYB.extT` replaceHsVar
                    `SYB.extT` replacePat
                   ) a
  where
    newName = GHC.mkRdrUnqual (GHC.mkVarOcc newNameStr)

    cond :: GHC.SrcSpan -> Bool
    cond ln = any (\ss -> ss2span ln == ss) spans

    replaceRdr :: GHC.Located GHC.RdrName -> GHC.Located GHC.RdrName
    replaceRdr (GHC.L ln _)
        | cond ln = GHC.L ln newName
    replaceRdr x = x

    replaceHsVar :: GHC.LHsExpr GHC.RdrName -> GHC.LHsExpr GHC.RdrName
    replaceHsVar (GHC.L ln (GHC.HsVar _))
        | cond ln = GHC.L ln (GHC.HsVar newName)
    replaceHsVar x = x

    replacePat (GHC.L ln (GHC.VarPat _))
        | cond ln = GHC.L ln (GHC.VarPat newName)
    replacePat x = x



-- ---------------------------------------------------------------------

changeWhereIn4 :: GHC.ParsedSource -> GHC.ParsedSource
changeWhereIn4 parsed
  = SYB.everywhere (SYB.mkT replace) parsed
  where
    replace :: GHC.Located GHC.RdrName -> GHC.Located GHC.RdrName
    replace (GHC.L ln _n)
      | ss2span ln == ((12,16),(12,17)) = GHC.L ln (GHC.mkRdrUnqual (GHC.mkVarOcc "p_2"))
    replace x = x

-- ---------------------------------------------------------------------

-- | Where all the tests are to be found
examplesDir :: FilePath
examplesDir = "tests" </> "examples"

examplesDir2 :: FilePath
examplesDir2 = "examples"

manipulateAstTestWithMod :: (GHC.ParsedSource -> GHC.ParsedSource) -> FilePath -> String -> IO Bool
manipulateAstTestWithMod change file modname = manipulateAstTest' (Just change) False file modname

manipulateAstTest :: FilePath -> String -> IO Bool
manipulateAstTest file modname = manipulateAstTest' Nothing False file modname

manipulateAstTestTH :: FilePath -> String -> IO Bool
manipulateAstTestTH file modname = manipulateAstTest' Nothing True file modname

manipulateAstTest' :: Maybe (GHC.ParsedSource -> GHC.ParsedSource) -> Bool -> FilePath -> String -> IO Bool
manipulateAstTest' mchange useTH file' modname = do
  let testpath = "./tests/examples/"
      file     = testpath </> file'
      out      = file <.> "out"
      expected = file <.> "expected"

  contents <- case mchange of
                   Nothing -> readUTF8File file
                   Just _  -> readUTF8File expected
  (ghcAnns,t) <- parsedFileGhc file modname useTH
  let
    parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
    parsedAST = SYB.showData SYB.Parser 0 parsed
    -- parsedAST = showGhc parsed
       -- `debug` ("getAnn:=" ++ (show (getAnnotationValue (snd ann) (GHC.getLoc parsed) :: Maybe AnnHsModule)))
    -- try to pretty-print; summarize the test result
    ann = annotateAST parsed ghcAnns
      `debug` ("ghcAnns:" ++ showGhc ghcAnns)

    parsed' = case mchange of
                   Nothing -> parsed
                   Just change -> change parsed
    printed = exactPrintAnnotation parsed' ann -- `debug` ("ann=" ++ (show $ map (\(s,a) -> (ss2span s, a)) $ Map.toList ann))
    result =
            if printed == contents
              then "Match\n"
              else printed ++ "\n==============\n"
                    ++ "lengths:" ++ show (length printed,length contents) ++ "\n"
                    ++ parsedAST
                    ++ "\n========================\n"
                    ++ showAnnData ann 0 parsed'
  writeFile out $ result
  -- putStrLn $ "Test:parsed=" ++ parsedAST
  -- putStrLn $ "Test:ann :" ++ showGhc ann
  -- putStrLn $ "Test:ghcAnns :" ++ showGhc ghcAnns
  -- putStrLn $ "Test:showdata:" ++ showAnnData ann 0 parsed
  -- putStrLn $ "Test:showdata:parsed'" ++ showAnnData ann 0 parsed'
  return ("Match\n" == result)


-- ---------------------------------------------------------------------
-- |Result of parsing a Haskell source file. It is simply the
-- TypeCheckedModule produced by GHC.
type ParseResult = GHC.TypecheckedModule

parsedFileGhc :: String -> String -> Bool -> IO (GHC.ApiAnns,ParseResult)
parsedFileGhc fileName modname useTH = do
    -- putStrLn $ "parsedFileGhc:" ++ show fileName
    GHC.defaultErrorHandler GHC.defaultFatalMessager GHC.defaultFlushOut $ do
      GHC.runGhc (Just libdir) $ do
        dflags <- GHC.getSessionDynFlags
        let dflags'' = dflags { GHC.importPaths = ["./tests/examples/","../tests/examples/",
                                                   "./src/","../src/"] }

            tgt = if useTH then GHC.HscInterpreted
                           else GHC.HscNothing -- allows FFI
            dflags''' = dflags'' { GHC.hscTarget = tgt,
                                   GHC.ghcLink =  GHC.LinkInMemory
                                  , GHC.packageFlags = [GHC.ExposePackage (GHC.PackageArg "ghc") (GHC.ModRenaming False [])]
                                 }

            dflags4 = if False -- useHaddock
                        then GHC.gopt_set (GHC.gopt_set dflags''' GHC.Opt_Haddock)
                                       GHC.Opt_KeepRawTokenStream
                        else GHC.gopt_set dflags'''
                                       GHC.Opt_KeepRawTokenStream
                        -- else GHC.gopt_set (GHC.gopt_unset dflags''' GHC.Opt_Haddock)
                        --               GHC.Opt_KeepRawTokenStream

        (dflags5,_args,_warns) <- GHC.parseDynamicFlagsCmdLine dflags4 [GHC.noLoc "-package ghc"]
        -- GHC.liftIO $ putStrLn $ "dflags set:(args,warns)" ++ show (map GHC.unLoc args,map GHC.unLoc warns)
        void $ GHC.setSessionDynFlags dflags5
        -- GHC.liftIO $ putStrLn $ "dflags set"

        target <- GHC.guessTarget fileName Nothing
        GHC.setTargets [target]
        -- GHC.liftIO $ putStrLn $ "target set:" ++ showGhc (GHC.targetId target)
        void $ GHC.load GHC.LoadAllTargets -- Loads and compiles, much as calling make
        -- GHC.liftIO $ putStrLn $ "targets loaded"
        -- g <- GHC.getModuleGraph
        -- let showStuff ms = show (GHC.moduleNameString $ GHC.moduleName $ GHC.ms_mod ms,GHC.ms_location ms)
        -- GHC.liftIO $ putStrLn $ "module graph:" ++ (intercalate "," (map showStuff g))

        modSum <- GHC.getModSummary $ GHC.mkModuleName modname
        -- GHC.liftIO $ putStrLn $ "got modSum"
        -- let modSum = head g
{-
        (sourceFile, source, flags) <- getModuleSourceAndFlags (GHC.ms_mod modSum)
        strSrcBuf <- getPreprocessedSrc sourceFile
        GHC.liftIO $ putStrLn $ "preprocessedSrc====\n" ++ strSrcBuf ++ "\n================\n"
-}
        p <- GHC.parseModule modSum
        -- GHC.liftIO $ putStrLn $ "got parsedModule"
        t <- GHC.typecheckModule p
        -- GHC.liftIO $ putStrLn $ "typechecked"
        -- toks <- GHC.getRichTokenStream (GHC.ms_mod modSum)
        -- GHC.liftIO $ putStrLn $ "toks" ++ show toks
        let anns = GHC.pm_annotations p
        -- GHC.liftIO $ putStrLn $ "anns"
        return (anns,t)

readUTF8File :: FilePath -> IO String
readUTF8File fp = openFile fp ReadMode >>= \h -> do
        hSetEncoding h utf8
        hGetContents h

-- ---------------------------------------------------------------------

pwd :: IO FilePath
pwd = getCurrentDirectory

cd :: FilePath -> IO ()
cd = setCurrentDirectory

-- ---------------------------------------------------------------------

mkSs :: (Int,Int) -> (Int,Int) -> GHC.SrcSpan
mkSs (sr,sc) (er,ec)
  = GHC.mkSrcSpan (GHC.mkSrcLoc (GHC.mkFastString "examples/PatBind.hs") sr sc)
                  (GHC.mkSrcLoc (GHC.mkFastString "examples/PatBind.hs") er ec)
-- ---------------------------------------------------------------------

-- | The preprocessed files are placed in a temporary directory, with
-- a temporary name, and extension .hscpp. Each of these files has
-- three lines at the top identifying the original origin of the
-- files, which is ignored by the later stages of compilation except
-- to contextualise error messages.
getPreprocessedSrc ::
  -- GHC.GhcMonad m => FilePath -> m GHC.StringBuffer
  GHC.GhcMonad m => FilePath -> m String
getPreprocessedSrc srcFile = do
  df <- GHC.getSessionDynFlags
  d <- GHC.liftIO $ getTempDir df
  fileList <- GHC.liftIO $ getDirectoryContents d
  let suffix = "hscpp"

  let cppFiles = filter (\f -> getSuffix f == suffix) fileList
  origNames <- GHC.liftIO $ mapM getOriginalFile $ map (\f -> d </> f) cppFiles
  let tmpFile = ghead "getPreprocessedSrc" $ filter (\(o,_) -> o == srcFile) origNames
  -- buf <- GHC.liftIO $ GHC.hGetStringBuffer $ snd tmpFile
  -- return buf
  GHC.liftIO $ readUTF8File (snd tmpFile)

-- ---------------------------------------------------------------------

getSuffix :: FilePath -> String
getSuffix fname = reverse $ fst $ break (== '.') $ reverse fname

-- | A GHC preprocessed file has the following comments at the top
-- @
-- # 1 "./test/testdata/BCpp.hs"
-- # 1 "<command-line>"
-- # 1 "./test/testdata/BCpp.hs"
-- @
-- This function reads the first line of the file and returns the
-- string in it.
-- NOTE: no error checking, will blow up if it fails
getOriginalFile :: FilePath -> IO (FilePath,FilePath)
getOriginalFile fname = do
  fcontents <- readFile fname
  let firstLine = ghead "getOriginalFile" $ lines fcontents
  let (_,originalFname) = break (== '"') firstLine
  return $ (tail $ init $ originalFname,fname)


-- ---------------------------------------------------------------------
-- Copied from the GHC source, since not exported

getModuleSourceAndFlags :: GHC.GhcMonad m => GHC.Module -> m (String, GHC.StringBuffer, GHC.DynFlags)
getModuleSourceAndFlags modu = do
  m <- GHC.getModSummary (GHC.moduleName modu)
  case GHC.ml_hs_file $ GHC.ms_location m of
    Nothing ->
               do dflags <- GHC.getDynFlags
                  GHC.liftIO $ throwIO $ GHC.mkApiErr dflags (GHC.text "No source available for module " GHC.<+> GHC.ppr modu)
    Just sourceFile -> do
        source <- GHC.liftIO $ GHC.hGetStringBuffer sourceFile
        return (sourceFile, source, GHC.ms_hspp_opts m)


-- return our temporary directory within tmp_dir, creating one if we
-- don't have one yet
getTempDir :: GHC.DynFlags -> IO FilePath
getTempDir dflags
  = do let ref = GHC.dirsToClean dflags
           tmp_dir = GHC.tmpDir dflags
       mapping <- readIORef ref
       case Map.lookup tmp_dir mapping of
           Nothing -> error "should already be a tmpDir"
           Just d -> return d
