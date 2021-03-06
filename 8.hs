import Data.Char (digitToInt, isSpace)
import Data.Foldable (find)
import Data.List (elemIndex, findIndex, sort)
import Data.Maybe (fromMaybe)
import Util (remove, set, split, trim)

parseSegments :: String -> [String]
parseSegments = filter (not . null) . map (trim isSpace) <$> split ' '

parseLine :: String -> ([String], [String])
parseLine line = case map parseSegments $ split '|' line of
  [a, b] -> (a, b)
  _ -> error "failed to split once"

parse :: String -> [([String], [String])]
parse input = map parseLine $ filter (not . null) $ map (trim isSpace) $ split '\n' input

isSuperSet :: Eq a => [a] -> [a] -> Bool
isSuperSet a = all (`elem` a)

-- digits with 5 segments: 5 2 3
-- digits with 6 segments: 0 6

-- STEPS
-- - 1: has 2 segments
-- - 7: has 3 segments
-- - 4: has 4 segments
-- - 8: has 7 segments
-- - 3: has 5 segments and contains both segments of 1
-- - 6: has 6 segments and does not contain all segment of 1
-- - 0: has 6 segments and does not contain all segments of the number 4
-- - 9: has 6 segments
-- - 2: has 5 segments and is not a subset of 6
-- - 5: has 5 segments

type Step = (Int, String -> [String] -> Bool)

steps :: [Step]
steps =
  [ (1, \s _ -> length s == 2),
    (7, \s _ -> length s == 3),
    (4, \s _ -> length s == 4),
    (8, \s _ -> length s == 7),
    (3, \s results -> length s == 5 && isSuperSet s (results !! 1)),
    (6, \s results -> length s == 6 && not (isSuperSet s (results !! 1))),
    (0, \s results -> length s == 6 && not (isSuperSet s (results !! 4))),
    (9, \s _ -> length s == 6),
    (2, \s results -> length s == 5 && not (isSuperSet (results !! 6) s)),
    (5, \s _ -> length s == 5)
  ]

extract :: (a -> Bool) -> [a] -> ([a], a)
extract f list = case index of
  Just index -> (remove index list, list !! index)
  Nothing -> (list, undefined)
  where
    index = findIndex f list

solveSegments :: [String] -> [String]
solveSegments segments = snd $ foldl f (segments, map (const "") [0 .. 9]) steps
  where
    f :: ([String], [String]) -> Step -> ([String], [String])
    f (segments, results) (n, step) = (rem, set n pattern results)
      where
        (rem, pattern) = extract (`step` results) segments

unwrap :: Maybe a -> a
unwrap (Just a) = a
unwrap Nothing = error "tried to unwrap Nothing"

matchOutputs :: [String] -> [String] -> [Int]
matchOutputs segments = map unwrap <$> map ((`elemIndex` map sort segments) . sort)

digitsToInt :: [Int] -> Int
digitsToInt digits = f $ reverse digits
  where
    f [n] = n
    f (n : list) = n + (10 * f list)
    f [] = error "no digits"

solveLine :: ([String], [String]) -> Int
solveLine (segments, outputs) = digitsToInt $ matchOutputs (solveSegments segments) outputs

solve :: [([String], [String])] -> Int
solve = sum . map solveLine

main = interact $ show . solve . parse
