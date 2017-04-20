module Installer (
    packageDir
  , vendorDir
  , executablePath
  , install
  ) where

import Prelude
import Data.Newtype
import Data.Function
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Aff (Aff, makeAff, launchAff)
import Node.Path (FilePath)
import Node.Path as Path
import Node.Stream (Readable, Writable, Duplex, pipe)
import Node.Stream as Stream
import Node.Platform (Platform(..))
import Node.Process as Process

newtype Url = Url String
derive instance newtypeUrl :: Newtype Url _

newtype Version = Version String
derive instance newtypeVersion :: Newtype Version _

getSourceUrl :: Version -> Url
getSourceUrl v = wrap do
  "https://github.com/purescript/purescript/archive/v" <> unwrap v <> ".tar.gz"

getDownloadUrl :: Version -> Platform -> Url
getDownloadUrl v o = wrap do
  "https://github.com/purescript/purescript/releases/download/v" <> unwrap v <> "/" <> case o of
    Darwin -> "macos.tar.gz"
    Win32 -> "win64.tar.gz"
    _ -> "linux64.tar.gz"

foreign import packageDir :: FilePath
foreign import createDownloadStream :: ∀ w eff. String -> Eff eff (Readable w eff)
foreign import tar2fs :: ∀ w eff. String -> Eff eff (Duplex eff)
foreign import gzipMaybe :: ∀ w eff. Eff eff (Duplex eff)

vendorDir :: FilePath
vendorDir = Path.concat [packageDir, "vendor"]

executablePath :: FilePath
executablePath = Path.concat [
    vendorDir
  , "purescript"
  , case Process.platform of
      Win32 -> "purs.exe"
      _     -> "purs"
  ]

pipes
  :: ∀ r w eff
   . Eff eff (Readable w eff)
  -> Eff eff (Writable r eff)
  -> Eff eff (Writable r eff)
pipes getS1 getS2 = do
  s1 <- getS1
  s2 <- getS2
  s1 `pipe` s2

infixl 0 pipes as >|>

download :: ∀ w. FilePath -> Platform -> Version -> Aff _ FilePath
download dir platform version =
  let url = unwrap $ getDownloadUrl version platform
   in Path.concat [dir, "purescript"] <$ makeAff \errback callback ->
      liftEff do
        stream <- createDownloadStream url
          >|> gzipMaybe
          >|> tar2fs dir
        Stream.onError stream errback
        Stream.onFinish stream $ callback unit

install :: Eff _ Unit
install = void $ launchAff do
  -- TODO: move the version number into package.json
  download vendorDir Process.platform (Version "0.11.4")
