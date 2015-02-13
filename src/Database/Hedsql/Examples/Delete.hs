{-|
Module      : Database/Hedsql/Examples/Delete.hs
Description : Collection of DELETE statements.
Copyright   : (c) Leonard Monnier, 2015
License     : GPL-3
Maintainer  : leonard.monnier@gmail.com
Stability   : experimental
Portability : portable

A collection of DELETE statements to be used in tests or as examples.
-}
module Database.Hedsql.Examples.Delete
    ( deleteNotEqualTo 
    , deleteSubQuery
    ) where

--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------

import Database.Hedsql.SqLite

--------------------------------------------------------------------------------
-- PUBLIC
--------------------------------------------------------------------------------

-- | > DELETE FROM "People" WHERE "age" <> 20
deleteNotEqualTo :: Delete a
deleteNotEqualTo = deleteFrom "People" /++ where_ ("age" /<> value (20::Int))

{-|
> DELETE FROM "People"
>   WHERE "personId" IN
>        (SELECT "personId" FROM "Countries" WHERE "name" = 'Switzerland')
-}
deleteSubQuery :: Delete a
deleteSubQuery =
        deleteFrom "People"
    /++ where_
        (   in_ "personId"
        $   select "personId"
        /++ from "Countries"
        /++ where_ ("name" /== value "Switzerland")
        )