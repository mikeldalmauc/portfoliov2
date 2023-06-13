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
      ("Tetris\n", "Implementation of Tetris in Elm")
    , ("Elm Particles\n", "Implementations using\nElm particles library")
    , ("Minesweeper", "Full js implementation of\nclassic Minesweeper game")
    , ("Instagram\nfilters", "Filters created\nwith Spark AR Studio")
    ]


embeddedTab4 : List String
embeddedTab4 =
        [ 
          instagramReelsEmbedSpringGirl
        , instagramReelsEmbedCarnivalRow
        ]

textsTab4 : Texts
textsTab4 =
  [ 
      ("Spring\nOutdoors", "Process video")
    , ("Cara\nDelevingne\nCarnival Row", "Process video")
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
    -- let
    --     code = case Html.Parser.run embedded of
    --         Ok nodes ->
    --             Html.Parser.Util.toVirtualDom nodes

    --         Err _ ->
    --             []
    -- in 
    --     Html.div attrs code
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
        
        sourcelabel = sourceLabel gitHubSvg "Source" 

        sourcelabelIG = igSourceLabel instagramSvg "Try on Instagram" 

        links = 
            [ ({ url = "/playground/tetris/tetris.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/tetris" , label = sourcelabel}, False)
            , ({ url = "/playground/particles/app.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/elmparticles", label = sourcelabel}, False)
            , ({ url = "/playground/buscaminas/buscaminas.html", label = text "Live example"}, { url = "https://github.com/mikeldalmauc/buscaminas", label = sourcelabel}, False)
            , ({ url = "https://www.instagram.com/mikel_dalmau_art/", label = sourcelabelIG}, { url = "https://github.com/mikeldalmauc/buscaminas", label = none}, True)
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
        List.indexedMap (\index (liveExample, sourceCode, invisible) ->
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
                        , paragraph sourceAttrs <| [ link [transparent invisible] sourceCode ]
                        ])
        ) links

