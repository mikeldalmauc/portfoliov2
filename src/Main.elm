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
import Html.Attributes as Attrs exposing (align)
import String exposing (right)
import Gallery
import Gallery.Image as Image
import Platform.Cmd as Cmd
import ViewTab exposing (..)
import Element.Font exposing (shadow)
import Random 
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)
import Keyboard.Key as Key
import Json.Decode as Json


type alias Model =

    { tab : Int
    , tabState : TabState
    , justChangedTab : Bool
    , device : Device
    , dimensions : Flags
    , wheelModel : WheelModel
    , gesture : Swipe.Gesture

    , galleryTab1 : GalleryState
    , galleryTab2 : GalleryState
    , galleryTab3 : GalleryState
    , galleryTab4 : GalleryState
    }

type alias GalleryState = 
    { image: Gallery.State
    , text: Gallery.State
    , links: Gallery.State
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
    | HandleKeyboardEvent KeyboardEvent
    | Head
    | ToTab Int
    | GalleryMsg Gallery.Msg
    | DeviceClassified Flags
    | NoOp

init : Flags -> ( Model, Cmd Msg )
init flags =
    ({    tab = 0
        , tabState = Loaded
        , justChangedTab = False
        , device = Element.classifyDevice flags
        , dimensions = flags
        , wheelModel = initWheelModel
        , gesture = Swipe.blanco
        , galleryTab1 = initGalleryState (List.length ViewTab.imagesTab1)
        , galleryTab2 = initGalleryState (List.length ViewTab.imagesTab2)
        , galleryTab3 = initGalleryState (List.length ViewTab.imagesTab3)
        , galleryTab4 = initGalleryState (List.length ViewTab.embeddedTab4)
    }
    , Cmd.none
    )

initWheelModel : WheelModel
initWheelModel = 
    { deltaX = 0, deltaY = 0 }
    
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg modelPrev =
    let
        model = {modelPrev | justChangedTab = False}
    in
        case msg of
            {-
                NAVIGATION messages
            -} 
            HandleKeyboardEvent event -> 
                case event.keyCode of
                    Key.Right ->  
                        case (actualGallery model) of
                            Just galleryState -> 
                                (updateGallery 
                                    { image =Gallery.next galleryState.image
                                    , links = Gallery.next galleryState.links
                                    , text = Gallery.next galleryState.text} 
                                    model, Cmd.none)
                            Nothing -> 
                                ( model, Cmd.none )
                    Key.Left ->  
                        case (actualGallery model) of
                            Just galleryState -> 
                                (updateGallery
                                { image =Gallery.previous galleryState.image
                                , links = Gallery.previous galleryState.links
                                , text = Gallery.previous galleryState.text} 
                                 model, Cmd.none)
                            Nothing -> 
                                ( model, Cmd.none )

                    Key.Up -> 
                        ( model , Cmd.batch [toTab <| previousTab model.tab])
                    Key.Down ->  
                        ( model , Cmd.batch [toTab <| nextTab model.tab] )
                    _ -> 
                        (model, Cmd.none)
                                

            Wheel wheelModel ->
                case model.tabState of
                    Loading -> 
                        ( model, Cmd.none )
                    Loaded -> 
                        if  wheelModel.deltaY < 0.0 then                       
                            ( {model |  wheelModel = initWheelModel} , Cmd.batch [toTab <| previousTab model.tab])
                        else
                            ( {model | wheelModel = initWheelModel} , Cmd.batch [toTab <| nextTab model.tab] )
            
            ToTab tab ->
                ( {model | tab = tab, justChangedTab = True} , Cmd.none )
                
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
                    ({ model | gesture = Swipe.blanco}, Cmd.batch [toTab newTab])

            UserMovedSlider v ->
                (model, Cmd.batch [toTab (v // 10)])

            DeviceClassified flags ->
                ( { model | device = (Element.classifyDevice flags), dimensions = flags } , Cmd.none)

            GalleryMsg galleryMsg ->
                case (actualGallery model) of
                    Just galleryState -> 
                        (updateGallery
                         { image =Gallery.update galleryMsg galleryState.image
                        , links = Gallery.update galleryMsg  galleryState.links
                        , text = Gallery.update galleryMsg galleryState.text}  
                         model, Cmd.none)
                    Nothing -> 
                        ( model, Cmd.none )

            Head -> 
                ( model , Cmd.batch [toTab 0] )

            NoOp ->
                ( model, Cmd.none )


initGalleryState : Int -> GalleryState
initGalleryState length =  
    { image = Gallery.init length
    , text = Gallery.init length
    , links = Gallery.init length
    }


actualGallery : Model -> Maybe GalleryState
actualGallery model =  
    case model.tab of
        1 ->
           Just model.galleryTab1
        2 ->
           Just model.galleryTab2
        3 ->
           Just model.galleryTab3
        4 ->
           Just model.galleryTab4
        _ ->
            Nothing

updateGallery : GalleryState -> Model -> Model
updateGallery  galleryState model = 
     case model.tab of
        1 ->
            { model | galleryTab1 = galleryState}
        2 ->
            { model | galleryTab2 = galleryState}
        3 ->
            { model | galleryTab3 = galleryState}
        4 ->
            { model | galleryTab4 = galleryState}
        _ -> model

            

-- This is a workaround  to issue a message becaouse i am unable to making it the correct way
toTab : Int -> Cmd Msg
toTab tab =
    Random.generate ToTab (Random.constant tab) 


view : Model -> Html Msg
view model =
    let 
        (deviceClass, deviceOrientation) = 
            case model.device of
                { class, orientation} -> (class, orientation)
    in
        case deviceClass of
            Phone ->
                desktopLayout model
            Tablet ->
                desktopLayout model
            Desktop ->
                desktopLayout model
            BigDesktop ->
                desktopLayout model
    -- Html.div 
        -- [ Swipe.onStart Swipe
        -- , Swipe.onMove Swipe
        -- , Swipe.onEndWithOptions 
        --     { stopPropagation = True
        --     , preventDefault = False
        --     } 
        --     SwipeEnd
        -- ]
        -- [ bigDesktopLayout model ]

        {-
              if shortSide < 600 then
            Phone

        else if longSide <= 1200 then
            Tablet

        else if longSide > 1200 && longSide <= 1920 then
            Desktop

        else
            BigDesktop
        -}


desktopLayout : Model -> Html Msg
desktopLayout model = 
    let 
        
        conf = layoutConf model.device

        name = el (brandFontAttrs ++ [ width fill, height <| fillPortion 1, centerX, Font.color <| gray50, mouseOver [Font.color <| highlight]  ]) 
            <| paragraph [ Font.center, centerY, Font.size 20, padding 40, onClick Head, pointer] [ text "Mikel Dalmau" ]

        attrs = (secondaryFontAttrs ++ [width (fillPortion 2), height fill, Font.size 12, Font.color <| gray80, mouseOver [Font.color <| highlight]])
        menuL = el (attrs ++ [alignLeft]) <| paragraph [Font.center, centerY, rotate <| degrees -90, onClick Head, pointer] <| [ text "About"]
        menuR = el (attrs ++ [alignRight]) <| paragraph [Font.center, centerY, rotate <| degrees -90, pointer] <| [
            link []
                { url = partnerMailto
                , label = text "mikeldalmauc@gmail.com"}
            ]
            
        -- Slider definition
        slider = if model.tab > 0 then 
                    el [width <| fillPortion conf.vSliderWidthFactor, height fill, onRight <| tabsSlider model.tab ] none
                else
                    el [width <| fillPortion conf.vSliderWidthFactor, height fill] none
    in 
        layout
            [ width fill, height fill, Background.color black08
                , behindContent <| infoDebug model -- TODO hide maybe
                -- , Element.explain Debug.todo
            ]
            <|  column
                [ height fill, width fill]
                [ name
                , row
                    [ height <| fillPortion 18, width fill, spaceEvenly]
                    [  menuL
                    , el [width <| fillPortion 2, height fill] none
                    , viewTab model
                    , slider
                    , menuR]
                , el [height <| fillPortion 1] none
                ]



infoDebug : Model -> Element msg
infoDebug model =
    column 
        [ width fill, height fill, Font.size 11, padding 10, Font.color <| rgb 255 255 255]
        [ text <| "wheel Delta Y: " ++ fromFloat model.wheelModel.deltaY
        , text <| "wheel Delta X: " ++ fromFloat model.wheelModel.deltaX
        , text <| "tab: " ++ fromInt model.tab
        , text <| "device: " ++ Debug.toString model.device
        , text <| "dimensions: " ++ Debug.toString model.dimensions
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
            el [width (fillPortion 14), height (fillPortion 1)] <| tab model
        Nothing ->
            el [width (fillPortion 14), height (fillPortion 1)] <| viewTab1 model

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
   viewSliderTab model.justChangedTab Nothing Nothing (Just ViewTab.imagesTab1) ViewTab.textsTab1 model.dimensions model.device model.galleryTab1


viewTab2 : Model -> Element Msg
viewTab2 model = 
    viewSliderTab model.justChangedTab Nothing Nothing (Just ViewTab.imagesTab2) ViewTab.textsTab2 model.dimensions model.device model.galleryTab2


viewTab3 : Model -> Element Msg
viewTab3 model = 
    viewSliderTab model.justChangedTab (Just linkToPage) Nothing (Just ViewTab.imagesTab3) ViewTab.textsTab3 model.dimensions model.device model.galleryTab3


viewTab4 : Model -> Element Msg
viewTab4 model = 
    viewSliderTab model.justChangedTab Nothing (Just ViewTab.embeddedTab4) Nothing ViewTab.textsTab4 model.dimensions model.device model.galleryTab4


viewSliderTab : Bool -> Maybe (Device -> List ( String, Html Gallery.Msg )) -> Maybe (List String)  -> Maybe (List String) -> ViewTab.Texts -> Flags -> Device -> GalleryState -> Element Msg
viewSliderTab justChangedTab maybeLinks maybeEmbeddings maybeImages texts dimensions device galleryState = 

    let
        conf  = layoutConf device
        slidesTransitionTime = if justChangedTab then
                            0
                        else
                            400

        imageConfig = ViewTab.imageConfig slidesTransitionTime (toFloat dimensions.width * conf.sliderWidthFactor) (toFloat dimensions.height * conf.sliderHeightFactor)
        textConfig = ViewTab.textConfig slidesTransitionTime (toFloat dimensions.width * conf.sliderWidthFactor) (toFloat dimensions.height * conf.sliderHeightFactor)
        
        imageGallery = 
            case maybeImages of 
                Just images -> 
                     case maybeLinks of
                            Just _ -> 
                                el [] <| html <| Html.div [] <| [Html.map GalleryMsg <|
                                        Gallery.view imageConfig galleryState.image [] (ViewTab.imageSlides images)]
                            Nothing -> 
                                el [] <| html <| Html.div [] <| [Html.map GalleryMsg <|
                                        Gallery.view imageConfig galleryState.image [Gallery.Arrows] (ViewTab.imageSlides images)]
                Nothing -> 
                    el [] none

        linksGallery = 
            case maybeLinks of
                Just linksSectionView -> 
                    el [transparent False, moveRight conf.leftDisplacement, moveDown conf.upDisplacement] 
                        <| html <| Html.div [] <| [Html.map GalleryMsg <|
                            Gallery.viewClickable imageConfig galleryState.links [Gallery.Arrows] <| linksSectionView device]
                Nothing -> 
                    el [] none
                
        embeddedGallery = 
            case maybeEmbeddings of
                Just embeddedSectionView -> 
                    el []  <| html <| Html.div [] <| [Html.map GalleryMsg <|
                            Gallery.viewClickable imageConfig galleryState.image [Gallery.Arrows] <| (ViewTab.embeddedSlides embeddedSectionView) ]
                Nothing -> 
                    el [] none

        
        textGallery = el (brandFontAttrs ++ [
              width fill
            , height fill
            , Font.size conf.fontSize
            , moveLeft conf.leftDisplacement
            , moveUp conf.upDisplacement
            , Font.alignLeft
            , htmlAttribute (Attrs.attribute "style" "pointer-events: none;")
            , shadow {offset = (5, 5), blur = 5, color= rgba 0 0 0 0.5}
            , inFront linksGallery
            ]) 
            <| html 
                <| Html.div [] [Html.map GalleryMsg <| Gallery.viewText textConfig galleryState.text [] (ViewTab.textSlides device texts) ]
    in
        el [ centerX, centerY] 
            <|
                row
                [ width fill, height fill, Font.color <| rgb 255 255 255
                , behindContent imageGallery
                , behindContent embeddedGallery
                ]
                [
                   textGallery
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
        [ onKeyDown (Json.map HandleKeyboardEvent decodeKeyboardEvent)
        , onWheel
            (\val ->
                case Decode.decodeValue wheelDecoder val of
                    Ok wheelModel ->
                        Wheel wheelModel

                    Err _ ->
                        NoOp
            )
        , onResize 
            (\width height ->
                DeviceClassified { width = width, height = height })
        ]

main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }