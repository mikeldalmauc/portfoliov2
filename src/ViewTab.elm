module ViewTab exposing (..)

import Gallery
import Gallery.Image as Image
import Html exposing (Html)
import Base exposing (slideCustom, layoutConf)
import Element exposing (..)
import Element.Font as Font
import Base exposing (goldenRatio)
import Tuple exposing (first)
import Html.Attributes as Attrs
import Element.Background as Background
import Element.Border as Border

type alias Texts = List (String, String)

imageSlides : List String -> List ( String, Html Gallery.Msg )
imageSlides  images =
    List.map (\image -> (image, slideCustom [] image Image.Contain )) images



styling : Html msg
styling =
    Html.node "style"
        []
        [ Html.text
            """
               .elm-gallery-text-itemcontainer p{
                    font-size:60px;
               }    
            """
        ]

imageConfig : Int -> Float -> Float -> Gallery.Config
imageConfig transition w h =
    Gallery.config
        { id = "image-gallery-tab1"
        , transition = transition
        , width = Gallery.px w 
        , height = Gallery.px h
        }

textConfig : Int -> Float -> Float -> Gallery.Config
textConfig transition w h =
    Gallery.config
        { id = "text-gallery"
        , transition = transition
         , width = Gallery.px w 
        , height = Gallery.px h
        }

textSlides : Device -> Texts ->  List ( String, Html Gallery.Msg )
textSlides device texts =
    List.map (\pair -> ( first pair, textSlide device pair)) texts


textSlide : Device -> (String, String) -> Html Gallery.Msg
textSlide device (title, subtitle) =
    let
        conf = layoutConf device

        subtitleFont = String.fromInt conf.subtitleFontSize ++ "px"
    in
        Html.article [] [ Html.h3 [Attrs.attribute "style" "margin-bottom: 10px;"] [ Html.text title]
            , Html.p 
                [ Attrs.attribute "style" <| "font-size:"++ subtitleFont ++"; letter-spacing: 1.2px; font-family: 'Montserrat', sans-serif;word-spacing: 1.2px; font-variant: normal;"
                ] [ Html.text subtitle ] ]

imagesTab1 : List String
imagesTab1 =
    List.map (\image -> "assets/tab1/" ++ image ++ "/" ++ image)
        [ 
          "portrait-21"
        , "3-black-woman"
        , "portrait-12"
        , "portrait-13"
        , "portrait-14"
        , "fallen-angel"
        , "lazo"
        , "velazquez-9"
        , "afternoon-wall"
        , "collage-digital-paintings"
        ]

textsTab1 : Texts
textsTab1 =
  [ 
      ("Malenia,\nBlade of\nMiquella", "Fanart from Dark Souls")
    , ("Woman on\npark", "Digital portrait")
    , ("Ona\nMorgan", "Digital portrait")
    , ("Spring\nOutdoors", "Digital portrait")
    , ("Urban\nPortrait", "Stylized Digital portrait")
    , ("Fallen\nAngel", "Digital painting")
    , ("Lazo", "Digital painting")
    , ("Tyrion\nLannister +\nVelazquez", "Master study and fanart")
    , ("City\nwall", "Digital painting")
    , ("", "Bondrew from Made in Abyss\nAlicia Vikander on Tomb Raider\nMMA Fighter\nMichelle Reis on Fallen Angels")
    ]

imagesTab2 : List String
imagesTab2 =
    List.map (\image -> "assets/tab2/" ++ image ++ "/" ++ image)
        [ 
          "ana-de-armas"
        , "calamar"
        , "carnival-row"
        , "pescados"
        , "ink-sketches"
        ]

textsTab2 : Texts
textsTab2 =
  [ 
      ("Ana de Armas\nBalde Runner", "Watercolor portrait")
    , ("Jung Ho-yeon\nSquid Game", "Watercolor portrait")
    , ("Cara\nDelevingne\nCarnival Row", "Watercolor portrait")
    , ("Fish", "Watercolor")
    , ("Sketches", "Ink sketches")
    ]

imagesTab3 : List String
imagesTab3 =
    List.map (\image -> "assets/tab3/" ++ image ++ "/" ++ image)
        [ 
          "tetris"
        , "particles"
        , "buscaminas"
        ]

textsTab3 : Texts
textsTab3 =
  [ 
      ("Tetris\n", "Implementation of Tetris in Elm")
    , ("Elm Particles\n", "Implementations using\nElm particles library")
    , ("Minesweeper", "Full js implementation of\nclassic Minesweeper game")
    ]

-- TODO add code for normal desktp sizes
linkToPage : Int -> Element msg
linkToPage tab = 
    let 
        path = case tab of 
            0 ->  
                { url = "/playground/tetris/tetris.html"
                , label = text "Play!"
                }
            1 -> 
                { url = "/playground/particles/app.html"
                , label = text "Try it!"
                }
            2 ->
                { url = "/playground/buscaminas/buscaminas.html"
                , label = text "Play!"
                }
            _ -> 
                { url = "/playground/buscaminas/buscaminas.html"
                , label = text "mikeldalmauc@gmail.com"
                }
    in 
        el (Base.secondaryFontAttrs ++ [
                  centerY
                , centerX
                , moveRight 200
                , Font.size 70
                , Background.color Base.black08
                , Border.color Base.gray80
                , Font.color Base.highlight
                , padding 40
                , Border.rounded 10
                , Border.solid
                , Border.width 4
                , Border.glow (rgba 1 1 1 0.5) 10.0
              , htmlAttribute (Attrs.attribute "style" "z-index:20")
            ]) 
            <| paragraph [Font.center, centerY, centerX, pointer] <| [
            link [] path ]