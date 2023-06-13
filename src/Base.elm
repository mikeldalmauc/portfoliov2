module Base exposing (..)

import Element exposing (Attribute, rgb, Device, DeviceClass(..))
import Element.Font as Font
import Element exposing (Color)
import Mailto exposing (mailto, subject)
import Html
import Html.Attributes as Attrs
import Svg 
import Svg.Attributes as SvgAttrs
import Html exposing (Html)


            
type alias LayoutConf =                 
    { fontSize : Int
    , subtitleFontSize : Int
    , sliderWidthFactor : Float
    , sliderHeightFactor: Float
    , leftDisplacement : Float
    , upDisplacement : Float
    , vSliderWidthFactor : Int
    }

layoutConf : Device -> LayoutConf
layoutConf device =
    let
       (deviceClass, deviceOrientation) = 
            case device of
                { class, orientation} -> (class, orientation)
        
    in
        case deviceClass of
            BigDesktop ->
                { fontSize=120
                , subtitleFontSize = 40
                , sliderWidthFactor=0.5
                , sliderHeightFactor=0.7
                , leftDisplacement=200.0
                , upDisplacement=100.0
                , vSliderWidthFactor = 2
                }
            _ ->
                { fontSize=70
                , subtitleFontSize = 20
                , sliderWidthFactor=0.65
                , sliderHeightFactor=0.76
                , leftDisplacement=100.0
                , upDisplacement=50.0
                , vSliderWidthFactor = 1
                }




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

orange : Color
orange = rgb 0.95 0.5 0.1

lightOrange : Color
lightOrange = rgb 0.95 0.7 0.5

ligthBlue : Color
ligthBlue = rgb 0.5 0.7 0.95

goldenRatio : Float
goldenRatio = 1.61803398875

gitHubSvg : Html msg
gitHubSvg = 
    Svg.svg
    [ SvgAttrs.height "32"
    , SvgAttrs.width "32"
    , SvgAttrs.viewBox "0 0 16 16"
    ][
        Svg.path [SvgAttrs.d "M8 0c4.42 0 8 3.58 8 8a8.013 8.013 0 0 1-5.45 7.59c-.4.08-.55-.17-.55-.38 0-.27.01-1.13.01-2.2 0-.75-.25-1.23-.54-1.48 1.78-.2 3.65-.88 3.65-3.95 0-.88-.31-1.59-.82-2.15.08-.2.36-1.02-.08-2.12 0 0-.67-.22-2.2.82-.64-.18-1.32-.27-2-.27-.68 0-1.36.09-2 .27-1.53-1.03-2.2-.82-2.2-.82-.44 1.1-.16 1.92-.08 2.12-.51.56-.82 1.28-.82 2.15 0 3.06 1.86 3.75 3.64 3.95-.23.2-.44.55-.51 1.07-.46.21-1.61.55-2.33-.66-.15-.24-.6-.83-1.23-.82-.67.01-.27.38.01.53.34.19.73.9.82 1.13.16.45.68 1.31 2.69.94 0 .67.01 1.3.01 1.49 0 .21-.15.45-.55.38A7.995 7.995 0 0 1 0 8c0-4.42 3.58-8 8-8Z"
        , SvgAttrs.fill "white"]
        []
    ]

instagramSvg : Html msg
instagramSvg = 
    Html.div [
        Attrs.attribute "style" <| "width: 64px; height: 64px; background-image: url('assets/instagram_logo.svg'); background-size: contain; background-repeat: no-repeat; background-position: center;"
    ] []
