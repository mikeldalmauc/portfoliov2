module Base exposing (..)

import Element exposing (Attribute, rgb)
import Element.Font as Font
import Element exposing (Color)
import Mailto exposing (mailto, subject)
import Gallery.Image exposing (..)
import Html
import Html.Attributes as Attrs

slideCustom : List (Html.Attribute msg) -> Url -> Size -> Html.Html msg
slideCustom attrs url size =
    Html.img
        ([ Attrs.src url
         , Attrs.style "object-fit" (toObjectFit size)
         , Attrs.class "elm-gallery-image"
         ]
            ++ attrs
        )
        []

toObjectFit : Size -> String
toObjectFit size =
    case size of
        Cover ->
            "cover"

        Contain ->
            "contain"

brandFontAttrs : List (Attribute msg)
brandFontAttrs =
    [brandFont, Font.letterSpacing 3, Font.wordSpacing 1.4]

brandFont : Attribute msg
brandFont = Font.family
            [ Font.external
                { name = "EB Garamond"
                , url = "https://fonts.googleapis.com/css2?family=EB+Garamond:wght@800&display=swap"
                }
            , Font.serif
            ]

partnerMailto : String
partnerMailto =
    mailto "mikeldalmauc@gmail.co"
        |> subject "Hello Mikel"
        |> Mailto.toString

baseFontAttrs : List (Attribute msg)
baseFontAttrs =
    [baseFont100,  Font.hairline, Font.letterSpacing 1.2, Font.wordSpacing 1.2]


secondaryFontAttrs : List (Attribute msg)
secondaryFontAttrs =
    [baseFont400, Font.letterSpacing 1.2, Font.wordSpacing 1.2]


baseFont100 : Attribute msg
baseFont100 = Font.family
            [ Font.external
                { name = "Montserrat"
                , url = "https://fonts.googleapis.com/css2?family=Montserrat:wght@100&display=swap"
                }
            , Font.sansSerif
            ]

baseFont400 : Attribute msg
baseFont400 = Font.family
            [ Font.external
                { name = "Montserrat"
                , url = "https://fonts.googleapis.com/css2?family=Montserrat:wght@400&display=swap"
                }
            , Font.sansSerif
            ]


highlight : Color
highlight = rgb 1 1 1   

gray50 : Color
gray50 = rgb  0.5 0.5 0.5

gray80 : Color
gray80 = rgb  0.8 0.8 0.8


black08 : Color
black08 = rgb 0.09 0.09 0.09 