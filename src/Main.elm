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
import Browser.Navigation exposing (back)
import  Html.Lazy as Lazy
import Slider 
import Html exposing (p)

type alias Model =

    { device : Device
    , dimensions : Flags
    , wheelModel : WheelModel
    , gesture : Swipe.Gesture
    , justChangedTab : Bool
    , tab : Int
    , tabState : TabState
    , about : AboutModalState
    , galleryTab1 : GalleryState
    , galleryTab2 : GalleryState
    , galleryTab3 : GalleryState
    , galleryTab4 : GalleryState
    , galleryTab5 : GalleryState
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

type AboutModalState
    = Visible
    | Hidden

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
    | ToggleAbout
    | NoOp

init : Flags -> ( Model, Cmd Msg )
init flags =
    ({    tab = 0
        , justChangedTab = False
        , device = Element.classifyDevice flags
        , dimensions = flags
        , wheelModel = initWheelModel
        , gesture = Swipe.blanco
        , about = Hidden
        , tabState = Loaded
        , galleryTab1 = initGalleryState (List.length ViewTab.imagesTab1)
        , galleryTab2 = initGalleryState (List.length ViewTab.imagesTab2)
        , galleryTab3 = initGalleryState (List.length ViewTab.imagesTab3)
        , galleryTab4 = initGalleryState (List.length <| ViewTab.embeddedTab4 <| Element.classifyDevice flags)
        , galleryTab5 = initGalleryState (List.length ViewTab.imagesTab5)
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

        updateIfAboutHidden : (Model, Cmd Msg) -> (Model, Cmd Msg)
        updateIfAboutHidden = \action -> 
            case model.about of
                Visible -> 
                    (model, Cmd.none)
                Hidden -> 
                    action

    in
        case msg of
            {-
                NAVIGATION messages
            -} 
            HandleKeyboardEvent event -> 
                updateIfAboutHidden
                    <|  case event.keyCode of
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
                updateIfAboutHidden
                    <|  case model.tabState of
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
                updateIfAboutHidden
                    <|  ({ model | gesture = Swipe.record touch model.gesture }, Cmd.none)
                        
            SwipeEnd touch ->
                updateIfAboutHidden
                    <|  let
                            gesture = Swipe.record touch model.gesture
                        in
                            if (Swipe.isUpSwipe 100.0 gesture) then
                                ({ model | gesture = Swipe.blanco}, Cmd.batch [toTab <| nextTab model.tab])
                            else if (Swipe.isDownSwipe 100.0 gesture) then
                                ({ model | gesture = Swipe.blanco}, Cmd.batch [toTab <| previousTab model.tab])
                            else
                                ({ model | gesture = Swipe.blanco}, Cmd.none)

            UserMovedSlider v ->
                updateIfAboutHidden
                    <|  (model, Cmd.batch [toTab (v // 10)])

            DeviceClassified flags ->
                ( { model | device = (Element.classifyDevice flags), dimensions = flags } , Cmd.none)

            GalleryMsg galleryMsg ->
                updateIfAboutHidden
                    <|  case (actualGallery model) of
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

            ToggleAbout ->  
                case model.about of
                    Visible -> 
                        ( { model | about = Hidden } , Cmd.none )
                    Hidden -> 
                        ( { model | about = Visible } , Cmd.none )

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
           Just model.galleryTab5
        4 ->
           Just model.galleryTab3
        5 ->
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
            { model | galleryTab5 = galleryState}
        4 ->
            { model | galleryTab3 = galleryState}
        5 ->
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
                Html.div 
                    [ Swipe.onStart Swipe
                    , Swipe.onMove Swipe
                    , Swipe.onEndWithOptions 
                        { stopPropagation = True
                        , preventDefault = False
                        } 
                        SwipeEnd
                    ]
                    [phoneLayout model]

            Tablet ->
                Html.div 
                    [ Swipe.onStart Swipe
                    , Swipe.onMove Swipe
                    , Swipe.onEndWithOptions 
                        { stopPropagation = True
                        , preventDefault = False
                        } 
                        SwipeEnd
                    ]
                    [phoneLayout model]
            Desktop ->
                desktopLayout model
            BigDesktop ->
                desktopLayout model

phoneLayout : Model -> Html Msg
phoneLayout model = 
    let 
        (deviceClass, deviceOrientation) = 
            case model.device of
                { class, orientation} -> (class, orientation)

    in 
        case deviceOrientation of
                Portrait ->
                    layout
                        [ width fill, height fill,
                            if model.tab == 0 then (Background.color <| rgba 0 0 0 0) else Background.color black08
                                        -- , behindContent <| infoDebug model -- TODO hide maybeÇ
                        , htmlAttribute (Attrs.attribute "style" "pointer-events: none ;")
                        ]
                        <| el (brandFontAttrs ++ [centerX, centerY, Font.color highlight, Font.center] )
                        <| text "Turn your device\n horizontally"

                Landscape ->
                    let 
                        conf = layoutConf model.device

                        name = \hidden -> el (brandFontAttrs ++ [ transparent hidden, width fill, height <| fillPortion 1, centerX, Font.color <| gray50] ) 
                            <| paragraph [ Font.center, centerY, Font.size 20, padding 10, onClick Head] [html <| animatedText "animatedSubTitle2" ["Mikel ","Dalmau"]]

                        attrs = (secondaryFontAttrs ++ [htmlAttribute (Attrs.attribute "style" "z-index: 10;"), height fill, Font.size 10, Font.color <| gray90, mouseOver [Font.color <| highlight]])
                        menuL = \hidden -> el (attrs ++ [transparent hidden, alignLeft, width (fillPortion 1)]) <| paragraph [Font.center, centerY, rotate <| degrees -90, onClick ToggleAbout, pointer] <| [ 
                            if model.about == Visible then text "Close" else (if  model.tab /= 0 then text "About" else html <| animatedText "animatedSubTitle3"  ["About"])]
                        menuR = \hidden -> el (attrs ++ [transparent hidden, alignRight, width <| px 120]) <| paragraph [Font.center, centerY, rotate <| degrees -90, pointer] <| [
                            link []
                                { url = partnerMailto
                                , label =  if model.about == Visible || model.tab /= 0 then  text "mikeldalmauc@gmail.com" else html <| animatedText "animatedSubTitle3" ["mikeldalmauc@gmail.com"] }
                            ]
                        slider = \hidden ->
                            if model.tab > 0 then 
                                el [transparent hidden, width <| fillPortion conf.vSliderWidthFactor, height fill, onRight 
                                    <| Slider.phoneSlider model.device model.tab (List.length tabs - 1)] none
                            else
                                el [transparent hidden, width <| fillPortion conf.vSliderWidthFactor, height fill] none

                        spaces = if model.tab == 0 then 
                                [ el [width <| fillPortion 2, height fill] none
                                , el [width <| fillPortion 2, height fill] none]    
                            else
                                [ el [width <| fillPortion 2, height fill] none
                                , el [width <| fillPortion 2, height fill] none
                                , el [width <| fillPortion 2, height fill] none
                                , el [width <| fillPortion 2, height fill] none]

                        about = 
                            case model.about of
                                Hidden ->
                                    []   
                                Visible ->
                                    [ inFront <| 
                                        column
                                            [ height fill, width fill]
                                            [ name True
                                            , row
                                                [ height <| fillPortion 18, width fill, spaceEvenly]
                                                [ menuL False
                                                -- , el [width <| fillPortion 2, height fill] none
                                                -- , 
                                                , viewTab Visible model
                                                , slider True
                                                , menuR False]
                                            , el [height <| fillPortion 1] none
                                            ]
                                    ]
                        backgroundAttrs = 
                            if model.tab == 0 then 
                                [htmlAttribute (Attrs.attribute "style" "background: none !important;")
                                -- ,htmlAttribute (Attrs.attribute "style" "pointer-events: none ;")
                                ]
                            else 
                                [Background.color black08]
                    in
                        layout
                            (about ++ [ width fill, height fill
                                -- , behindContent <| infoDebug model -- TODO hide maybeÇ
                                -- , Element.explain Debug.todo
                            ]++ backgroundAttrs)
                            <|  column
                                ((reduceOpacityWhenBehind model.about) ++ [ height fill, width fill]++ backgroundAttrs )
                                [ name False
                                , row
                                    [ height <| fillPortion 8, width fill]
                                    ( (menuL <| model.about == Visible) :: spaces ++ 
                                    [ viewTab Hidden model
                                    , slider False
                                    , menuR <| model.about == Visible])
                                , el [height <| fillPortion 1] none
                                ]
                        


desktopLayout : Model -> Html Msg
desktopLayout model = 
    let 
        
        conf = layoutConf model.device

        name = \hidden -> el (brandFontAttrs ++ [ transparent hidden, width fill, height <| fillPortion 1, centerX, Font.color <| gray50, mouseOver [Font.color <| highlight]  ]) 
            <| paragraph [ Font.center, centerY, Font.size 20, padding 40, onClick Head, pointer] [html <| animatedText "animatedSubTitle3" ["Mikel ","Dalmau"]]

        attrs = (secondaryFontAttrs ++ [htmlAttribute (Attrs.attribute "style" "z-index: 10;"), width (fillPortion 2), height fill, Font.size 12, Font.color <| gray80, mouseOver [Font.color <| highlight]])
        menuL = \hidden -> el (attrs ++ [transparent hidden, alignLeft]) <| paragraph [Font.center, centerY, rotate <| degrees -90, onClick ToggleAbout, pointer] <| 
            [ if model.about == Visible then text "Close" else (if  model.tab /= 0 then text "About" else html <| animatedText "animatedSubTitle3"  ["About"])]
        menuR = \hidden -> el (attrs ++ [ transparent hidden, alignRight]) <| paragraph [Font.center, centerY, rotate <| degrees -90, pointer] <| [
            link []
                { url = partnerMailto
                , label =  if model.about == Visible || model.tab /= 0 then  text "mikeldalmauc@gmail.com" else html <| animatedText "animatedSubTitle3" ["mikeldalmauc@gmail.com"] }
            ]
            
        -- Slider definition
        slider = \hidden ->
                if model.tab > 0 then 
                    el [transparent hidden, width <| fillPortion conf.vSliderWidthFactor, height fill, onRight 
                        <| Slider.tabsSlider model.device model.tab (List.length tabs - 1) (ToTab (previousTab model.tab)) (ToTab (previousTab model.tab))] none
                else
                    el [transparent hidden, width <| fillPortion conf.vSliderWidthFactor, height fill] none
        
        about = 
            case model.about of
                Hidden ->
                    []   
                Visible ->
                    [ inFront <| 
                        column
                            [ height fill, width fill]
                            [ name False
                            , row
                                [ height <| fillPortion 18, width fill, spaceEvenly]
                                [ menuL False
                                -- , el [width <| fillPortion 2, height fill] none
                                , viewTab Visible model
                                , slider True
                                , menuR False]
                            , el [height <| fillPortion 1] none
                            ]
                    ]
        backgroundAttrs = 
            if model.tab == 0 then 
                [htmlAttribute (Attrs.attribute "style" "background: none !important;")
                -- ,htmlAttribute (Attrs.attribute "style" "pointer-events: none ;")
                ]            
            else 
                [Background.color black08]
    in 
        layout
            (about ++ [ width fill, height fill
                -- , behindContent <| infoDebug model -- TODO hide maybeÇ
                -- , Element.explain Debug.todo
         
            ] ++ backgroundAttrs)
            <|  column
                ((reduceOpacityWhenBehind model.about) ++ [ height fill, width fill]++ backgroundAttrs)
                [ name <| model.about == Visible
                , row
                    [ height <| fillPortion 18, width fill, spaceEvenly]
                    [ menuL <| model.about == Visible
                    , el [width <| fillPortion 2, height fill] none
                    , viewTab Hidden model
                    , slider False
                    , menuR <| model.about == Visible]
                , el [height <| fillPortion 1] none
                ]


reduceOpacityWhenBehind : AboutModalState -> List (Attribute msg)
reduceOpacityWhenBehind about =
    if about == Hidden then [] else [htmlAttribute (Attrs.attribute "style" "filter: opacity(1);")]

infoDebug : Model -> Element msg
infoDebug model =
    column 
        [ width fill, height fill, Font.size 11, padding 10, Font.color <| rgb 255 255 255]
        [ text <| "wheel Delta Y: " ++ fromFloat model.wheelModel.deltaY
        , text <| "wheel Delta X: " ++ fromFloat model.wheelModel.deltaX
        , text <| "tab: " ++ fromInt model.tab
        -- , text <| "device: " ++ Debug.toString model.device
        -- , text <| "dimensions: " ++ Debug.toString model.dimensions
        -- , text <| "galleryTab1: " ++ Debug.toString model.galleryTab1
        -- , text <| "gesture: " ++ Debug.toString model.gesture
        ]


tabs : List (Model -> Element Msg )
tabs = 
    [viewTab0, viewTab1, viewTab2, viewTab5, viewTab3, viewTab4]
    
viewTab : AboutModalState -> Model -> Element Msg
viewTab about model =
    let 
        conf = layoutConf model.device

        (deviceClass, deviceOrientation) = 
            case model.device of
                { class, orientation} -> (class, orientation)

        heightFp = case deviceClass of 
            Phone ->  height (fillPortion conf.tabHeightPortion)
            _ -> height (fillPortion conf.tabHeightPortion)

    in  
        case about of
            Hidden ->
                case (head <| drop model.tab tabs ) of
                    Just tab ->
                        el (reduceOpacityWhenBehind model.about ++ [width (fillPortion conf.tabWidthPortion), heightFp]) <| tab model
                    Nothing ->
                        el (reduceOpacityWhenBehind model.about ++ [width (fillPortion conf.tabWidthPortion), heightFp]) <| viewTab1 model
            Visible ->
                el [width (fillPortion conf.tabWidthPortion), heightFp] <| viewAbout model

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
        

viewAbout : Model -> Element Msg
viewAbout model =
    let
        
        conf = layoutConf model.device
        backdrop = Html.div 
            [Attrs.attribute "style" "z-index:1; background-color: rgba(0, 0, 0, 0.8); height: 100vh;  width: 100vw; margin: 0; padding: 0; position: fixed; top:0; left:0;"]
            []
    in
        el [  height fill
            , behindContent <| html backdrop
            , centerY 
            , htmlAttribute (Attrs.attribute "style" "background: none !important;")
            -- , htmlAttribute (Attrs.attribute "style" "pointer-events: none ;")]
            ]
            <|
                column
                [centerY, width <| fillPortion 2, Font.color <| rgb 255 255 255, spacing 10]
                [ Element.textColumn [padding 10, spacing 40, width <| px conf.aboutWidth] 
                    [paragraph
                        (secondaryFontAttrs ++ [Font.size conf.aboutFontSize, Font.alignLeft])
                        [ text """Born and raised in the Basque Country. Educated at University of the Basque County on Software Engineering. Former engineer 
                        at QAD, Sopra Steria and Everis. Currenty teaching web development and electronics at professional training schools."""]
                    ,paragraph
                        (secondaryFontAttrs ++ [Font.size conf.aboutFontSize, Font.alignLeft])
                        [ text """Apart from programming my main passion is art as this site can show. I have been drawing and painting the last years in my free time.
                        I would love to be able to live from art and teaching while never stopping to programm as i consider it another mean of expression."""]
                    ,paragraph
                        (secondaryFontAttrs ++ [Font.size conf.aboutLinkFontSize, Font.alignLeft, pointer, Font.color Base.gray50, spacing 10])
                        [link [Font.underline, padding 5] { url = "https://www.instagram.com/mikel_dalmau_art/", label = text "Instagram"} 
                        , text "             "
                        , link [Font.underline, padding 5] { url = "https://www.linkedin.com/in/mkldalmau/", label = text "LinedIn" }
                        , text "             "
                        , link [Font.underline, padding 5] { url = "https://github.com/mikeldalmauc/portfoliov2", label = text "This website source"}
                        ]
                    ]
                , el [width <| px 600, transparent True] <| text "sss"
                ]


animatedText : String -> List String ->  Html msg 
animatedText class words = 
    let 
         animationAttrs = 
            "transform: scale(0.94);"
            ++"animation: scale 3s forwards cubic-bezier(0.5, 1, 0.89, 1);"
            ++ "white-space:pre"
    in
        Html.div [Attrs.class class, Attrs.attribute "style" animationAttrs]
            <| List.map (\word ->  Html.span [] [Html.text word]) words

viewTab0 : Model -> Element Msg 
viewTab0 model = 
    let
        
        conf = layoutConf model.device
        
       

        arrow = 
            el [height fill, centerX, padding conf.arrowPadding
            , htmlAttribute (Attrs.attribute "style" "opacity:0; animation: fade-in 1.5s 3.8s forwards cubic-bezier(0.11, 0, 0.5, 0);")]
            <| image [width <| px conf.arrowWidth
                , height <| px conf.arrowHeight
                , alignBottom
                , onClick <| Wheel { deltaX = 0, deltaY = 150.0 }
                , pointer
                ] {src="assets/downarrow.png", description="arrow pointing down"}  
    in
        el [ centerX, height fill, centerY, inFront arrow] 
            <|
                column
                [centerY, width fill, Font.color <| rgb 255 255 255, spacing 10
                ]
                [ paragraph
                        (brandFontAttrs ++ [Font.size conf.tab0TitleFontSize, Font.center])
                        [ html  <| animatedText "animatedTitle" ["Mikel ", "Dalmau"] ]
                , Element.textColumn [padding 10, spacing 10] 
                    [paragraph
                        (baseFontAttrs ++ [Font.size conf.tab0SubTitleFontSize, Font.center])
                        [ html  <| animatedText "animatedSubTitle" ["Software ", "Engineer"] ]
                    ,paragraph
                        (baseFontAttrs ++ [Font.size conf.tab0SubTitleFontSize, Font.center])
                        [ html  <| animatedText "animatedSubTitle2" ["&"] ] 
                    ,paragraph
                        (baseFontAttrs ++ [Font.size conf.tab0SubTitleFontSize, Font.center])
                        [ html  <| animatedText "animatedSubTitle2" ["Artist"] ]
                    ]
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
    viewSliderTab model.justChangedTab Nothing (Just <| ViewTab.embeddedTab4 model.device) Nothing ViewTab.textsTab4 model.dimensions model.device model.galleryTab4


viewTab5 : Model -> Element Msg
viewTab5 model = 
    viewSliderTab model.justChangedTab Nothing Nothing (Just ViewTab.imagesTab5) ViewTab.textsTab5 model.dimensions model.device model.galleryTab5


viewSliderTab : Bool -> Maybe (Device -> List ( String, Html Gallery.Msg )) -> Maybe (List String)  -> Maybe (List String) -> ViewTab.Texts -> Flags -> Device -> GalleryState -> Element Msg
viewSliderTab justChangedTab maybeLinks maybeEmbeddings maybeImages texts dimensions device galleryState = 

    let
        conf  = layoutConf device
        slidesTransitionTime =  if justChangedTab then 0 else 400
        imageConfig = ViewTab.imageConfig slidesTransitionTime (toFloat dimensions.width * conf.sliderWidthFactor) (toFloat dimensions.height * conf.sliderHeightFactor)
        textConfig = ViewTab.textConfig slidesTransitionTime (toFloat dimensions.width * conf.sliderWidthFactor) (toFloat dimensions.height * conf.sliderHeightFactor)
        hasLinks = 
            case maybeLinks of
                Just _ -> True
                Nothing -> False

        imageGallery = viewImageGallery hasLinks galleryState imageConfig maybeImages
        linksGallery = viewLinksGallery device  galleryState imageConfig maybeLinks
        embeddedGallery = viewEmbeddedsGallery galleryState imageConfig maybeEmbeddings
        textGallery = viewTextsGallery device galleryState textConfig texts linksGallery
        slidesCount = viewSlidesCount device maybeImages maybeEmbeddings galleryState

    in
        el [ centerX, centerY ]
            <| row
            [ width fill, height fill, Font.color <| rgb 255 255 255
            , behindContent imageGallery
            , behindContent embeddedGallery
            , behindContent slidesCount
            ]
            [
                textGallery
            ]


viewImageGallery : Bool -> GalleryState -> Gallery.Config ->  Maybe (List String) -> Element Msg
viewImageGallery hasLinks galleryState imageConfig maybeImages =
    case maybeImages of 
        Just images -> 
            let
                arrows = if hasLinks then [] else [Gallery.Arrows]
            in
            
                el [] <| html <| Html.div [] <| [Html.map GalleryMsg <|
                        Gallery.view imageConfig galleryState.image arrows (ViewTab.imageSlides images)]
        Nothing -> 
            el [] none

viewLinksGallery : Device -> GalleryState -> Gallery.Config -> Maybe (Device -> List ( String, Html Gallery.Msg )) -> Element Msg
viewLinksGallery device galleryState imageConfig maybeLinks  =
    let
        conf  = layoutConf device
    in
        case maybeLinks of
            Just linksSectionView -> 
                el [transparent False, moveRight conf.leftDisplacement, moveDown conf.upDisplacement] 
                    <| html <| Html.div [] <| [Html.map GalleryMsg <|
                        Gallery.viewClickable imageConfig galleryState.links [Gallery.Arrows] <| linksSectionView device]
            Nothing -> 
                el [] none

viewEmbeddedsGallery : GalleryState -> Gallery.Config -> Maybe (List String) -> Element Msg
viewEmbeddedsGallery galleryState imageConfig maybeEmbeddings = 
    case maybeEmbeddings of
        Just embeddedSectionView -> 
            el []  <| html <| Html.div [] <| [Html.map GalleryMsg <|
                    Gallery.viewClickable imageConfig galleryState.image [Gallery.Arrows] <| (ViewTab.embeddedSlides embeddedSectionView) ]
        Nothing -> 
            el [] none


viewTextsGallery : Device -> GalleryState -> Gallery.Config -> ViewTab.Texts -> Element Msg -> Element Msg
viewTextsGallery device galleryState textConfig texts linksGallery = 
    let 
        conf  = layoutConf device
    in
        el (brandFontAttrs 
            ++ [  width fill
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
    

viewSlidesCount : Device -> Maybe (List String) -> Maybe (List String) -> GalleryState -> Element Msg
viewSlidesCount device maybeImages maybeEmbeddings galleryState =
    let 
        slider = \images -> 
            let
                    conf  = layoutConf device
                    stickAttrs = [width <| px conf.slideCountWidth, height <| px conf.slideCountHeight, Border.rounded 1]
                    stick = el (Background.color gray50::stickAttrs) none
                    stickGlowing = el ([Background.color gray80, Border.glow (rgba 1 1 1 0.8) 1.0] ++ stickAttrs) none
            in  
                List.range 1 (length images) 
                    |> List.map (\i -> if i == Gallery.current galleryState.image + 1 then stickGlowing else stick)
                    |> row [alignRight, alignBottom, spacing conf.slideCountSpacing, moveLeft conf.slideLeftDisp, moveDown conf.slideDownDisp]
    in
        case maybeImages of 
                Just images -> slider images
                    
                Nothing -> 
                    case maybeEmbeddings of 
                        Just embeddings -> slider embeddings
                        Nothing -> el [] none


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