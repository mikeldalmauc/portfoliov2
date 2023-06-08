module ViewTab1 exposing (..)

import Gallery
import Gallery.Image as Image
import Html exposing (Html)
import Base exposing (slideCustom)
import Element exposing (..)
import Base exposing (goldenRatio)
import Tuple exposing (first)
import Html.Attributes as Attrs



imageSlides : List ( String, Html Gallery.Msg )
imageSlides =
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

imageConfig : Float -> Float -> Gallery.Config
imageConfig w h =
    Gallery.config
        { id = "image-gallery-tab1"
        , transition = 400
        , width = Gallery.px w 
        , height = Gallery.px h
        }

textConfig :  Float -> Float -> Gallery.Config
textConfig w h =
    Gallery.config
        { id = "text-gallery"
        , transition = 400
         , width = Gallery.px w 
        , height = Gallery.px h
        }

textSlides : List ( String, Html Gallery.Msg )
textSlides =
    List.map (\pair -> ( first pair, textSlide pair)) texts


textSlide : (String, String) -> Html Gallery.Msg
textSlide (title, subtitle) =
    Html.article [] [ Html.h3 [Attrs.attribute "style" "margin-bottom: 10px;"] [ Html.text title]
        , Html.p 
            [ Attrs.attribute "style" "font-size:40px; letter-spacing: 1.2px; font-family: 'Montserrat', sans-serif;word-spacing: 1.2px; font-variant: normal;"
            ] [ Html.text subtitle ] ]

images : List String
images =
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
        ]

texts : List (String, String)
texts =
    [ 
      ("Malenia,\nBlade of\nMiquella", "Fanart from Dark Souls")
    , ("3-black-woman", "")
    , ("portrait-12", "")
    , ("portrait-13", "")
    , ("portrait-14", "")
    , ("fallen-angel", "")
    , ("lazo", "")
    , ("velazquez-9", "")
    , ("afternoon-wall", "")
    ]
