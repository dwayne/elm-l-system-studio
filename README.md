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
        | startPosition = { x = 250, y = 750 }
        , lineLength = 5
        , turningAngle = Angle.fromDegrees 90
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
        | startPosition = { x = 500, y = 500 }
        , lineLength = 10
        , turningAngle = Angle.fromDegrees 90
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
        | startPosition = { x = 500, y = 750 }
        , startHeading = Angle.fromDegrees 270
        , lineLength = 3
        , turningAngle = Angle.fromDegrees 22.5
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
        | startPosition = { x = 500, y = 750 }
        , startHeading = Angle.fromDegrees 270
        , lineLength = 1
        , lineLengthScaleFactor = 1.36
        , turningAngle = Angle.fromDegrees 45
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
    Generator.generate 4 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | startPosition = { x = 250, y = 750 }
        , lineLength = 5
        , turningAngle = Angle.fromDegrees 90
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
        | startPosition = { x = 500, y = 750 }
        , startHeading = Angle.fromDegrees 270
        , lineLength = 5
        , turningAngle = Angle.fromDegrees 90
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
    Generator.generate 5 rules axiom

defaultSettings =
    Settings.default

settings =
    { defaultSettings
        | startPosition = { x = 150, y = 500 }
        , lineLength = 3
        , turningAngle = Angle.fromDegrees 90
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
        | startPosition = { x = 350, y = 650 }
        , lineLength = 6
        , turningAngle = Angle.fromDegrees 60
    }
```
