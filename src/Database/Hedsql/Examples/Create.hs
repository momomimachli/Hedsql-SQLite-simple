{-|
Module      : Hedsql/Common/Parser/TableManipulations/Create.hs
Description : Collection of CREATE statements.
Copyright   : (c) Leonard Monnier, 2015
License     : GPL-3
Maintainer  : leonard.monnier@gmail.com
Stability   : experimental
Portability : portable

A collection of CREATE statements to be used in tests or as examples.
-}
module Database.Hedsql.Examples.Create
    (
    -- * Full examples
      countries
    , people
    
    -- * Basics
    , simpleTable
    , defaultVal
    
    -- * Constraints
    
    -- ** PRIMARY KEY
    , primaryKeyCol
    , primaryKeyColAuto
    , primaryKeyTable
    
    -- ** UNIQUE
    , createUnique
    , createUniqueT
    
    -- ** NOT NULL
    , noNulls
    
    -- ** FOREIGN KEY
    , createFK
    
    -- ** CHECK
    , createCheck
    , createChecks
    ) where

--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------

import Database.Hedsql.Ext
import Database.Hedsql.SqLite

--------------------------------------------------------------------------------
-- PUBLIC
--------------------------------------------------------------------------------

----------------------------------------
-- Full examples
----------------------------------------

{-|
MariaDB and SqLite:
@
CREATE TABLE "Countries" (
    "countryId"   INTEGER      PRIMARY KEY AUTOINCREMENT,
    "name"        VARCHAR(256) NOT NULL, UNIQUE,
    "size"        INTEGER,
    "inhabitants" INTEGER
)
@

PostgreSQL:
@
CREATE TABLE "Countries" (
    "countryId"   serial       PRIMARY KEY,
    "name"        varchar(256) NOT NUL, UNIQUE,
    "size"        integer,
    "inhabitants" integer
)
@
-}
countries :: Create a
countries =
    createTable
        "Countries"
        [ wrap  (col "countryId"   integer)       /++ primary True
        , wrap  (col "name"        (varchar 256)) /++ [notNull, unique]
        , wrap $ col "size"        integer
        , wrap $ col "inhabitants" integer
        ]

{-|
MariaDB and SqLite:
@
CREATE TABLE "People" (
   "personId"   INTEGER      PRIMARY KEY AUTOINCREMENT,
   "title"      CHAR(2)      DEFAULT('Ms')
   "firstName"  VARCHAR(256) NOT NULL,
   "lastName"   VARCHAR(256) NOT NULL,
   "age"        INTEGER      CHECK ("age" > -1),
   "married"    BOOLEAN      DEFAULT(FALSE), NOT NULL
   "father"     INTEGER      REFERENCES "People"("personId")
   "passportNo" VARCHAR(256) UNIQUE,
   "countryId"  INTEGER      REFERENCES "Countries"("countryId")
)
@

PostgreSQL:
@
CREATE TABLE "People" (
   "personId"   serial       PRIMARY KEY,
   "title"      char(2)      DEFAULT('Ms')
   "firstName"  varchar(256) NOT NULL,
   "lastName"   varchar(256) NOT NULL,
   "age"        integer      CHECK ("age" > -1),
   "married"    boolean      DEFAULT(FALSE), NOT NULL
   "passportNo" varchar(256) UNIQUE,
   "father"     integer      REFERENCES "People"("personId")
   "countryId"  integer      REFERENCES "Countries"("countryId")
)
@
-}
people :: Create a
people =
    createTable
        "People"
        [ wrap (col "personId"   integer)       /++ primary True
        , wrap (col "title"      (char 2))      /++ defaultValue (value "Ms")
        , wrap (col "firstName"  (varchar 256)) /++ notNull
        , wrap (col "lastName"   (varchar 256)) /++ notNull
        , wrap age /++ check (age /> value (-1::Int))
        , wrap (col "married"    boolean)       /++ [ defaultValue (value False)
                                                    , notNull
                                                    ]
        , wrap (col "passportNo" (varchar 256)) /++ unique
        , wrap (col "father"     integer) /++ foreignKey "People" "personId"
        , wrap (col "countryId"  integer) /++ foreignKey "Countries" "countryId"
        ]
    where
        age = col "age" integer
