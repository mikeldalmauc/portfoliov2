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
import Element.HexColor as HexColor


            
type alias LayoutConf =                 
    { fontSize : Int
    , subtitleFontSize : Int
    , sliderWidthFactor : Float
    , sliderHeightFactor : Float
    , leftDisplacement : Float
    , upDisplacement : Float
    , vSliderWidthFactor : Int
    , vSliderPointerTranslate : Int
    , arrowHeight : Int
    , arrowWidth : Int
    , arrowPadding : Int
    , aboutFontSize : Int
    , aboutLinkFontSize : Int
    , aboutWidth : Int
    , tab0TitleFontSize : Int
    , tab0SubTitleFontSize : Int
    , tabWidthPortion : Int
    , tabHeightPortion : Int
    , liveExampleFontSize : Int
    , sourceFontSize : Int
    , linksPadding : Int
    , linksRightDisplacement : Float
    , githubSize : Int
    , igSize : Int
    , instragramEmbeddingMaxWidth : Int
    , instragramEmbeddingMinWidth : Int
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
                , vSliderPointerTranslate = 80
                , arrowHeight = 60
                , arrowWidth = 20
                , arrowPadding = 45
                , aboutFontSize = 35
                , aboutLinkFontSize = 14
                , aboutWidth = 1000
                , tab0TitleFontSize = 60
                , tab0SubTitleFontSize = 22
                , tabWidthPortion = 14
                , tabHeightPortion = 1
                , liveExampleFontSize = 40
                , sourceFontSize = 25
                , linksPadding = 40
                , linksRightDisplacement = 200.0
                , githubSize = 32
                , igSize = 64
                , instragramEmbeddingMaxWidth = 540
                , instragramEmbeddingMinWidth = 150
                }
            Phone -> 
                { fontSize=30
                , subtitleFontSize = 20
                , sliderWidthFactor=0.65
                , sliderHeightFactor=0.65
                , vSliderPointerTranslate = 60
                , leftDisplacement=30.0
                , upDisplacement=20.0
                , vSliderWidthFactor = 1
                , arrowHeight = 30
                , arrowWidth = 10
                , arrowPadding = 0
                , aboutFontSize = 8
                , aboutLinkFontSize = 6
                , aboutWidth = 600
                , tab0TitleFontSize = 40
                , tab0SubTitleFontSize = 18
                , tabWidthPortion = 16
                , tabHeightPortion = 1
                , liveExampleFontSize = 12
                , sourceFontSize = 10
                , linksPadding = 10
                , linksRightDisplacement = 70.0
                , githubSize = 16
                , igSize = 32
                , instragramEmbeddingMaxWidth = 200
                , instragramEmbeddingMinWidth = 150
                }
            _ ->
                { fontSize=70
                , subtitleFontSize = 20
                , sliderWidthFactor=0.65
                , sliderHeightFactor=0.76
                , leftDisplacement=100.0
                , upDisplacement=50.0
                , vSliderWidthFactor = 1
                , vSliderPointerTranslate = 75
                , arrowHeight = 60
                , arrowWidth = 20
                , arrowPadding = 45
                , aboutFontSize = 25
                , aboutLinkFontSize = 14
                , aboutWidth = 800
                , tab0TitleFontSize = 60
                , tab0SubTitleFontSize = 22
                , tabWidthPortion = 14
                , tabHeightPortion = 1
                , liveExampleFontSize = 40
                , sourceFontSize = 25
                , linksPadding = 40
                , linksRightDisplacement = 200.0
                , githubSize = 32
                , igSize = 64
                , instragramEmbeddingMaxWidth = 425
                , instragramEmbeddingMinWidth = 256
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
-- #7f7f7f

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

gitHubSvg : Int -> Html msg
gitHubSvg size = 
    Svg.svg
    [ SvgAttrs.height <| String.fromInt size
    , SvgAttrs.width <| String.fromInt size
    , SvgAttrs.viewBox "0 0 16 16"
    ][
        Svg.path [SvgAttrs.d "M8 0c4.42 0 8 3.58 8 8a8.013 8.013 0 0 1-5.45 7.59c-.4.08-.55-.17-.55-.38 0-.27.01-1.13.01-2.2 0-.75-.25-1.23-.54-1.48 1.78-.2 3.65-.88 3.65-3.95 0-.88-.31-1.59-.82-2.15.08-.2.36-1.02-.08-2.12 0 0-.67-.22-2.2.82-.64-.18-1.32-.27-2-.27-.68 0-1.36.09-2 .27-1.53-1.03-2.2-.82-2.2-.82-.44 1.1-.16 1.92-.08 2.12-.51.56-.82 1.28-.82 2.15 0 3.06 1.86 3.75 3.64 3.95-.23.2-.44.55-.51 1.07-.46.21-1.61.55-2.33-.66-.15-.24-.6-.83-1.23-.82-.67.01-.27.38.01.53.34.19.73.9.82 1.13.16.45.68 1.31 2.69.94 0 .67.01 1.3.01 1.49 0 .21-.15.45-.55.38A7.995 7.995 0 0 1 0 8c0-4.42 3.58-8 8-8Z"
        , SvgAttrs.fill "white"]
        []
    ]

instagramSvg : Int -> Html msg
instagramSvg size = 
    let
        sizeS = String.fromInt size  
    in
        Html.div [
            Attrs.attribute "style" <| "width:"++sizeS++"px; height: "++sizeS++"px; background-image: url('assets/instagram_logo.svg'); background-size: contain; background-repeat: no-repeat; background-position: center;"
        ] []

upArrowSvg : String -> Html msg
upArrowSvg color =
    arrowSvg color "0"

downArrowSvg : String -> Html msg
downArrowSvg color =
    arrowSvg color "180"

arrowSvg : String -> String -> Html msg
arrowSvg color rotation =
  Svg.svg
    [ SvgAttrs.height "20"
    , SvgAttrs.width "20"
    , SvgAttrs.viewBox "0 0 330 330"
    , SvgAttrs.transform <| "rotate(" ++ rotation ++ " 0 0)"
    ][
        Svg.path [SvgAttrs.d """M325.606,229.393l-150.004-150C172.79,76.58,168.974,75,164.996,75c-3.979,0-7.794,1.581-10.607,4.394
                                l-149.996,150c-5.858,5.858-5.858,15.355,0,21.213c5.857,5.857,15.355,5.858,21.213,0l139.39-139.393l139.397,139.393
                                C307.322,253.536,311.161,255,315,255c3.839,0,7.678-1.464,10.607-4.394C331.464,244.748,331.464,235.251,325.606,229.393z"""
           , SvgAttrs.fill color]
        []
    ]