# L-System Studio

## How to view the application

Enter the Devbox shell and use the build, `b`, and serve, `s`, aliases.

```bash
devbox shell
b
s
```

Then, open your browser at `localhost:8000`.

## Examples

### Example 1

This is the first example used in [Paul Bourke](https://paulbourke.net/fractals/)'s [L-System User Notes](https://paulbourke.net/fractals/lsys/).

```elm
rules =
    [ ( 'F', "F+F-F-FF+F+F-F" ) ]

axiom =
    "F+F+F+F"

chars =
    Generator.generate 3 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | lineLength = 1
        , turningAngle = Angle.fromDegrees 90
    }

transformOptions =
    { windowPosition = { x = -25, y = -25 }
    , windowSize = 100
    , canvasSize = canvasSize
    }
```

### Example 2

```elm
rules =
    [ ( 'F', "FF+F-F+F+FF" ) ]

axiom =
    "F+F+F+F"

chars =
    Generator.generate 3 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | lineLength = 10
        , turningAngle = Angle.fromDegrees 90
    }

transformOptions =
    { windowPosition = { x = -200, y = -150 }
    , windowSize = 250
    , canvasSize = canvasSize
    }
```

### Example 3

```elm
rules =
    [ ( 'F', "FF" )
    , ( 'X', "F-[[X]+X]+F[+FX]-X" )
    ]

axiom =
    "X"

chars =
    Generator.generate 6 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | startHeading = Angle.fromDegrees 90
        , lineLength = 1
        , lineWidth = 1
        , turningAngle = Angle.fromDegrees 22.5
    }

transformOptions =
    { windowPosition = { x = -25, y = 50 }
    , windowSize = 50
    , canvasSize = canvasSize
    }
```

### Example 4

```elm
rules =
    [ ( 'F', ">F<" )
    , ( 'a', "F[+x]Fb" )
    , ( 'b', "F[-y]Fa" )
    , ( 'x', "a" )
    , ( 'y', "b" )
    ]

axiom =
    "a"

chars =
    Generator.generate 15 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | startHeading = Angle.fromDegrees 90
        , lineLength = 1
        , lineLengthScaleFactor = 1.36
        , turningAngle = Angle.fromDegrees 45
    }

transformOptions =
    { windowPosition = { x = -300, y = 20 }
    , windowSize = 500
    , canvasSize = canvasSize
    }
```

### Example 5

```elm
rules =
    [ ( 'F', "FF+F++F+F" )
    ]

axiom =
    "F+F+F+F"

chars =
    Generator.generate 5 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | lineLength = 5
        , turningAngle = Angle.fromDegrees 90
    }

transformOptions =
    { windowPosition = { x = -10, y = -10 }
    , windowSize = 1250
    , canvasSize = canvasSize
    }
```

### Example 6

```elm
rules =
    [ ( 'X', "XFYFX+F+YFXFY-F-XFYFX" )
    , ( 'Y', "YFXFY-F-XFYFX+F+YFXFY" )
    ]

axiom =
    "X"

chars =
    Generator.generate 4 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | startHeading = Angle.fromDegrees 90
        , lineLength = 5
        , turningAngle = Angle.fromDegrees 90
    }

transformOptions =
    { windowPosition = { x = -400, y = 0 }
    , windowSize = 400
    , canvasSize = canvasSize
    }
```

### Example 7

```elm
rules =
    [ ( 'F', "F-F+F+F-F" )
    ]

axiom =
    "F"

chars =
    Generator.generate 4 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | lineLength = 3
        , turningAngle = Angle.fromDegrees 90
    }

transformOptions =
    { windowPosition = { x = 0, y = -175 }
    , windowSize = 250
    , canvasSize = canvasSize
    }
```

### Example 8

```elm
rules =
    [ ( 'F', "F-F++F-F" )
    ]

axiom =
    "F++F++F"

chars =
    Generator.generate 4 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | lineLength = 6
        , turningAngle = Angle.fromDegrees 60
    }

transformOptions =
    { windowPosition = { x = -50, y = -150 }
    , windowSize = 600
    , canvasSize = canvasSize
    }
```