----------------------------------------
-- Basics
----------------------------------------

-- | > CREATE TABLE "People" ("firstName" varchar(256))        
simpleTable :: Create a
simpleTable = createTable "People" [wrap (col "firstName" $ varchar 256)]
      
-- | CREATE TABLE "People" ("country" integer DEFAULT(1))
defaultVal :: Create a
defaultVal = createTable
    "People"
    [wrap (col "country" integer) /++ defaultValue (value (1::Int))]

----------------------------------------
-- Constraints
----------------------------------------

--------------------
-- PRIMARY KEY
--------------------

{-|
Maria DB and SqLite:
> CREATE TABLE "People" ("personId" INTEGER PRIMARY KEY)

PostgreSQL:
> CREATE TABLE "People" ("personId" integer PRIMARY KEY)
-}
primaryKeyCol :: Create a
primaryKeyCol =
    createTable "People" [wrap (col "personId" integer) /++ primary False]

{-|
Maria DB and SqLite:
> CREATE TABLE "People" ("id" INTEGER PRIMARY KEY AUTOINCREMENT)

PostgreSQL:
> CREATE TABLE "People" ("id" serial PRIMARY KEY)
-}
primaryKeyColAuto :: Create a
primaryKeyColAuto =
    createTable "People" [wrap (col "personId" integer) /++ primary True]

{-|
CREATE TABLE "People" (
    "firstName"       varchar(256),
    "lastName"        varchar(256),
    CONSTRAINT "pk" PRIMARY KEY ("firstName", "lastName")
)
-}
primaryKeyTable :: Create a
primaryKeyTable =
    createTable
        "People"
        [ wrap $ col "firstName" (varchar 256)
        , wrap $ col "lastName" (varchar 256)]
    /++ tableConstraint "pk" (primaryT ["firstName", "lastName"])

--------------------
-- UNIQUE
--------------------

-- | CREATE TABLE "People" ("passportNo" varchar(256) UNIQUE)
createUnique :: Create a
createUnique =
    createTable "People" [wrap (col "passportNo" (varchar 256)) /++ unique]
    
{-|
CREATE TABLE "People" (
    "firstName" varchar(256),
    "lastName"  varchar(256),
    UNIQUE ("firstName", "lastName")
)
-}
createUniqueT :: Create a
createUniqueT =
    createTable "People" cs /++ tableConstraint "" (uniqueT cs)
    where
        cs =
            [ wrap $ col "firstName" $ varchar 256
            , wrap $ col "lastName"  $ varchar 256
            ]

--------------------
-- NOT NULL
--------------------

{-|
CREATE TABLE "People" (
    "firstName" varchar(256) CONSTRAINT "no_null" NOT NULL,
    "lastName"  varchar(256) NOT NULL
)
-}
noNulls :: Create a
noNulls =
    createTable "People" cs
    where
        cs =
            [ wrap (col "firstName" (varchar 256))
                /++ colConstraint "no_null" notNull
            , wrap (col "lastName"  (varchar 256)) /++ notNull
            ]

--------------------
-- FOREIGN KEY
--------------------

{-|
CREATE TABLE "People" ("countryId" integer REFERENCES "Countries"("countryId"))
-}
createFK :: Create a
createFK =
    createTable
        "People"
        [wrap (col "countryId" integer) /++ foreignKey "Countries" "countryId"]

--------------------
-- CHECK
--------------------
     
-- | CREATE TABLE "People" ("age" integer CHECK ("age" > -1))
createCheck :: Create a
createCheck =
    createTable
        "People"
        [wrap age /++ check (age /> intVal (-1))]
    where
        age = col "age" integer
        
{-|            
CREATE TABLE "People" (
    "lastName" varchar(256),
    "age"      integer,
    CONSTRAINT "checks" CHECK ("age" > -1 AND "lastName" <> '')
)
-}
createChecks :: Create a
createChecks =
    createTable
        "People"
        [ wrap lastName
        , wrap age
        ]
    /++ c1
    where
        age = col "age"integer
        lastName = col "lastName" $ varchar 256
        c1 =
            tableConstraint "checks" $
                  checkT $
                      (age /> intVal (-1)) `and_` (lastName /<> value "")