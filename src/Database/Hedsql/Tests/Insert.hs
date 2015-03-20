module Database.Hedsql.Tests.Insert
    ( tests
    ) where

--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------

import Database.Hedsql.Examples.Insert

import Test.Framework                 (Test, testGroup)
import Test.Framework.Providers.HUnit (testCase)
import Test.HUnit              hiding (Test)

import qualified Database.Hedsql.PostgreSQL as P
import qualified Database.Hedsql.SqLite     as S

--------------------------------------------------------------------------------
-- PRIVATE
--------------------------------------------------------------------------------

----------------------------------------
-- All vendors
----------------------------------------

testWithCols :: Test
testWithCols = testCase "Insert with columns names" assertInsert
    where
        assertInsert :: Assertion
        assertInsert = assertEqual
            "Insert with columns names is incorrect"
            (  "INSERT INTO \"People\" "
            ++ "(\"title\", \"firstName\", \"lastName\", \"age\", "
            ++ "\"passportNo\", \"countryId\") "
            ++ "VALUES ('Mr', 'Julius', 'Ceasar', 2000, NULL, NULL, 2)"
            )
            (S.parse withCols)

----------------------------------------
-- SqLite
----------------------------------------

testJulius :: Test
testJulius = testCase "Insert example Julius Ceasar" assertInsert
    where
        assertInsert :: Assertion
        assertInsert = assertEqual
            "Insert of Julius Ceasar is incorrect"
            (  "INSERT INTO \"People\" "
            ++ "VALUES (1, 'Mr', 'Julius', 'Ceasar', 2000, 1, NULL, 2, 2)"
            )
            (S.parse juliusCeasar)

----------------------------------------
-- PostgreSQL
----------------------------------------

testDefaultValPostgreSQL :: Test
testDefaultValPostgreSQL = testCase "Insert with a DEFAULT value" assertInsert
    where
        assertInsert :: Assertion
        assertInsert = assertEqual
            "Insert with a DEFAULT value is incorrect"
            (  "INSERT INTO \"People\" "
            ++ "VALUES (NULL, DEFAULT, 'Julius', 'Ceasar', 2000, "
            ++ "TRUE, NULL, NULL, 2)"
            )
            (P.parse defaultValPostgreSQL)

testMultiValsPostgreSQL :: Test
testMultiValsPostgreSQL = testCase "Multiple inserts" assertInsert
    where
        assertInsert :: Assertion
        assertInsert = assertEqual
            "Multiple inserts are incorrect"
            (  "INSERT INTO \"People\" "
            ++ "(\"title\", \"firstName\", \"lastName\", \"age\", "
            ++ "\"passportNo\", \"countryId\") "
            ++ "VALUES ('Mr', 'Julius', 'Ceasar', 2000, NULL, NULL, 2), "
            ++ "('Mr', 'Gnaeus', 'Pompeius', 2000, NULL, NULL, 2)"
            )
            (P.parse multiValsPostgreSQL)

--------------------------------------------------------------------------------
-- PUBLIC
--------------------------------------------------------------------------------

-- | Gather all tests.
tests :: Test
tests = testGroup "Insert"
    [ testGroup "AllVendors"
        [ testWithCols
        ]
    , testGroup "SqLite"
        [ testJulius
        ] 
    , testGroup "PostgreSQL"
        [ testDefaultValPostgreSQL
        , testMultiValsPostgreSQL
        ]
    ]