# Purescript-Chappagetti

A simple wrapper around React-Redux that provides real row unions for working with mapState and mapDispatch.

![](https://i.imgur.com/94WNLaX.png)

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
