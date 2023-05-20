module Base exposing (..)

import Element exposing (Attribute)
import Element.Font as Font


brandFontAttrs : List (Attribute msg)
brandFontAttrs =
    [brandFont, Font.letterSpacing 4, Font.wordSpacing 1.4]

brandFont : Attribute msg
brandFont = Font.family
            [ Font.external
                { name = "EB Garamond"
                , url = "https://fonts.googleapis.com/css2?family=EB+Garamond:wght@800&display=swap"
                }
            , Font.serif
            ]


baseFontAttrs : List (Attribute msg)
baseFontAttrs =
    [baseFont,  Font.hairline, Font.letterSpacing 1.2, Font.wordSpacing 1.2]

baseFont : Attribute msg
baseFont = Font.family
            [ Font.external
                { name = "Montserrat"
                , url = "https://fonts.googleapis.com/css2?family=Montserrat:wght@100&display=swap"
                }
            , Font.sansSerif
            ]