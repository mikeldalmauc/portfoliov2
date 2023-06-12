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
import Svg 
import Svg.Attributes as SvgAttrs

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
{--
Github svg 


--}

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

linkToPage : Device -> List ( String, Html Gallery.Msg )
linkToPage  device = 
    let 
        conf = layoutConf device
        
        sourcelabel = row [spaceEvenly ] [
              el [transparent True] <| text " "
            , el [transparent True] <| text " "
            , el [transparent True] <| text " "
            , html gitHubSvg
            , text "Source"
            , el [transparent True] <| text " "
            , el [transparent True] <| text " "
            , el [transparent True] <| text " "
            ]

        links = 
            [ ({ url = "/playground/tetris/tetris.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/tetris" , label = sourcelabel})
            , ({ url = "/playground/particles/app.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/elmparticles", label = sourcelabel})
            , ({ url = "/playground/buscaminas/buscaminas.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/buscaminas", label = sourcelabel})
            ]

        liveExampleAttrs = Base.secondaryFontAttrs ++ 
                        [ Font.size 40
                        , Font.color Base.lightOrange
                        , Font.center, centerY, centerX, pointer
                        , Font.underline
                        ]
        sourceAttrs = Base.secondaryFontAttrs ++ 
                        [ Font.size 25
                        , Font.color Base.ligthBlue
                        , Font.center, centerY, centerX, pointer
                        , Font.underline
                        ]
    in 
        List.indexedMap (\index (liveExample, sourceCode) ->
             (String.fromInt <| index+1,
                layoutWith {options = [noStaticStyleSheet]} [] <| column (Base.secondaryFontAttrs ++ [
                    centerY
                    , centerX
                    , moveRight 200
                    , Background.color Base.black08
                    , Border.color Base.gray80
                    , padding 40
                    , Border.rounded 10
                    , Border.solid
                    , Border.width 4
                    , Border.glow (rgba 1 1 1 0.5) 10.0
                    , htmlAttribute (Attrs.attribute "style" "z-index:20")
                    ]) 
                    <| [ paragraph liveExampleAttrs <| [ link [] liveExample ]
                        , el [transparent True] <| text " "
                        , paragraph sourceAttrs <| [ link [] sourceCode ]
                        ])
        ) links

    