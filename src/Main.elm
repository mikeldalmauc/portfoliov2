port module Main exposing (..)

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Browser.Events exposing (onResize)
import Element.Input as Input
import Element.Background as Background
import Html exposing (Html)
import Browser
import Browser.Events exposing (onKeyDown)
import Json.Decode as Decode exposing (Decoder, Value)
import String exposing (fromFloat)
import String exposing (fromInt)
import List exposing (take, head, drop, length)
import Base exposing (..)
import Element.Events exposing (onClick)
import Swipe
import Html.Attributes exposing (align)
import String exposing (right)
import Gallery
import Gallery.Image as Image
import Platform.Cmd as Cmd
import ViewTab1

type alias Model =

    { tab : Int
    , tabState : TabState
    , device : Device
    , wheelModel : WheelModel
    , galleryTab1 : Gallery.State
    , gesture : Swipe.Gesture
    }

type alias WheelModel =
    { deltaX : Float
    , deltaY : Float
    }

type alias Flags =
    { width : Int
    , height : Int
    }

type TabState
    = Loading
    | Loaded

type Msg =
      Wheel WheelModel
    | Swipe Swipe.Event
    | SwipeEnd Swipe.Event
    | UserMovedSlider Int
    | DeviceClassified Device
    | GalleryMsg Gallery.Msg
    | Head
    | NoOp

init : Flags -> ( Model, Cmd Msg )
init flags =
    ({    tab = 0
        , tabState = Loaded
        , device = Element.classifyDevice flags
        , wheelModel = initWheelModel
        , gesture = Swipe.blanco
        , galleryTab1 = Gallery.init (List.length ViewTab1.images)
    }
    , Cmd.none
    )

