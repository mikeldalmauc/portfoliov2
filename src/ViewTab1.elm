module ViewTab1 exposing (..)

import Gallery
import Gallery.Image as Image
import Html exposing (Html)
import Base exposing (slideCustom)
import Element exposing (..)

imageConfig : Float -> Float -> Gallery.Config
imageConfig w h =
    Gallery.config
        { id = "image-gallery-tab1"
        , transition = 400
        , width = Gallery.px w 
        , height = Gallery.px h
        }

imageSlides : List ( String, Html Gallery.Msg )
imageSlides =
    List.map (\x -> ( x, slideCustom [] x Image.Contain )) images

images : List String
images =
    List.map (\x -> "assets/tab1/" ++ x)
        [ 
          "portrait-21-md.jpg"
        , "3-black-woman-md.jpg"
        , "portrait-12-md.jpg"
        , "portrait-13-md.jpg"
        , "portrait-14-md.jpg"
        , "portrait-19-md.jpg"
        , "portrait-20-md.jpg"
        , "velazquez-9-md.jpg"
        , "wall-afternoon-md.jpg"
        ]

styling : Html msg
styling =
    Html.node "style"
        []
        [ Html.text
            """
                main {
                    font-family: Helvetica, arial, sans-serif;
                }

                a {
                    color: white;
                }

                #image-gallery {
                    margin: 5rem auto;
                }

                #text-gallery {
                    margin: 5rem auto;
                    background-color: #eee;
                }

                article {
                    padding: 2rem;
                }

                h4 {
                    color: grey;
                    margin: 1rem 0 0;
                    font-weight: 500;
                }
            """
        ]

textConfig : Gallery.Config
textConfig =
    Gallery.config
        { id = "text-gallery"
        , transition = 500
        , width = Gallery.px 600
        , height = Gallery.px 400
        }

textSlides : List ( String, Html Gallery.Msg )
textSlides =
    List.map (\x -> ( x, textSlide x )) texts


textSlide : String -> Html Gallery.Msg
textSlide slide =
    Html.article [] [ Html.h3 [] [ Html.text "Title" ], Html.p [] [ Html.text slide ] ]
    
texts : List String
texts =
    [ """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et quam nec eros pellentesque ultrices at et mauris. Sed sed ultricies lacus. Vestibulum porta elit et odio bibendum tempor. Nullam scelerisque quam felis, vitae pulvinar tortor scelerisque at. Mauris efficitur sagittis elit, pretium dapibus justo volutpat ac. Phasellus maximus lorem sit amet felis vestibulum accumsan. Mauris porta commodo massa placerat facilisis. Nunc et metus felis. Nulla scelerisque pretium elementum. Mauris pharetra eleifend erat et fermentum. Nulla eget sem consectetur, posuere felis sagittis, dictum metus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc feugiat et lorem feugiat gravida. Morbi elementum, eros at imperdiet eleifend, enim leo vestibulum nisi, et convallis lectus leo eu ipsum. Nam faucibus est sit amet accumsan luctus."""
    , """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et quam nec eros pellentesque ultrices at et mauris. Sed sed ultricies lacus. Vestibulum porta elit et odio bibendum tempor. Nullam scelerisque quam felis, vitae pulvinar tortor scelerisque at. Mauris efficitur sagittis elit, pretium dapibus justo volutpat ac. Phasellus maximus lorem sit amet felis vestibulum accumsan. Mauris porta commodo massa placerat facilisis. Nunc et metus felis. Nulla scelerisque pretium elementum. Mauris pharetra eleifend erat et fermentum. Nulla eget sem consectetur, posuere felis sagittis, dictum metus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc feugiat et lorem feugiat gravida. Morbi elementum, eros at imperdiet eleifend, enim leo vestibulum nisi, et convallis lectus leo eu ipsum. Nam faucibus est sit amet accumsan luctus."""
    , """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et quam nec eros pellentesque ultrices at et mauris. Sed sed ultricies lacus. Vestibulum porta elit et odio bibendum tempor. Nullam scelerisque quam felis, vitae pulvinar tortor scelerisque at. Mauris efficitur sagittis elit, pretium dapibus justo volutpat ac. Phasellus maximus lorem sit amet felis vestibulum accumsan. Mauris porta commodo massa placerat facilisis. Nunc et metus felis. Nulla scelerisque pretium elementum. Mauris pharetra eleifend erat et fermentum. Nulla eget sem consectetur, posuere felis sagittis, dictum metus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc feugiat et lorem feugiat gravida. Morbi elementum, eros at imperdiet eleifend, enim leo vestibulum nisi, et convallis lectus leo eu ipsum. Nam faucibus est sit amet accumsan luctus."""
    ]
