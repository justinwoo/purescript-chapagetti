module Test.Main where

import Prelude

import Chapagetti (MapDispatch(..), MapState(..), connect)
import Data.Function.Uncurried as FU
import Data.Maybe (fromMaybe)
import Data.Nullable (toMaybe)
import Effect (Effect)
import Effect.Console (log)
import Effect.Uncurried as EU
import Global.Unsafe (unsafeStringify)
import JollyPong (ActionVariant(..), Middleware(..), Reducer(..), combineReducers)
import Type.Row (type (+))

foreign import data ReactElement :: Type
foreign import data ReactComponent :: Type -> Type

type State =
  { a :: Int
  , b :: String
  }

state :: State
state =
  { a: 0
  , b: "a"
  }

type Action = ActionVariant ("ping" :: String)

aReducer :: Reducer Int (ActionVariant ("ping" :: String))
aReducer = Reducer $ FU.mkFn2 inner
  where
    inner a b = fromMaybe 0 $ add 1 <$> toMaybe a

bReducer :: Reducer String (ActionVariant ())
bReducer = Reducer $ FU.mkFn2 \a b -> "sdfd"

reducer :: Reducer State Action
reducer = combineReducers
  { a: aReducer
  , b: bReducer
  }

middleware :: Middleware State Action
middleware = Middleware go
  where
    go store = EU.mkEffectFn1 <<< handleAction
    handleAction next action = do
      log $ "action called: " <> unsafeStringify action
      EU.runEffectFn1 next action

type StateProps r = ( count :: String | r )

mapState :: MapState State (StateProps ())
mapState = MapState go
  where
    go {a} = {count: show a}

type DispatchProps r = ( doPing :: Effect Unit | r )

mapDispatch :: MapDispatch Action (DispatchProps ())
mapDispatch = MapDispatch go
  where
    go d | dispatch <- EU.runEffectFn1 d =
      { doPing: dispatch $ ActionVariant {type: "ping"}
      }

type InnerProps r = StateProps + DispatchProps + r

enhance :: forall topProps. ReactComponent { | InnerProps topProps } -> ReactComponent { | topProps }
enhance = connect mapState mapDispatch

main :: Effect Unit
main = do
  log "done"
