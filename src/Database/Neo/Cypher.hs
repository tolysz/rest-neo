{-# Language OverloadedStrings
           , RecordWildCards
           , ExistentialQuantification
           , CPP
            #-}
{-# LANGUAGE DeriveGeneric #-}

module Database.Neo.Cypher
 ( Cypher (..)
 , addP
 , addT
 )
where

import Prelude
import Data.Text (Text, pack)
import qualified Data.Text as T
import Data.Aeson
import Data.Aeson.Types
import Data.String
import Data.Default
#if !(MIN_VERSION_base(4,8,0))
import Data.Monoid (Monoid(..))
#endif
#if !(MIN_VERSION_base(4,11,0))
import Data.Semigroup (Semigroup(..))
#endif
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import GHC.Generics
import qualified Data.Vector as V

data Cypher = Cypher
      { query  :: Text
      , params :: Map Text Value
      } deriving (Show, Generic)

instance Default Cypher where
  def = Cypher "" def

instance Semigroup Cypher where
  Cypher q1 p1 <> Cypher q2 p2 = Cypher {..}
           where
             query = if T.null q1 then q2 else q1
             params = dicJoin p1 p2

instance Monoid Cypher where
  mempty = def

dicJoin = Map.unionWith f
   where
     f (Array v1) (Array v2) = Array $ v1 <> v2
     f (Array v1) a = Array $ v1 <> V.singleton a
     f a (Array v2) = Array $ V.singleton a <> v2
     f o1 o2 = Array $ V.fromList [o1, o2]

instance IsString Cypher where
  fromString s = def {query = pack s}

addP :: ToJSON b =>  (Text,b) -> Cypher
addP (a,b) = def{ params = Map.fromList [(a, toJSON b)]}

addT :: Text -> Text -> Cypher
addT a b = def{ params = Map.fromList [(a, toJSON b)]}

instance ToJSON Cypher
instance FromJSON Cypher
