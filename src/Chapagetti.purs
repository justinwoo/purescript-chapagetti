module Chapagetti where

import Prelude

import Data.Function.Uncurried as FU
import Effect.Uncurried as EU
import JollyPong (Store)
import Prim.Row as Row

-- | a Redux Provider element that takes a store
reduxProvider :: forall state action reactElement
   . Store state action
  -> reactElement
  -> reactElement
reduxProvider store child =
  FU.runFn2 _reduxProvider store child

-- | Newtype helper for mapStateToProps
newtype MapState state props = MapState
  (state -> { | props})

-- | Newtype helper for mapDispatchToProps
newtype MapDispatch action props = MapDispatch
  (EU.EffectFn1 action Unit -> { | props})

-- | connect a mapState and mapDispatch to a tree.
-- | Use the merged total props for our class, but expose top level props explicitly.
-- | Note that this function is Partial because it relies on the upstream
-- | component tree having a reduxProvider with the correct state and action types.
connect :: forall state action stateP dispatchP merged topProps props reactComponent
   . Row.Union stateP dispatchP merged
  => Row.Union merged topProps props
  => MapState state stateP
  -> MapDispatch action dispatchP
  -> reactComponent { | props}
  -> reactComponent { | topProps}
connect mapState mapDispatch =
  FU.runFn2 _connect mapState mapDispatch

foreign import _reduxProvider :: forall store reactElement reactClass
   . FU.Fn2 store reactElement reactClass

foreign import _connect :: forall reactComponent mapState mapDispatch origProps props
   . FU.Fn2 mapState mapDispatch (reactComponent origProps -> reactComponent props)
