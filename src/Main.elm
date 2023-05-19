module Main exposing (..)

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)


menu : Element msg
menu =
    row
        [ width fill
        , height fill
        ]
        [ el [ alignLeft, centerY, rotate <| degrees -90] <| text "About"
        , el [ alignRight, centerY, rotate <| degrees -90] <| text "mikeldalmauc@gmail.com"
        ]


main : Html msg
main =
    layout
        [ width fill, height fill, inFront menu ]
    <|
        el [ centerX, centerY, padding 50 ] <|
            column
            [ width fill, height fill]
            [
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Mikel Dalmau" 
                    ]
            ,
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Image engineer"
                    ]
            ]