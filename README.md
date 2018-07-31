# Purescript-Chapagetti

A simple wrapper around React-Redux that provides real row unions for working with mapState and mapDispatch.

This is meant to be a reference for you to implement something similar in your own project.

![](https://i.imgur.com/94WNLaX.png)

### Warning

Connect will always be a partial function because the React Context-injected Store can't be tracked in any reasonable way. While I would put `Partial` as a constraint on `connect`, this would be heavy-handed considering that any approach that duct-tapes in Redux will always be just that -- fairly brittle. You should really try to migrate your application from the logical core first if you can. This library exists only for integration purposes.

## Example

From [test/Main.purs](test/Main.purs)

```hs
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
```
