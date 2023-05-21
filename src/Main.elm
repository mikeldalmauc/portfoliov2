port module Main exposing (..)

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Browser.Events exposing (onResize)
import Element.Background as Background
import Html exposing (Html)
import Browser
import Browser.Events exposing (onKeyDown)
import Json.Decode as Decode exposing (Decoder, Value)
import String exposing (fromFloat)
import String exposing (fromInt)
import List exposing (take, head, drop, length)
import Mailto exposing (Mailto, mailto, subject, cc, bcc, body)
import Base exposing (..)
import Element.Events exposing (onClick)
import Swiper

type alias Model =

    { tab : Int
    , tabState : TabState
    , device : Device
    , wheelModel : WheelModel
    , swipingState : Swiper.SwipingState
    , userSwipedDown : Bool
    , userSwipedUp : Bool
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
    | Swiped Swiper.SwipeEvent
    | DeviceClassified Device
    | Head
    | NoOp

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { 
        tab = 0
      , tabState = Loaded
      , device = Element.classifyDevice flags
      , wheelModel = initWheelModel
      , swipingState = Swiper.initialSwipingState
      , userSwipedDown = False
      , userSwipedUp = False
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
        Swiped evt ->
            let
                (newStateDown, swipedDown) =
                    Swiper.hasSwipedDown evt model.swipingState
                
                (newStateUp, swipedUp) =
                    Swiper.hasSwipedUp evt model.swipingState
            in
                if swipedDown then
                    ( { model | tab = previousTab model.tab, swipingState = newStateDown, userSwipedDown = swipedDown}, Cmd.none )
                else
                    if swipedUp then
                        ( { model | tab = nextTab model.tab, swipingState = newStateUp, userSwipedUp = swipedUp}, Cmd.none )
                    else
                        (  { model | swipingState = newStateDown}, Cmd.none )

        DeviceClassified device ->
            ( { model | device = device } , Cmd.none)

        Head -> 
            ( {model | tab = 0} , Cmd.none )
        NoOp ->
            ( model, Cmd.none )

partnerMailto : String
partnerMailto =
    mailto "mikeldalmauc@gmail.co"
        |> subject "Hello Mikel"
        |> Mailto.toString


view : Model -> Html Msg
view model =
    let
        name = el (brandFontAttrs ++ [ width fill, height <| fillPortion 1, centerX, Font.color <| rgb 255 255 255]) 
            <| paragraph [ Font.center, centerY, Font.size 20, padding 40, onClick Head, pointer] [ text "Mikel Dalmau" ]

        attrs = (baseFontAttrs ++ [width (fillPortion 1), height (fillPortion 1), Font.size 12, Font.color <| rgb 255 255 255])
        menuL = el (attrs ++ [alignLeft]) <| paragraph [Font.center, centerY, rotate <| degrees -90, onClick Head, pointer] <| [ text "About"]
        menuR = el (attrs ++ [alignRight]) <| paragraph [Font.center, centerY, rotate <| degrees -90] <| [
            link []
                { url = partnerMailto
                , label = text "mikeldalmauc@gmail.com"}
            ]
     
    in
        Html.div ([] ++ Swiper.onSwipeEvents Swiped) 
        [layout
            [ width fill, height fill, Background.color <| rgb 0 0 0
                -- , behindContent <| infoDebug model -- TODO hide maybe
            ] 
            <| column
                [ explain Debug.todo,height fill, width fill]
                [ name
                , row
                    [ height <| fillPortion 18, width fill, spaceEvenly]
                    [ menuL
                    , viewTab model
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
        ]


tabs : List (Model -> Element Msg )
tabs = 
    [viewTab1, viewTab2, viewTab3, viewTab4, viewTab5, viewTab6, viewTab7]
    
viewTab : Model -> Element Msg
viewTab model =
    case (head <| drop model.tab tabs ) of
        Just tab ->
            el [width (fillPortion 3), height (fillPortion 1)] <| tab model
        Nothing ->
            el [width (fillPortion 3), height (fillPortion 1)] <| viewTab1 model

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
        

viewTab1 : Model -> Element Msg 
viewTab1 model = 
    let
        arrow = 
            el [height fill, centerX, padding 45]
            <| image [width <| px 17, 
                height <| px 60, alignBottom
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

viewTab2 : Model -> Element msg
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

viewTab3 : Model -> Element msg
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
viewTab4 : Model -> Element msg
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
viewTab5 : Model -> Element msg
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
viewTab6 : Model -> Element msg
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
viewTab7 : Model -> Element msg
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