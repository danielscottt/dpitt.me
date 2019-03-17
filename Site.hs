{-# LANGUAGE OverloadedStrings #-}

module Main where

import Hakyll

import System.FilePath

import Data.List.Split (splitOn)

import Text.Pandoc.Options
import Text.Pandoc.SideNote (usingSideNotes)

main :: IO ()
main =
  hakyll $ do
    match "tufte/et-book/*/*" $ route $ customRoute $ drop 6 . toFilePath
    match "tufte/tufte.css" $ do
      route idRoute
      compile copyFileCompiler
    match "css/*.css" $ do
      route idRoute
      compile copyFileCompiler
    match "js/*.js" $ do
      route idRoute
      compile copyFileCompiler
    match "files/*" $ do
      route idRoute
      compile copyFileCompiler
    match "images/*" $ do
      route idRoute
      compile copyFileCompiler
    match "blog/*" $ do
      route blogRoute
      compile $
        pandocWithSidenotes >>=
        loadAndApplyTemplate "templates/default.html" dateCtx
    match "archive.html" $ do
      route toIdxPath
      compile $ do
        posts <- recentFirst =<< loadAll "blog/*"
        let context = listField "items" (dateCtx <> blogRouteCtx) (return posts)
        asTempWithDefault context
    match "talks/*" $ do
      route toIdxPath
      compile $
        getResourceBody >>= applyAsTemplate defaultContext >>=
        saveSnapshot "talk-content" >>=
        renderPandoc >>=
        loadAndApplyTemplate "templates/default.html" defaultContext
    match "talks.html" $ do
      route toIdxPath
      compile $ do
        talks <- loadAll "talks/*"
        let context =
              listField
                "talks"
                (defaultContext <> teaserField "teaser" "talk-content" <>
                 cleanRouteCtx)
                (return talks)
        asTempWithDefault context
    match "ephemera/*" $ do
      route blogRoute
      compile $
        pandocWithSidenotes >>= saveSnapshot "eph-content" >>=
        loadAndApplyTemplate "templates/default.html" dateCtx
    match "ephemera.html" $ do
      route toIdxPath
      compile $ do
        eph <- recentFirst =<< loadAll "ephemera/*"
        asTempWithDefault $ ephCtx eph
    match "index.html" $ do
      route idRoute
      compile $ do
        posts <- take 5 <$> (recentFirst =<< loadAll "blog/*")
        let context = listField "items" (dateCtx <> blogRouteCtx) (return posts)
        asTempWithDefault context
    match "templates/*" $ compile templateCompiler
    match "*.html" $ do
      route toIdxPath
      compile $
        getResourceBody >>=
        loadAndApplyTemplate "templates/default.html" defaultContext

asTempWithDefault :: Context String -> Compiler (Item String)
asTempWithDefault cs =
  getResourceBody >>= applyAsTemplate cs >>=
  loadAndApplyTemplate "templates/default.html" defaultContext

dateCtx :: Context String
dateCtx = dateField "date" "%B %e, %Y" <> defaultContext

ephCtx :: [Item String] -> Context String
ephCtx items =
  listField "first" ephPostCtx (return (take 1 items)) <>
  listField "items" ephPostCtx (return (drop 1 items))
  where
    ephPostCtx =
      defaultContext <> teaserField "teaser" "eph-content" <> blogRouteCtx <>
      dateCtx

-- This is the infamous `niceRoute' function.
toIdxPath :: Routes
toIdxPath = customRoute createIndexRoute
  where
    createIndexRoute ident =
      let path = toFilePath ident
       in takeDirectory path </> takeBaseName path </> "index.html"

pandocWithSidenotes :: Compiler (Item String)
pandocWithSidenotes =
  let defWExt = writerExtensions defaultHakyllWriterOptions
      mathExtensions = [Ext_tex_math_dollars, Ext_latex_macros]
      extents = foldr enableExtension defWExt mathExtensions
      wopts =
        defaultHakyllWriterOptions
          {writerExtensions = extents, writerHTMLMathMethod = MathJax ""}
   in pandocCompilerWithTransform
        defaultHakyllReaderOptions
        wopts
        usingSideNotes

mkBlogRoute :: Identifier -> FilePath
mkBlogRoute ident =
  let path = toFilePath ident
      fileNameSplit = splitOn "-" (takeBaseName path)
   in takeDirectory path </> head fileNameSplit </> fileNameSplit !! 1 </>
      drop 11 (takeBaseName path) </>
      "index.html"

blogRoute :: Routes
blogRoute = customRoute mkBlogRoute

blogRouteCtx :: Context String
blogRouteCtx =
  field "blog-route" (return . dropFileName . mkBlogRoute . itemIdentifier)

cleanRouteCtx :: Context String
cleanRouteCtx =
  field "clean-route" (return . clean . toFilePath . itemIdentifier)
  where
    clean path = takeDirectory path </> takeBaseName path