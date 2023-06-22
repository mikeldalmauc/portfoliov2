module Slider exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Events exposing (onClick)
import Base 
import Element.Font as Font
import Html.Attributes as Attrs
import Element.Border as Border
import Html exposing (input)

tabsSlider :  Device -> Int -> Int -> msg -> msg -> Element msg
tabsSlider device actual positions prev next = 
    let
        conf = Base.layoutConf device
        margin = (toFloat actual - 1) / (toFloat positions - 1) *80 |> round

        translate = toCssTranslate conf.vSliderPointerTranslate (positions - 1) (actual - 1) 0 0
        buttonAttrs = [
                  pointer
                , Background.color Base.black08
                , padding 10]
        buttons : Element msg
        buttons = 
            column 
            [spacing 60,
            centerX,
            centerY
            ] 
            [ el (buttonAttrs ++ [onClick prev , transparent <| actual == 1]) <| html <| Base.upArrowSvg "#7f7f7f"
            , el (buttonAttrs ++ [onClick next , transparent <| actual == positions]) <| html <| Base.downArrowSvg "#7f7f7f"]  

        thumb = el 
            [ paddingEach { top = 40, bottom = 40, left = 10, right = 10 }
            , Background.color Base.black08
            , Font.color Base.gray50
            , centerX
            -- , moveDown <| toFloat margin
            , htmlAttribute (Attrs.attribute "style" <| styleSheet ++ " " ++ translate)
            , inFront buttons
            ] 
            <| text <| String.fromInt actual ++ "\n  /\n   " ++ String.fromInt positions

    in
    
        el 
        [ height fill 
        -- , rotate <| degrees -180
        , width <| px 1
        -- , explain Debug.todo
        , behindContent <|
            -- Slider track
            el
                [ width <| px 1
                , height fill
                , centerX
                , Background.color <| Base.gray50
                , Border.rounded 6
                ]
                Element.none
        -- , htmlAttribute (Attrs.attribute "style" <| "padding-top:" ++ fromInt margin ++ "%;")
        -- , spacingTop margin
        ] <| thumb 
    

phoneSlider : Device -> Int -> Int -> Element msg
phoneSlider device actual positions = 
    let       
        translate = toCssTranslatePhone (positions - 1) (actual - 1) 0 0

        thumb = el 
            [ paddingEach { top = 2, bottom = 2, left = 2, right = 2 }
            , Background.color Base.gray80
            , Border.rounded 100
            , Font.color Base.gray50
            , centerX
            -- , moveDown <| toFloat margin
            , htmlAttribute (Attrs.attribute "style" <| styleSheet ++ " " ++ translate)
            ] none

    in
        el 
            [ height fill 
            -- , rotate <| degrees -180
            , width <| px 1
            -- , explain Debug.todo
            , behindContent <|
                -- Slider track
                el
                    [ width <| px 1
                    , height fill
                    , centerX
                    , Background.color <| Base.gray50
                    , Border.rounded 6
                    ]
                    Element.none
            -- , htmlAttribute (Attrs.attribute "style" <| "padding-top:" ++ fromInt margin ++ "%;")
            -- , spacingTop margin
            ] <| thumb 
    


styleSheet :  String
styleSheet  =
    """            
       transition: -webkit-transform 400ms ease;
       transition: -moz-transform 400ms ease;
       transition: transform 400ms ease;
    """
        


toCssTranslate : Int -> Int -> Int -> Int -> Int -> String
toCssTranslate vSliderPointerTranslate slideCount index_ x y =
    "-webkit-transform: "
        ++ "translate(0px,"
        ++ String.fromFloat (toFloat index_ * (toFloat vSliderPointerTranslate / toFloat slideCount))
        ++ "vh);"
    ++
    "-moz-transform: "
        ++ "translate(0px,"
        ++ String.fromFloat (toFloat index_ * (toFloat vSliderPointerTranslate / toFloat slideCount))
        ++ "vh);"
    ++
    "transform: "
        ++ "translate(0px,"
        ++ String.fromFloat (toFloat index_ * (toFloat vSliderPointerTranslate / toFloat slideCount))
        ++ "vh);"




toCssTranslatePhone : Int -> Int -> Int -> Int -> String
toCssTranslatePhone slideCount index_ x y =
    "-webkit-transform: "
        ++ "translate(0px,"
        ++ String.fromFloat (toFloat index_ * (60 / toFloat slideCount))
        ++ "vh);"
    ++
    "-moz-transform: "
        ++ "translate(0px,"
        ++ String.fromFloat (toFloat index_ * (60 / toFloat slideCount))
        ++ "vh);"
    ++
    "transform: "
        ++ "translate(0px,"
        ++ String.fromFloat (toFloat index_ * (60 / toFloat slideCount))
        ++ "vh);"