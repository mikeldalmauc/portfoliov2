module Gallery exposing 
    ( view
    , viewText
    , viewClickable
    , Config
    , config
    , Length
    , px
    , pct
    , rem
    , em
    , vw
    , vh
    , init
    , update
    , State
    , Msg
    , SlideCount
    , Controls(..)
    , index
    , next
    , previous
    , current, viewTextSlides
    )

{-|


# View

@docs view


# Configuration

@docs Config
@docs config


## Dimensions

@docs Length
@docs px
@docs pct
@docs rem
@docs em
@docs vw
@docs vh


# State

@docs init
@docs update


## Definitions

@docs State
@docs Msg
@docs SlideCount


# Controls

@docs Controls


# Navigation

@docs index
@docs next
@docs previous
@docs current

-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy as Lazy
import Json.Decode as Decode



-- STATE


{-| Tracks index, mouse and touch movements
-}
type State
    = State Index (Maybe Drag) SlideCount


type Drag
    = Drag Position Position


{-| Total number of slides
-}
type alias SlideCount =
    Int


type alias Index =
    Int


type alias Position =
    { x : Int
    , y : Int
    }


{-| Initialize a gallery state

    { gallery = Gallery.init (List.length someSlides) }

-}
init : SlideCount -> State
init slideCount =
    State 0 Nothing slideCount



-- CONFIG


{-| -}
type Config
    = Config
        { id : String
        , transition : Int
        , width : Length
        , height : Length
        }


{-|

     Gallery.config
        { id = "image-gallery"
        , transition = 500 -- time in milliseconds
        , width = Gallery.px 800
        , height = Gallery.px 400
        }

-}
config :
    { id : String
    , transition : Int
    , width : Length
    , height : Length
    }
    -> Config
config { id, transition, width, height } =
    Config
        { id = id
        , transition = transition
        , width = width
        , height = height
        }



-- UPDATE


{-| A message type for the gallery to update.
-}
type Msg
    = Next
    | Previous
    | DragStart Position
    | DragAt Position
    | DragEnd


{-|

    type Msg
        = GalleryMsg Gallery.Msg

    update : Msg -> Model -> Model
    update msg model =
        case msg of
            GalleryMsg msg ->
                { model | gallery = Gallery.update msg model.gallery }

-}
update : Msg -> State -> State
update msg ((State index_ drag slideCount) as state) =
    case msg of
        Next ->
            if index_ == slideCount - 1 then
                index 0 state
            else
                next state

        Previous ->
            previous state

        DragStart position ->
            State index_ (Just (Drag position position)) slideCount

        DragAt position ->
            let
                updateDrag current_ (Drag start _) =
                    Drag start current_
            in
            State index_ (Maybe.map (updateDrag position) drag) slideCount

        DragEnd ->
            case drag of
                Just (Drag start current_) ->
                    if start.x - current_.x > 100 then
                        next state

                    else if start.x - current_.x < -100 then
                        previous state

                    else
                        State index_ Nothing slideCount

                Nothing ->
                    state



-- CONTROL


{-| Go to next slide

    { model | gallery = Gallery.next model.gallery }

-}
next : State -> State
next (State index_ _ slideCount) =
    State (clamp 0 (slideCount - 1) (index_ + 1)) Nothing slideCount


{-| Go to previous slide

    { model | gallery = Gallery.previous model.gallery }

-}
previous : State -> State
previous (State index_ _ slideCount) =
    State (clamp 0 (slideCount - 1) (index_ - 1)) Nothing slideCount


{-| Go to slide at index

    { model | gallery = Gallery.index 10 model.gallery }

-}
index : Int -> State -> State
index index_ (State _ _ slideCount) =
    State (clamp 0 (slideCount - 1) index_) Nothing slideCount


{-| Get current index
-}
current : State -> Int
current (State index_ _ _) =
    index_



-- VIEW


{-|

    Gallery.view config model.gallery [] slides

-}
view : Config -> State -> List Controls -> List ( String, Html Msg ) -> Html Msg
view ((Config configR) as config_) ((State _ drag _) as state) navigation slides =
    div [ id configR.id ] <|
        [ Lazy.lazy2 viewSlides state slides
        , Lazy.lazy2 styleSheet config_ drag
        ]
            ++ List.map (viewControls state) navigation

viewText : Config -> State -> List Controls -> List ( String, Html Msg ) -> Html Msg
viewText ((Config configR) as config_) ((State _ drag _) as state) navigation slides =
    div [ id configR.id ] <|
        [ Lazy.lazy2 viewTextSlides state slides
        , Lazy.lazy2 styleSheet config_ drag
        ]
            ++ List.map (viewControls state) navigation
viewClickable : Config -> State -> List Controls -> List ( String, Html Msg ) -> Html Msg
viewClickable ((Config configR) as config_) ((State _ drag _) as state) navigation slides =
    div [ id configR.id ] <|
        [ Lazy.lazy2 viewClickableSlides state slides
        , Lazy.lazy2 styleSheet config_ drag
        ]
            ++ List.map (viewControls state) navigation

viewTextSlides : State -> List ( String, Html Msg ) -> Html Msg
viewTextSlides ((State index_ _ _) as state) slides =
    Keyed.ul (viewSlidesAttributes state) <|
        List.indexedMap (viewTextSlide index_) slides


viewClickableSlides : State -> List ( String, Html Msg ) -> Html Msg
viewClickableSlides ((State index_ _ _) as state) slides =
    Keyed.ul (viewSlidesAttributes state) <|
        List.indexedMap (viewClickableSlide index_) slides

-- SLIDES


viewSlides : State -> List ( String, Html Msg ) -> Html Msg
viewSlides ((State index_ _ _) as state) slides =
    Keyed.ul (viewSlidesAttributes state) <|
        List.indexedMap (viewSlide index_) slides


viewSlidesAttributes : State -> List (Attribute Msg)
viewSlidesAttributes ((State _ drag slideCount) as state) =
    events drag
        ++ [ classList
                [ ( "elm-gallery-transition", drag == Nothing ) ]
           , style "transform" (toTranslate state)
           , style "width" (String.fromInt (100 * slideCount) ++ "%")
           , id "elm-gallery-focusable"
           , tabindex 0
           ]


toTranslate : State -> String
toTranslate (State index_ drag slideCount) =
    case drag of
        Nothing ->
            toCssTranslate slideCount index_ 0 0

        Just (Drag start current_) ->
            toCssTranslate slideCount index_ (current_.x - start.x) 0



-- ITEMS


viewSlide : Index -> Index -> ( String, Html Msg ) -> ( String, Html Msg )
viewSlide currentIndex slideIndex ( id, html ) =
    ( id
    , div
        [ classList
            [ ( "elm-gallery-itemcontainer", True )
            , ( "elm-gallery-current", currentIndex == slideIndex )
            ]
        ]
        [ html ]
    )

viewTextSlide : Index -> Index -> ( String, Html Msg ) -> ( String, Html Msg )
viewTextSlide currentIndex slideIndex ( id, html ) =
    ( id
    , div
        [ classList
            [ ( "elm-gallery-text-itemcontainer", True )
            , ( "elm-gallery-current", currentIndex == slideIndex )
            ]
        ]
        [ html ]
    )

viewClickableSlide : Index -> Index -> ( String, Html Msg ) -> ( String, Html Msg )
viewClickableSlide currentIndex slideIndex ( id, html ) =
    ( id
    , div
        [ classList
            [ ( "elm-gallery-itemcontainer-clickable", True )
            , ( "elm-gallery-current", currentIndex == slideIndex )
            ]
        ]
        [ html ]
    )


-- NAVIGATION


{-| -}
type Controls
    = Arrows


viewControls : State -> Controls -> Html Msg
viewControls state navigation =
    case navigation of
        Arrows ->
            viewControlsArrows state


viewControlsArrows : State -> Html Msg
viewControlsArrows (State index_ _ slideCount) =
    div
        []
        [ button
            [ onClick Next
            , class "elm-gallery-next"
            , title "next"
            ]
            []
        , button
            [ onClick Previous
            , class "elm-gallery-previous"
            , title "previous"
            , disabled (index_ == 0)
            ]
            []
        ]



-- EVENTS


events : Maybe Drag -> List (Attribute Msg)
events drag =
    moveEvent drag
        ++ [ on "mousedown" (Decode.map DragStart decodePosition)
           , on "touchstart" (Decode.map DragStart decodePosition)
           , on "keydown" (Decode.andThen keycodeToMsg decodeKeyboard)
           ]


moveEvent : Maybe a -> List (Attribute Msg)
moveEvent drag =
    case drag of
        Just _ ->
            [ preventDefaultOn "mousemove"
                (Decode.map (\p -> ( DragAt p, True )) decodePosition)
            , preventDefaultOn "touchmove"
                (Decode.map (\p -> ( DragAt p, True )) decodePosition)
            , on "mouseup" (Decode.succeed DragEnd)
            , on "mouseleave" (Decode.succeed DragEnd)
            , on "touchend" (Decode.succeed DragEnd)
            , on "touchcancel" (Decode.succeed DragEnd)
            ]

        Nothing ->
            []


decodeKeyboard : Decode.Decoder Int
decodeKeyboard =
    Decode.field "keyCode" Decode.int


decodePosition : Decode.Decoder Position
decodePosition =
    let
        decoder =
            Decode.map2 Position
                (Decode.field "pageX" (Decode.map floor Decode.float))
                (Decode.field "pageY" (Decode.map floor Decode.float))
    in
    Decode.oneOf [ decoder, Decode.at [ "touches", "0" ] decoder ]


keycodeToMsg : Int -> Decode.Decoder Msg
keycodeToMsg keyCode =
    case keyCode of
        37 ->
            Decode.succeed Previous

        39 ->
            Decode.succeed Next

        _ ->
            Decode.fail "Unknown key"



-- CSS


{-| -}
type Length
    = Px Float
    | Pct Float
    | Rem Float
    | Em Float
    | Vh Float
    | Vw Float
    | Unset


{-| -}
unset : Length
unset =
    Unset


{-| -}
px : Float -> Length
px x =
    Px x


{-| -}
pct : Float -> Length
pct x =
    Pct x


{-| -}
rem : Float -> Length
rem x =
    Rem x


{-| -}
em : Float -> Length
em x =
    Em x


{-| -}
vh : Float -> Length
vh x =
    Vh x


{-| -}
vw : Float -> Length
vw x =
    Vw x


lengthToString : Length -> String
lengthToString length =
    case length of
        Px x ->
            String.fromFloat x ++ "px"

        Pct x ->
            String.fromFloat x ++ "%"

        Rem x ->
            String.fromFloat x ++ "rem"

        Em x ->
            String.fromFloat x ++ "em"

        Vh x ->
            String.fromFloat x ++ "vh"

        Vw x ->
            String.fromFloat x ++ "vw"

        Unset ->
            ""


toCssTranslate : SlideCount -> Int -> Int -> Int -> String
toCssTranslate slideCount index_ x y =
    "translate3d("
        ++ String.fromFloat (negate <| toFloat index_ * (100 / toFloat slideCount))
        ++ "%, "
        ++ String.fromInt y
        ++ "px, 0) "
        ++ "translateX("
        ++ String.fromInt x
        ++ "px)"


styleSheet : Config -> Maybe Drag -> Html msg
styleSheet (Config config_) drag =
    node "style"
        []
        [ text <|
            """
            #"""
                ++ config_.id
                ++ """ {
                position: relative;
                width: """
                ++ lengthToString config_.width
                ++ """;
                height:
                    """
                ++ lengthToString config_.height
                ++ """;
                overflow: hidden;
            }

            #"""
                ++ config_.id
                ++ """ ul {
                position: absolute;
                display: flex;
                height: 100%;
                left: 0;
                top: 0;
                padding: 0;
                margin: 0;
                z-index: 1;
                outline: none;
            }

            #"""
                ++ config_.id
                ++ """ ul:hover {
                cursor: move;
                cursor: grab;
                cursor: -moz-grab;
                cursor: -webkit-grab;
            }

            #"""
                ++ config_.id
                ++ """ ul:active {
                cursor: grabbing;
                cursor: -moz-grabbing;
                cursor: -webkit-grabbing;
            }

            #"""
                ++ config_.id
                ++ """ button {
                background-color: transparent;
                opacity: .0;
                border-radius: 0;
                border: 0;
                cursor: pointer;
                z-index: 2;
                transform: translate3d(0, 0, 0);
                width: 18rem;
            }

            #"""
                ++ config_.id
                ++ """ button:hover {
                opacity: .0;
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-previous,
            #"""
                ++ config_.id
                ++ """ .elm-gallery-next {
                position: absolute;
                width: 8rem;
                height: 100%;
                
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-next:hover {
               
                opacity: .6;
                background-color: rgba(100, 100, 100, .2);
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-previous:hover {
               
                opacity: .6;
                background-color: rgba(100, 100, 100, .2);
            }


            #"""
                ++ config_.id
                ++ """ .elm-gallery-next {
                right: 0rem;
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-previous {
                left: 0rem;
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-previous:disabled,
            #"""
                ++ config_.id
                ++ """ .elm-gallery-next:disabled {
                opacity: 0;
                cursor: not-allowed;
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-itemcontainer {
                position: relative;
                width: 100%;
                height: 100%;
                pointer-events: none;
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-itemcontainer-clickable {
                position: relative;
                width: 100%;
                height: 100%;
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-text-itemcontainer {
                position: relative;
                display: flex;
                align-items: center;
                width: 100%;
                height: 100%;
                pointer-events: none;
            }

            #"""
                ++ config_.id
                ++ """ .elm-gallery-image {
                position: absolute;
                width: 100%;
                height: 100%;
            }


            #"""
                ++ config_.id
                ++ """ .elm-gallery-transition {
                transition: transform """
                ++ String.fromInt config_.transition
                ++ """ms ease;
            }
            """
        ]
