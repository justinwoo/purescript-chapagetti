module Test.Main where

import Prelude

import Chapagetti (MapDispatch(..), MapState(..), connect, reduxProvider)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Uncurried (mkEffFn1, runEffFn1)
import DOM.HTML (window)
import DOM.HTML.Types (htmlDocumentToDocument)
import DOM.HTML.Window (document)
import DOM.Node.NonElementParentNode (getElementById)
import DOM.Node.Types (ElementId(..), documentToNonElementParentNode)
import Data.Function.Uncurried (mkFn2)
import Data.Maybe (fromJust, fromMaybe)
import Data.Nullable (toMaybe)
import Global.Unsafe (unsafeStringify)
import JollyPong (ActionVariant(..), Middleware(..), Reducer(..), Store, applyMiddleware, combineReducers, createStore)
import Partial.Unsafe (unsafePartial)
import React (ReactClass, ReactElement, createClassStateless, createFactory)
import React.DOM as D
import React.DOM.Props as P
import ReactDOM (render)

type State =
  { a :: Int
  , b :: String
  }

state :: State
state =
  { a: 0
  , b: "a"
  }

type Action =
  ActionVariant ("ping" :: String)

aReducer :: Reducer Int (ActionVariant ("ping" :: String))
aReducer = Reducer $ mkFn2 reducer
  where
    reducer a b = fromMaybe 0 $ add 1 <$> toMaybe a

bReducer :: Reducer String (ActionVariant ())
bReducer = Reducer $ mkFn2 \a b -> "sdfd"

reducer :: Reducer State Action
reducer = combineReducers
  { a: aReducer
  , b: bReducer
  }

middleware :: Middleware _ _ _ State Action
middleware = Middleware go
  where
    go store = mkEffFn1 <<< handleAction
    handleAction next action = do
      log $ "action called: " <> unsafeStringify action
      runEffFn1 next action

helloWorld :: {} -> ReactElement
helloWorld =
  createFactory $ enhance component
  where
    enhance :: ReactClass _ -> ReactClass {}
    enhance = connect mapState mapDispatch
    mapState :: MapState State _
    mapState = MapState go
      where
        go {a} = {count: show a}
    mapDispatch :: MapDispatch _ Action _
    mapDispatch = MapDispatch go
      where
        go d | dispatch <- runEffFn1 d =
          { doPing: dispatch $ ActionVariant {type: "ping"}
          }
    component = createClassStateless render
    render {doPing, count} = do
      D.div
        []
        [ D.h1' <<< pure <<< D.text $ "Count: " <> count
        , D.button
          [ P.onClick \_ -> doPing
          ]
          [ D.text "Click me!"]
        ]

view :: forall e. Store e State Action -> ReactElement
view store = reduxProvider store $ helloWorld {}

main = do
  enhancer <- applyMiddleware [middleware]
  store <- createStore reducer state enhancer
  win <- window
  doc <- document win
  elm <- getElementById
           (ElementId "example")
           (documentToNonElementParentNode (htmlDocumentToDocument doc))
  let a = view store
  render (view store) (unsafePartial $ fromJust elm)
