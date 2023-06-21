module ViewTab exposing (..)

import Gallery
import Gallery.Image as Image
import Html exposing (Html)
import Base exposing (layoutConf, instagramSvg, gitHubSvg)
import Element exposing (..)
import Element.Font as Font
import Base exposing (goldenRatio)
import Tuple exposing (first)
import Html.Attributes as Attrs
import Element.Background as Background
import Element.Border as Border
import IntragramEmbeddings exposing (..)

type alias Texts = List (String, String)


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

{--

TABS data 

--}

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
        , "igfilters"
        ]

textsTab3 : Texts
textsTab3 =
  [ 
      ("Tetris\n", "Implementation of\nTetris in Elm")
    , ("Elm Particles\n", "Implementations using\nElm particles library")
    , ("Minesweeper", "Full js implementation of\nclassic Minesweeper game")
    , ("Instagram\nfilters", "Filters created\nwith Spark AR Studio")
    ]


embeddedTab4 : Device -> List String
embeddedTab4 device =
        [ 
          instragramEmbeddedWrapper device instagramReelsEmbedSpringGirl
        , instragramEmbeddedWrapper device instagramReelsEmbedCarnivalRow
        , instragramEmbeddedWrapper device instagramReelsEmbedCouple
        ]

textsTab4 : Texts
textsTab4 =
  [ 
      ("Spring\nOutdoors", "Process video")
    , ("Cara\nDelevingne\nCarnival Row", "Process video")
    , ("Dancers\nCouple", "Process video")
    ]


-- TODO add code for normal desktp sizes
{--
Github svg 


--}


igSourceLabel : Html msg -> String -> Element msg
igSourceLabel icon label = 
    row [spaceEvenly ] 
        [
          el [transparent True] <| text " "
        , html icon
        , text label
        , el [transparent True] <| text " "
        ]

sourceLabel : Html msg -> String -> Element msg
sourceLabel icon label = 
    row [spaceEvenly ] 
        [
        el [transparent True] <| text " "
        , el [transparent True] <| text " "
        , el [transparent True] <| text " "
        , html icon
        , text label
        , el [transparent True] <| text " "
        , el [transparent True] <| text " "
        , el [transparent True] <| text " "
        ]

imageSlides : List String -> List ( String, Html Gallery.Msg )
imageSlides  images =
    List.map (\image -> (image, imageSlide [] image Image.Contain )) images


imageSlide : List (Html.Attribute msg) -> Image.Url -> Image.Size -> Html.Html msg
imageSlide attrs url size =

    Html.img
        ([ Attrs.src (url ++ "-or.jpg")
        , Attrs.style "object-fit" (toObjectFit size)
        , Attrs.class "elm-gallery-image"
        , Attrs.attribute "srcset" <| srcSet url
        , Attrs.attribute "sizes" <| "100vw"
        ]
            ++ attrs
        )
        [ ]


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

embeddedSlides :  List String ->  List ( String, Html Gallery.Msg )
embeddedSlides embeddings =
    List.indexedMap (\i embedded -> (String.fromInt i, embeddedSlide [] embedded )) embeddings


embeddedSlide : List (Html.Attribute msg) -> String -> Html.Html msg
embeddedSlide attrs embedded =
     Html.iframe
      [    Attrs.srcdoc embedded
        ,  Attrs.style "height" "100%"
        ,  Attrs.style "width" "100%"
        ,  Attrs.style "overflow" "hidden"
        ,  Attrs.style "scrolling" "no"
        ,  Attrs.style "frameborder" "0"
        ,  Attrs.style "border-width" "0"
        ]
      []
    

toObjectFit : Image.Size -> String
toObjectFit size =
    case size of
        Image.Cover ->
            "cover"

        Image.Contain ->
            "contain"

-- srcset="example-320.jpg 320w, example-640.avif 640w, example-1024.webp 1024w, 
-- example-1280.jpg 1280w, example-1920.avif 1920w, example-2560.webp 2560w">
srcSet : Image.Url -> String
srcSet image =
    List.map (\suffix -> image ++ suffix) (crossProduct ["or", "lg", "md"] ["avif", "webp", "jpg"])
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

linkToPage : Device -> List ( String, Html Gallery.Msg )
linkToPage  device = 
    let 
        conf = layoutConf device
        
        sourcelabel = sourceLabel (gitHubSvg conf.githubSize) "Source" 

        sourcelabelIG = igSourceLabel (instagramSvg conf.igSize) "Try on Instagram" 

        links = 
            [ ({ url = "/playground/tetris/tetris.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/tetris" , label = sourcelabel}, False)
            , ({ url = "/playground/particles/app.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/elmparticles", label = sourcelabel}, False)
            , ({ url = "/playground/buscaminas/buscaminas.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/buscaminas", label = sourcelabel}, False)
            , ({ url = "https://www.instagram.com/mikel_dalmau_art/", label = sourcelabelIG}, { url = "https://github.com/mikeldalmauc/buscaminas", label = none}, True)
            ]

        liveExampleAttrs = Base.secondaryFontAttrs ++ 
                        [ Font.size conf.liveExampleFontSize
                        , Font.color Base.lightOrange
                        , Font.center, centerY, centerX, pointer
                        , Font.underline
                        ]
        sourceAttrs = Base.secondaryFontAttrs ++ 
                        [ Font.size conf.sourceFontSize
                        , Font.color Base.ligthBlue
                        , Font.center, centerY, centerX, pointer
                        , Font.underline
                        ]
    in 
        List.indexedMap (\index (liveExample, sourceCode, invisible) ->
             (String.fromInt <| index+1,
                layoutWith {options = [noStaticStyleSheet]} [] <| column (Base.secondaryFontAttrs ++ [
                    centerY
                    , centerX
                    , moveRight conf.linksRightDisplacement
                    , Background.color Base.black08
                    , Border.color Base.gray80
                    , padding conf.linksPadding
                    , Border.rounded 10
                    , Border.solid
                    , Border.width 4
                    , Border.glow (rgba 1 1 1 0.5) 10.0
                    , htmlAttribute (Attrs.attribute "style" "z-index:20")
                    ]) 
                    <| [ paragraph liveExampleAttrs <| [ link [] liveExample ]
                        , el [transparent True] <| text " "
                        , paragraph sourceAttrs <| [ link [transparent invisible] sourceCode ]
                        ])
        ) links