initWheelModel : WheelModel
initWheelModel = 
    { deltaX = 0, deltaY = 0 }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        Wheel wheelModel ->
            case model.tabState of
                Loading -> 
                    ( model, Cmd.none )
                Loaded -> 
                    if  wheelModel.deltaY < 0.0 then                       
                        ( {model | tab = previousTab model.tab, wheelModel = initWheelModel} , Cmd.none )
                    else
                        ( {model | tab = nextTab model.tab, wheelModel = initWheelModel} , Cmd.none )
        
        
        Swipe touch ->
            ({ model | gesture = Swipe.record touch model.gesture }, Cmd.none)
                    
        SwipeEnd touch ->
            let
                gesture = Swipe.record touch model.gesture
                newTab = 
                    if (Swipe.isUpSwipe 150.0 gesture) then
                        nextTab model.tab
                    else if (Swipe.isDownSwipe 150.0 gesture) then
                        previousTab model.tab
                    else
                        model.tab
            in
                ({ model | gesture = Swipe.blanco, tab = newTab}, Cmd.none)

        UserMovedSlider v ->
            ({ model | tab = (v // 10) }, Cmd.none)

        DeviceClassified device ->
            ( { model | device = device } , Cmd.none)

        GalleryMsg galleryMsg ->
            ({ model | galleryTab1 = Gallery.update galleryMsg model.galleryTab1 }, Cmd.none)
            
        Head -> 
            ( {model | tab = 0} , Cmd.none )
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        name = el (brandFontAttrs ++ [ width fill, height <| fillPortion 1, centerX, Font.color <| gray50, mouseOver [Font.color <| highlight]  ]) 
            <| paragraph [ Font.center, centerY, Font.size 20, padding 40, onClick Head, pointer] [ text "Mikel Dalmau" ]

        attrs = (secondaryFontAttrs ++ [width (fillPortion 2), height fill, Font.size 12, Font.color <| gray80, mouseOver [Font.color <| highlight]])
        menuL = el (attrs ++ [alignLeft]) <| paragraph [Font.center, centerY, rotate <| degrees -90, onClick Head, pointer] <| [ text "About"]
        menuR = el (attrs ++ [alignRight]) <| paragraph [Font.center, centerY, rotate <| degrees -90, pointer] <| [
            link []
                { url = partnerMailto
                , label = text "mikeldalmauc@gmail.com"}
            ]
        slider = if model.tab > 0 then 
                    el [width <| fillPortion 3, height fill, onRight <| tabsSlider model.tab ] none
                else
                    el [width <| fillPortion 3, height fill] none
    in
        Html.div 
            [ Swipe.onStart Swipe
            , Swipe.onMove Swipe
            , Swipe.onEndWithOptions 
                { stopPropagation = True
                , preventDefault = False
                } 
                SwipeEnd
            ]
            [ layout
                [ width fill, height fill, Background.color black08
                    , behindContent <| infoDebug model -- TODO hide maybe
                ] 
                <|  column
                    [ height fill, width fill]
                    [ name
                    , row
                        [ height <| fillPortion 18, width fill, spaceEvenly]
                        [  menuL
                        , el [width <| fillPortion 3, height fill] none
                        , viewTab model
                        , slider
                        , menuR]
                    , el [height <| fillPortion 1] none
                    ]
            ]

infoDebug : Model -> Element msg
infoDebug model =
    column 
        [ width fill, height fill, Font.size 11, padding 10, Font.color <| rgb 255 255 255]
        [ text <| "wheel Delta Y: " ++ fromFloat model.wheelModel.deltaY
        , text <| "wheel Delta X: " ++ fromFloat model.wheelModel.deltaX
        , text <| "tab: " ++ fromInt model.tab
        , text <| "device: " ++ Debug.toString model.device
        , text <| "galleryTab1: " ++ Debug.toString model.galleryTab1
        , text <| "gesture: " ++ Debug.toString model.gesture
        ]


tabs : List (Model -> Element Msg )
tabs = 
    [viewTab0, viewTab1, viewTab2, viewTab3, viewTab4, viewTab5, viewTab6, viewTab7]
    
viewTab : Model -> Element Msg
viewTab model =
    case (head <| drop model.tab tabs ) of
        Just tab ->
            el [width (fillPortion 12), height (fillPortion 1)] <| tab model
        Nothing ->
            el [width (fillPortion 12), height (fillPortion 1)] <| viewTab1 model

nextTab : Int -> Int
nextTab actual  =   
    if actual == (List.length tabs) - 1 then
        actual
    else
        actual + 1

previousTab : Int -> Int
previousTab actual  =   
    if actual == 0  then
        actual
    else
        actual - 1
        
tabsSlider : Int -> Element Msg
tabsSlider actual = 
    Input.slider
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
                , Background.color <| gray50
                , Border.rounded 6
                ]
                Element.none
        ]
        { onChange = UserMovedSlider << round
        , label = Input.labelHidden ("Integer value: " ++ String.fromInt (actual*10))
        , min = 10 * (toFloat (List.length tabs) - 1)
        , max = 10
        , step = Just 10
        , value = toFloat actual*10
        , thumb = Input.defaultThumb
        }
    
            

viewTab0 : Model -> Element Msg 
viewTab0 model = 
    let
        arrow = 
            el [height fill, centerX, padding 45]
            <| image [width <| px 17
                , height <| px 60 
                , alignBottom
                , onClick <| Wheel { deltaX = 0, deltaY = 150.0 }
                , pointer
                ] {src="assets/downarrow.png", description="arrow pointing down"}  
    in
        el [ centerX, height fill, centerY, inFront arrow] 
            <|
                column
                [centerY, width fill, Font.color <| rgb 255 255 255, spacing 10]
                [ paragraph
                        (brandFontAttrs ++ [Font.size 60, Font.center ])
                        [ text "Mikel Dalmau" ]
                , paragraph
                        (baseFontAttrs ++ [Font.size 22, Font.center])
                        [ text "Image engineer"]
                ]



viewTab1 : Model -> Element Msg
viewTab1 model = 
    el [ centerX, centerY] 
        <|
            column
            [ width fill, height fill, Font.color <| rgb 255 255 255]
            [
                
                html <| Html.div [] <| [ViewTab1.styling] ++ [Html.map GalleryMsg <|
                    Gallery.view ViewTab1.imageConfig model.galleryTab1 [ Gallery.Arrows  ] ViewTab1.imageSlides]
                    
            ]


viewTab2 : Model -> Element Msg
viewTab2 model = 
    el [ centerX, centerY] 
        <|
            column
            [ width fill, height fill, Font.color <| rgb 255 255 255]
            [
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Tab 2" ]
            ]

viewTab3 : Model -> Element Msg
viewTab3 model = 
    el [ centerX, centerY] 
        <|
            column
            [ width fill, height fill, Font.color <| rgb 255 255 255]
            [
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Tab 3" ]
            ]
viewTab4 : Model -> Element Msg
viewTab4 model = 
    el [ centerX, centerY] 
        <|
            column
            [ width fill, height fill, Font.color <| rgb 255 255 255]
            [
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Tab 4" ]
            ]
viewTab5 : Model -> Element Msg
viewTab5 model = 
    el [ centerX, centerY] 
        <|
            column
            [ width fill, height fill, Font.color <| rgb 255 255 255]
            [
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Tab 5" ]
            ]
viewTab6 : Model -> Element Msg
viewTab6 model = 
    el [ centerX, centerY] 
        <|
            column
            [ width fill, height fill, Font.color <| rgb 255 255 255]
            [
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Tab 6" ]
            ]
viewTab7 : Model -> Element Msg
viewTab7 model = 
    el [ centerX, centerY] 
        <|
            column
            [ width fill, height fill, Font.color <| rgb 255 255 255]
            [
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Tab 7" ]
            ]


-- Subscribe to the `messageReceiver` port to hear about messages coming in
-- from JS. Check out the index.html file to see how this is hooked up to a
-- WebSocket.
--

port onWheel : (Value -> msg) -> Sub msg

wheelDecoder : Decoder WheelModel
wheelDecoder =
    Decode.map2 WheelModel
        (Decode.field "deltaX" Decode.float)
        (Decode.field "deltaY" Decode.float)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onWheel
            (\val ->
                case Decode.decodeValue wheelDecoder val of
                    Ok wheelModel ->
                        Wheel wheelModel

                    Err _ ->
                        NoOp
            )
        , onResize 
            (\width height ->
                DeviceClassified (Element.classifyDevice { width = width, height = height }))
        ]

main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }