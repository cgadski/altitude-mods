module Main where

import Control.Monad (forever, void)
import System.IO

import FlightClub.Parser

commandFile = "./servers/command.txt"
logFile = "./servers/log.txt"

main :: IO ()
main = 
  do
    i <- openFile logFile ReadMode
    o <- openFile commandFile AppendMode
    void $ mainLoop i o

type State = ()

exec :: LogElement -> Maybe String
exec = const Nothing

-- the altitude server does this weird thing of
-- writing an EOF to the log file; it's actually
-- a static file, not a pipe
waitEvent :: Handle -> IO String
waitEvent h =
  do
    blocked <- hIsEOF h
    if blocked then waitEvent h
      else hGetLine h

mainLoop :: Handle -> Handle -> IO State
mainLoop i o = 
  do
    line <- waitEvent i
    putStrLn $ "recieved " ++ line
    case exec (parseLog line) of
      Nothing -> mainLoop i o
      Just str -> 
        do
          putStrLn $ "writing " ++ str
          hPutStrLn o str >> mainLoop i o