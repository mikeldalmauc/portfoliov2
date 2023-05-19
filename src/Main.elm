port module Main exposing (..)

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Background as Background
import Html exposing (Html)
import Browser
import Browser.Events exposing (onKeyDown)
import Json.Decode as Decode exposing (Decoder, Value)
import String exposing (fromFloat)
import String exposing (fromInt)
import List exposing (take, head, drop, length)
import Mailto exposing (Mailto, mailto, subject, cc, bcc, body)


type alias Model =

    {   tab : Int
    ,   tabState : TabState
    ,   wheelModel : WheelModel
    }

type alias WheelModel =
    { deltaX : Float
    , deltaY : Float
    }

type TabState
    = Loading
    | Loaded

type Msg =
      Wheel WheelModel
    | NoOp

init : ( Model, Cmd Msg )
init =
    ( { 
        tab = 0
      , tabState = Loaded
      , wheelModel = initWheelModel
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
               
        NoOp ->
            ( model, Cmd.none )


menu : Element msg
menu =
    row
        [ width fill, height fill, Font.size 11, padding 10, Font.color <| rgb 255 255 255]
        [ el [alignLeft, centerY] <| paragraph [rotate <| degrees -90, Font.center] <| [ text "About"]
        , el [alignRight, centerY] <| paragraph [rotate <| degrees -90, Font.center] <| [
            link []
                { url = partnerMailto
                , label = text "mikeldalmauc@gmail.com"
                }
            ]
        ]

partnerMailto : String
partnerMailto =
    mailto "mikeldalmauc@gmail.co"
        |> subject "Hello Mikel"
        |> Mailto.toString


view : Model -> Html Msg
view model =
    layout
        [ width fill, height fill, inFront menu, Background.color <| rgb 0 0 0 
            , behindContent <| infoDebug model -- TODO hide maybe
        ]
        <| viewTab model

infoDebug : Model -> Element msg
infoDebug model =
    column 
        [ width fill, height fill, Font.size 11, padding 10, Font.color <| rgb 255 255 255]
        [ text <| "wheel Delta Y: " ++ fromFloat model.wheelModel.deltaY
        , text <| "wheel Delta X: " ++ fromFloat model.wheelModel.deltaX
        , text <| "tab: " ++ fromInt model.tab
        ]


tabs : List (Model -> Element msg )
tabs = 
    [viewTab1, viewTab2, viewTab3]
    
viewTab : Model -> Element msg
viewTab model =
    case (head <| drop model.tab tabs ) of
        Just tab ->
            tab model
        Nothing ->
            viewTab1 model

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
        

viewTab1 : Model -> Element msg 
viewTab1 model = 
    el [ centerX, centerY] 
        <|
            column
            [ width fill, height fill, Font.color <| rgb 255 255 255]
            [
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Mikel Dalmau" ]
            ,
                paragraph
                    [ Font.size 48, Font.center ]
                    [ el [ Font.italic ] <| text "Image engineer"]
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
        ]

main : Program () Model Msg
main =
    Browser.element
        { init = always init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }