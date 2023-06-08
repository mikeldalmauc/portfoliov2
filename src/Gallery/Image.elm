module Gallery.Image exposing
    ( slide
    , Size(..)
    , Url
    )

{-|


# Image slide

@docs slide


## Definitions

@docs Size
@docs Url

-}

import Html exposing (..)
import Html.Attributes exposing (..)


{-| How the image is displayed within it's container, same as CSS background-size
-}
type Size
    = Cover
    | Contain


{-| Image url
-}
type alias Url =
    String


{-| Create an image slide that either fits or covers the gallery container
-}
slide : List (Html.Attribute msg) -> Url -> Size -> Html msg
slide attrs url size =
    img
        ([ src ("url(" ++ url ++ ")")
         , style "object-fit" (toObjectFit size)
         , class "elm-gallery-image"
         ]
            ++ attrs
        )
        []


toObjectFit : Size -> String
toObjectFit size =
    case size of
        Cover ->
            "cover"

        Contain ->
            "contain"
