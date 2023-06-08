module Base exposing (..)

import Element exposing (Attribute, rgb)
import Element.Font as Font
import Element exposing (Color)
import Mailto exposing (mailto, subject)
import Gallery.Image exposing (..)
import Html
import Html.Attributes as Attrs



-- srcset="example-320.jpg 320w, example-640.avif 640w, example-1024.webp 1024w, 
-- example-1280.jpg 1280w, example-1920.avif 1920w, example-2560.webp 2560w">
srcSet : Url -> String
srcSet image =
    List.map (\suffix -> image ++ suffix) (crossProduct ["or"] ["avif", "webp", "jpg"])
        |> String.join ", "
    

crossProduct : List String -> List String -> List String
crossProduct sizes formats =
    List.concatMap (\size -> List.map (\format -> "-" ++ size ++ "." ++ format ++ " " ++ (sizeWidth size)) formats) sizes

sizeWidth : String -> String
sizeWidth size =
    case size of 
        "or" ->
            "2560w"
        "lg" ->
            "1920w"
        "md" ->
            "1280w"
        "sm" ->
            "1024w"
        "xs" ->
            "640w"
        "xxs" ->
            "320w"
        _ ->
            "1280w"

slideCustom : List (Html.Attribute msg) -> Url -> Size -> Html.Html msg
slideCustom attrs url size =

    Html.img
        ([ Attrs.src (url ++ "-or.jpg")
        , Attrs.style "object-fit" (toObjectFit size)
        , Attrs.class "elm-gallery-image"
        , Attrs.attribute "srcset" <| srcSet url
        , Attrs.attribute "sizes" <| "100vw"
        ]
            ++ attrs
        )
        [ Html.div 
            [ Attrs.attribute "position" "absolute"
            , Attrs.attribute "pointer-events" "none"
            , Attrs.attribute "font-family" "EB Garamond, serif"
            , Attrs.attribute "font-weight" "400"
            , Attrs.attribute "font-size" "67"
            ] [Html.text "hello"]
        ]

toObjectFit : Size -> String
toObjectFit size =
    case size of
        Cover ->
            "cover"

        Contain ->
            "contain"

partnerMailto : String
partnerMailto =
    mailto "mikeldalmauc@gmail.co"
        |> subject "Hello Mikel"
        |> Mailto.toString



brandFontAttrs : List (Attribute msg)
brandFontAttrs =
    [brandFont, Font.letterSpacing 3, Font.wordSpacing 1.4]

baseFontAttrs : List (Attribute msg)
baseFontAttrs =
    [baseFont100,  Font.hairline, Font.letterSpacing 1.2, Font.wordSpacing 1.2]


secondaryFontAttrs : List (Attribute msg)
secondaryFontAttrs =
    [baseFont400, Font.letterSpacing 1.2, Font.wordSpacing 1.2]


brandFont : Attribute msg
brandFont = Font.family
            [ Font.external
                { name = "EB Garamond"
                , url = "https://fonts.googleapis.com/css2?family=EB+Garamond:wght@800&display=swap"
                }
            , Font.serif
            ]

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


goldenRatio : Float
goldenRatio = 1.61803398875