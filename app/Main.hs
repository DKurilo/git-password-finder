import System.Directory
import Control.Concurrent
import System.FilePath
import System.Environment
import Data.List hiding (find)
import GHC.Conc (getNumCapabilities)
import Text.Printf
import Text.Regex.Posix

import Control.Monad.Par.IO
import Control.Monad.Par.Class
import Control.Monad.IO.Class

import Control.Exception

-- <<main
main = do
  (d:_) <- getArgs
  runParIO (find ".git" d) >>= mapM_ print
-- >>

-- <<find
find :: String -> FilePath -> ParIO [FilePath]
find s d = do
  fs <- liftIO $ getDirectoryContents d
  let fs' = sort $ filter (`notElem` [".",".."]) fs
  let ps = map (d </>) fs'
  rest <- foldr (subfind s) dowait ps []
  if s `elem` fs'
     then do
         let config = d </> s </> "config"
         fe <- liftIO . doesFileExist $ config
         if fe
            then do
                fc <- liftIO $ readFile config
                if checkConfig fc
                   then return $ config:rest
                   else return rest
            else return rest
     else return rest
 where
   dowait vs = loop (reverse vs)

   loop [] = return []
   loop (v:vs) = do
      r <- get v
      as <- loop vs
      return $ r ++ as
-- >>

-- <<subfind
subfind :: String -> FilePath
        -> ([IVar [FilePath]] -> ParIO [FilePath])
        ->  [IVar [FilePath]] -> ParIO [FilePath]

subfind s p inner ivars = do
  isdir <- liftIO $ doesDirectoryExist p
  if not isdir
     then inner ivars
     else do v <- new                   -- <1>
             fork (find s p >>= put v)  -- <2>
             inner (v : ivars)          -- <3>
-- >>

-- <<checkConfig
checkConfig :: String -> Bool
checkConfig cs = (\(_,fs,_,_) -> fs /= "")
                 (cs =~ "[^/]+:[^/]+@" :: (String, String, String, [String]))
-- >>

