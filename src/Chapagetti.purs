module Chapagetti where

import Prelude

import Control.Monad.Eff.Uncurried (EffFn1)
import Data.Function.Uncurried (Fn2, runFn2)
import JollyPong (Store)
import React (ReactClass, ReactElement)

-- | a Redux Provider element that takes a store
reduxProvider :: forall state action e
   . Store e state action
  -> ReactElement
  -> ReactElement
reduxProvider store child =
  runFn2 _reduxProvider store child

-- | Newtype helper for mapStateToProps
newtype MapState state props = MapState
  (state -> { | props})

-- | Newtype helper for mapDispatchToProps
newtype MapDispatch e action props = MapDispatch
  (EffFn1 e action Unit -> { | props})

-- | connect a mapState and mapDispatch to a tree.
-- | Use the merged total props for our class, but expose top level props explicitly.
-- | Note that this function is Partial because it relies on the upstream
-- | component tree having a reduxProvider with the correct state and action types.
connect :: forall state action stateP dispatchP merged topProps props e
   . Union stateP dispatchP merged
  => Union merged topProps props
  => MapState state stateP
  -> MapDispatch e action dispatchP
  -> ReactClass { | props}
  -> ReactClass { | topProps}
connect mapState mapDispatch =
  runFn2 _connect mapState mapDispatch

foreign import _reduxProvider :: forall store reactClass
   . Fn2
      store
      ReactElement
      reactClass

foreign import _connect :: forall mapState mapDispatch origProps props
   . Fn2
       mapState
       mapDispatch
       (ReactClass origProps -> ReactClass props)