instagramReelsEmbedSpringGirl : String
instagramReelsEmbedSpringGirl =    
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
    </head>
    <body style=" display: flex; flex-direction: row; justify-content: flex-end; margin-right: 15%; frameborder:0; scrolling:no; overflow:hidden;">
    
    <blockquote class="instagram-media" data-instgrm-captioned
        data-instgrm-permalink="https://www.instagram.com/tv/CTExCHtFWsx/?utm_source=ig_embed&amp;utm_campaign=loading"
        data-instgrm-version="14"
        style=" background:#FFF; box-shadow:0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15); margin: 1px; max-width:540px; min-width:326px; padding:0; width:99.375%; width:-webkit-calc(100% - 2px); width:calc(100% - 2px);">
        <div style="padding:16px;"> <a
                href="https://www.instagram.com/tv/CTExCHtFWsx/?utm_source=ig_embed&amp;utm_campaign=loading"
                style=" background:#FFFFFF; line-height:0; padding:0 0; text-align:center; text-decoration:none; width:100%;"
                target="_blank">
                <div style=" display: flex; flex-direction: row; align-items: center;">
                    <div
                        style="background-color: #F4F4F4; border-radius: 50%; flex-grow: 0; height: 40px; margin-right: 14px; width: 40px;">
                    </div>
                    <div style="display: flex; flex-direction: column; flex-grow: 1; justify-content: center;">
                        <div
                            style=" background-color: #F4F4F4; border-radius: 4px; flex-grow: 0; height: 14px; margin-bottom: 6px; width: 100px;">
                        </div>
                        <div
                            style=" background-color: #F4F4F4; border-radius: 4px; flex-grow: 0; height: 14px; width: 60px;">
                        </div>
                    </div>
                </div>
                <div style="padding: 19% 0;"></div>
                <div style="display:block; height:50px; margin:0 auto 12px; width:50px;">
                    <svg width="50px" height="50px" viewBox="0 0 60 60" version="1.1" xmlns="https://www.w3.org/2000/svg"
                        xmlns:xlink="https://www.w3.org/1999/xlink">
                        <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                            <g transform="translate(-511.000000, -20.000000)" fill="#000000">
                                <g>
                                    <path
                                        d="M556.869,30.41 C554.814,30.41 553.148,32.076 553.148,34.131 C553.148,36.186 554.814,37.852 556.869,37.852 C558.924,37.852 560.59,36.186 560.59,34.131 C560.59,32.076 558.924,30.41 556.869,30.41 M541,60.657 C535.114,60.657 530.342,55.887 530.342,50 C530.342,44.114 535.114,39.342 541,39.342 C546.887,39.342 551.658,44.114 551.658,50 C551.658,55.887 546.887,60.657 541,60.657 M541,33.886 C532.1,33.886 524.886,41.1 524.886,50 C524.886,58.899 532.1,66.113 541,66.113 C549.9,66.113 557.115,58.899 557.115,50 C557.115,41.1 549.9,33.886 541,33.886 M565.378,62.101 C565.244,65.022 564.756,66.606 564.346,67.663 C563.803,69.06 563.154,70.057 562.106,71.106 C561.058,72.155 560.06,72.803 558.662,73.347 C557.607,73.757 556.021,74.244 553.102,74.378 C549.944,74.521 548.997,74.552 541,74.552 C533.003,74.552 532.056,74.521 528.898,74.378 C525.979,74.244 524.393,73.757 523.338,73.347 C521.94,72.803 520.942,72.155 519.894,71.106 C518.846,70.057 518.197,69.06 517.654,67.663 C517.244,66.606 516.755,65.022 516.623,62.101 C516.479,58.943 516.448,57.996 516.448,50 C516.448,42.003 516.479,41.056 516.623,37.899 C516.755,34.978 517.244,33.391 517.654,32.338 C518.197,30.938 518.846,29.942 519.894,28.894 C520.942,27.846 521.94,27.196 523.338,26.654 C524.393,26.244 525.979,25.756 528.898,25.623 C532.057,25.479 533.004,25.448 541,25.448 C548.997,25.448 549.943,25.479 553.102,25.623 C556.021,25.756 557.607,26.244 558.662,26.654 C560.06,27.196 561.058,27.846 562.106,28.894 C563.154,29.942 563.803,30.938 564.346,32.338 C564.756,33.391 565.244,34.978 565.378,37.899 C565.522,41.056 565.552,42.003 565.552,50 C565.552,57.996 565.522,58.943 565.378,62.101 M570.82,37.631 C570.674,34.438 570.167,32.258 569.425,30.349 C568.659,28.377 567.633,26.702 565.965,25.035 C564.297,23.368 562.623,22.342 560.652,21.575 C558.743,20.834 556.562,20.326 553.369,20.18 C550.169,20.033 549.148,20 541,20 C532.853,20 531.831,20.033 528.631,20.18 C525.438,20.326 523.257,20.834 521.349,21.575 C519.376,22.342 517.703,23.368 516.035,25.035 C514.368,26.702 513.342,28.377 512.574,30.349 C511.834,32.258 511.326,34.438 511.181,37.631 C511.035,40.831 511,41.851 511,50 C511,58.147 511.035,59.17 511.181,62.369 C511.326,65.562 511.834,67.743 512.574,69.651 C513.342,71.625 514.368,73.296 516.035,74.965 C517.703,76.634 519.376,77.658 521.349,78.425 C523.257,79.167 525.438,79.673 528.631,79.82 C531.831,79.965 532.853,80.001 541,80.001 C549.148,80.001 550.169,79.965 553.369,79.82 C556.562,79.673 558.743,79.167 560.652,78.425 C562.623,77.658 564.297,76.634 565.965,74.965 C567.633,73.296 568.659,71.625 569.425,69.651 C570.167,67.743 570.674,65.562 570.82,62.369 C570.966,59.17 571,58.147 571,50 C571,41.851 570.966,40.831 570.82,37.631">
                                    </path>
                                </g>
                            </g>
                        </g>
                    </svg>
                </div>
                <div style="padding-top: 8px;">
                    <div
                        style=" color:#3897f0; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:550; line-height:18px;">
                        Ver esta publicación en Instagram</div>
                </div>
                <div style="padding: 12.5% 0;"></div>
                <div style="display: flex; flex-direction: row; margin-bottom: 14px; align-items: center;">
                    <div>
                        <div
                            style="background-color: #F4F4F4; border-radius: 50%; height: 12.5px; width: 12.5px; transform: translateX(0px) translateY(7px);">
                        </div>
                        <div
                            style="background-color: #F4F4F4; height: 12.5px; transform: rotate(-45deg) translateX(3px) translateY(1px); width: 12.5px; flex-grow: 0; margin-right: 14px; margin-left: 2px;">
                        </div>
                        <div
                            style="background-color: #F4F4F4; border-radius: 50%; height: 12.5px; width: 12.5px; transform: translateX(9px) translateY(-18px);">
                        </div>
                    </div>
                    <div style="margin-left: 8px;">
                        <div
                            style=" background-color: #F4F4F4; border-radius: 50%; flex-grow: 0; height: 20px; width: 20px;">
                        </div>
                        <div
                            style=" width: 0; height: 0; border-bottom: 2px solid transparent; transform: translateX(16px) translateY(-4px) rotate(30deg)">
                        </div>
                    </div>
                    <div style="margin-left: auto;">
                        <div
                            style=" width: 0px;  transform: translateY(16px);">
                        </div>
                        <div
                            style=" background-color: #F4F4F4; flex-grow: 0; height: 12px; width: 16px; transform: translateY(-4px);">
                        </div>
                        <div
                            style=" width: 0; height: 0; transform: translateY(-4px) translateX(8px);">
                        </div>
                    </div>
                </div>
                <div
                    style="display: flex; flex-direction: column; flex-grow: 1; justify-content: center; margin-bottom: 24px;">
                    <div
                        style=" background-color: #F4F4F4; border-radius: 4px; flex-grow: 0; height: 14px; margin-bottom: 6px; width: 224px;">
                    </div>
                    <div style=" background-color: #F4F4F4; border-radius: 4px; flex-grow: 0; height: 14px; width: 144px;">
                    </div>
                </div>
            </a>
            <p
                style=" color:#c9c8cd; font-family:Arial,sans-serif; font-size:14px; line-height:17px; margin-bottom:0; margin-top:8px; overflow:hidden; padding:8px 0 7px; text-align:center; text-overflow:ellipsis; white-space:nowrap;">
                <a href="https://www.instagram.com/tv/CTExCHtFWsx/?utm_source=ig_embed&amp;utm_campaign=loading"
                    style=" color:#c9c8cd; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:normal; line-height:17px; text-decoration:none;"
                    target="_blank">Una publicación compartida de Mikel Dalmau (@mikel_dalmau_art)</a>
            </p>
        </div>
    </blockquote>
    <script async src="//www.instagram.com/embed.js"></script>
    </body>
    </html>
    """

instagramReelsEmbedCarnivalRow : String
instagramReelsEmbedCarnivalRow = 
    """
     <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
    </head>
    <body style=" display: flex; flex-direction: row; justify-content: flex-end; margin-right: 15%; frameborder:0; scrolling:no; overflow:hidden;">
    <blockquote class="instagram-media" data-instgrm-captioned
        data-instgrm-permalink="https://www.instagram.com/reel/CsOAri-omcH/?utm_source=ig_embed&amp;utm_campaign=loading"
        data-instgrm-version="14"
        style=" background:#FFF; border-radius:3px; box-shadow:0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15); margin: 1px; max-width:540px; min-width:326px; padding:0; width:99.375%; width:-webkit-calc(100% - 2px); width:calc(100% - 2px);">
        <div style="padding:16px;"> <a
                href="https://www.instagram.com/reel/CsOAri-omcH/?utm_source=ig_embed&amp;utm_campaign=loading"
                style=" background:#FFFFFF; line-height:0; padding:0 0; text-align:center; text-decoration:none; width:100%;"
                target="_blank">
                <div style=" display: flex; flex-direction: row; align-items: center;">
                    <div
                        style="background-color: #F4F4F4; border-radius: 50%; flex-grow: 0; height: 40px; margin-right: 14px; width: 40px;">
                    </div>
                    <div style="display: flex; flex-direction: column; flex-grow: 1; justify-content: center;">
                        <div
                            style=" background-color: #F4F4F4; border-radius: 4px; flex-grow: 0; height: 14px; margin-bottom: 6px; width: 100px;">
                        </div>
                        <div
                            style=" background-color: #F4F4F4; border-radius: 4px; flex-grow: 0; height: 14px; width: 60px;">
                        </div>
                    </div>
                </div>
                <div style="padding: 19% 0;"></div>
                <div style="display:block; height:50px; margin:0 auto 12px; width:50px;"><svg width="50px" height="50px"
                        viewBox="0 0 60 60" version="1.1" xmlns="https://www.w3.org/2000/svg"
                        xmlns:xlink="https://www.w3.org/1999/xlink">
                        <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                            <g transform="translate(-511.000000, -20.000000)" fill="#000000">
                                <g>
                                    <path
                                        d="M556.869,30.41 C554.814,30.41 553.148,32.076 553.148,34.131 C553.148,36.186 554.814,37.852 556.869,37.852 C558.924,37.852 560.59,36.186 560.59,34.131 C560.59,32.076 558.924,30.41 556.869,30.41 M541,60.657 C535.114,60.657 530.342,55.887 530.342,50 C530.342,44.114 535.114,39.342 541,39.342 C546.887,39.342 551.658,44.114 551.658,50 C551.658,55.887 546.887,60.657 541,60.657 M541,33.886 C532.1,33.886 524.886,41.1 524.886,50 C524.886,58.899 532.1,66.113 541,66.113 C549.9,66.113 557.115,58.899 557.115,50 C557.115,41.1 549.9,33.886 541,33.886 M565.378,62.101 C565.244,65.022 564.756,66.606 564.346,67.663 C563.803,69.06 563.154,70.057 562.106,71.106 C561.058,72.155 560.06,72.803 558.662,73.347 C557.607,73.757 556.021,74.244 553.102,74.378 C549.944,74.521 548.997,74.552 541,74.552 C533.003,74.552 532.056,74.521 528.898,74.378 C525.979,74.244 524.393,73.757 523.338,73.347 C521.94,72.803 520.942,72.155 519.894,71.106 C518.846,70.057 518.197,69.06 517.654,67.663 C517.244,66.606 516.755,65.022 516.623,62.101 C516.479,58.943 516.448,57.996 516.448,50 C516.448,42.003 516.479,41.056 516.623,37.899 C516.755,34.978 517.244,33.391 517.654,32.338 C518.197,30.938 518.846,29.942 519.894,28.894 C520.942,27.846 521.94,27.196 523.338,26.654 C524.393,26.244 525.979,25.756 528.898,25.623 C532.057,25.479 533.004,25.448 541,25.448 C548.997,25.448 549.943,25.479 553.102,25.623 C556.021,25.756 557.607,26.244 558.662,26.654 C560.06,27.196 561.058,27.846 562.106,28.894 C563.154,29.942 563.803,30.938 564.346,32.338 C564.756,33.391 565.244,34.978 565.378,37.899 C565.522,41.056 565.552,42.003 565.552,50 C565.552,57.996 565.522,58.943 565.378,62.101 M570.82,37.631 C570.674,34.438 570.167,32.258 569.425,30.349 C568.659,28.377 567.633,26.702 565.965,25.035 C564.297,23.368 562.623,22.342 560.652,21.575 C558.743,20.834 556.562,20.326 553.369,20.18 C550.169,20.033 549.148,20 541,20 C532.853,20 531.831,20.033 528.631,20.18 C525.438,20.326 523.257,20.834 521.349,21.575 C519.376,22.342 517.703,23.368 516.035,25.035 C514.368,26.702 513.342,28.377 512.574,30.349 C511.834,32.258 511.326,34.438 511.181,37.631 C511.035,40.831 511,41.851 511,50 C511,58.147 511.035,59.17 511.181,62.369 C511.326,65.562 511.834,67.743 512.574,69.651 C513.342,71.625 514.368,73.296 516.035,74.965 C517.703,76.634 519.376,77.658 521.349,78.425 C523.257,79.167 525.438,79.673 528.631,79.82 C531.831,79.965 532.853,80.001 541,80.001 C549.148,80.001 550.169,79.965 553.369,79.82 C556.562,79.673 558.743,79.167 560.652,78.425 C562.623,77.658 564.297,76.634 565.965,74.965 C567.633,73.296 568.659,71.625 569.425,69.651 C570.167,67.743 570.674,65.562 570.82,62.369 C570.966,59.17 571,58.147 571,50 C571,41.851 570.966,40.831 570.82,37.631">
                                    </path>
                                </g>
                            </g>
                        </g>
                    </svg></div>
                <div style="padding-top: 8px;">
                    <div
                        style=" color:#3897f0; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:550; line-height:18px;">
                        Ver esta publicación en Instagram</div>
                </div>
                <div style="padding: 12.5% 0;"></div>
                <div style="display: flex; flex-direction: row; margin-bottom: 14px; align-items: center;">
                    <div>
                        <div
                            style="background-color: #F4F4F4; border-radius: 50%; height: 12.5px; width: 12.5px; transform: translateX(0px) translateY(7px);">
                        </div>
                        <div
                            style="background-color: #F4F4F4; height: 12.5px; transform: rotate(-45deg) translateX(3px) translateY(1px); width: 12.5px; flex-grow: 0; margin-right: 14px; margin-left: 2px;">
                        </div>
                        <div
                            style="background-color: #F4F4F4; border-radius: 50%; height: 12.5px; width: 12.5px; transform: translateX(9px) translateY(-18px);">
                        </div>
                    </div>
                    <div style="margin-left: 8px;">
                        <div
                            style=" background-color: #F4F4F4; border-radius: 50%; flex-grow: 0; height: 20px; width: 20px;">
                        </div>
                        <div
                            style=" width: 0; height: 0;   transform: translateX(16px) translateY(-4px) rotate(30deg)">
                        </div>
                    </div>
                    <div style="margin-left: auto;">
                        <div
                            style=" width: 0px; transform: translateY(16px);">
                        </div>
                        <div
                            style=" background-color: #F4F4F4; flex-grow: 0; height: 12px; width: 16px; transform: translateY(-4px);">
                        </div>
                        <div
                            style=" width: 0; height: 0; transform: translateY(-4px) translateX(8px);">
                        </div>
                    </div>
                </div>
                <div
                    style="display: flex; flex-direction: column; flex-grow: 1; justify-content: center; margin-bottom: 24px;">
                    <div
                        style=" background-color: #F4F4F4; border-radius: 4px; flex-grow: 0; height: 14px; margin-bottom: 6px; width: 224px;">
                    </div>
                    <div style=" background-color: #F4F4F4; border-radius: 4px; flex-grow: 0; height: 14px; width: 144px;">
                    </div>
                </div>
            </a>
            <p
                style=" color:#c9c8cd; font-family:Arial,sans-serif; font-size:14px; line-height:17px; margin-bottom:0; margin-top:8px; overflow:hidden; padding:8px 0 7px; text-align:center; text-overflow:ellipsis; white-space:nowrap;">
                <a href="https://www.instagram.com/reel/CsOAri-omcH/?utm_source=ig_embed&amp;utm_campaign=loading"
                    style=" color:#c9c8cd; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:normal; line-height:17px; text-decoration:none;"
                    target="_blank">Una publicación compartida de Mikel Dalmau (@mikel_dalmau_art)</a></p>
        </div>
    </blockquote>
    <script async src="//www.instagram.com/embed.js"></script>
    </body>
    </html>
    """