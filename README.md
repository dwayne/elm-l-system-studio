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
        | startPosition = ( 250, 750 )
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
        | startPosition = ( 500, 500 )
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
        | startPosition = ( 500, 750 )
        , startHeading = Angle.fromDegrees 270
        , lineLength = 3
        , turningAngle = Angle.fromDegrees 22.5
    }
```
