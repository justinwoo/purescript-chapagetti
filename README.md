# Purescript-Chapagetti

A simple wrapper around React-Redux that provides real row unions for working with mapState and mapDispatch.

![](https://i.imgur.com/94WNLaX.png)

### Warning

Connect will always be a partial function because the React Context-injected Store can't be tracked in any reasonable way. While I would put `Partial` as a constraint on `connect`, this would be heavy-handed considering that any approach that duct-tapes in Redux will always be just that -- fairly brittle. You should really try to migrate your application from the logical core first if you can. This library exists only for integration purposes.

## Example

From [test/Main.purs](test/Main.purs)

```hs
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
```
