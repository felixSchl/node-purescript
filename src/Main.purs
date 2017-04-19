module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Aff (launchAff)
import Control.Monad.Aff.Console (CONSOLE, log)
import Node.FS.Aff
import Node.Platform (Platform(..))
import Node.Process as Process

_PURS_VERSION = "0.11.4" -- TODO: load this from somwhere else: package.json?
_TARGET_PATH = "~/purescript-node-test"  -- TODO: figure this out dynamically

getSourceUrl :: String -> String
getSourceUrl v = "https://github.com/purescript/purescript/archive/v" <> v <> ".tar.gz"

getDownloadUrl :: String -> Platform -> String
getDownloadUrl v o = "https://github.com/purescript/purescript/releases/download/v" <> v <> "/" <> case o of
  Darwin -> "macos.tar.gz"
  Win32 -> "win64.tar.gz"
  _ -> "linux64.tar.gz"

main :: forall e. Eff _ Unit
main = unit <$ launchAff do
  log $ getDownloadUrl _PURS_VERSION Process.platform
