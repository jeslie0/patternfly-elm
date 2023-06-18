port module Main exposing (..)

import Browser
import Components.Accordion as A
import Components.Accordion.Content as AC
import Components.Accordion.Item exposing (..)
import Components.Accordion.Toggle as AT
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import List exposing (..)



-- * Ports


port consoleLog : String -> Cmd msg



-- * MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = viewDocument
        , update = update
        , subscriptions = subscriptions
        }



-- * MODEL


type alias Model =
    { isLoading : Bool
    , text : String
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { isLoading = False, text = "Click to start loading" }
    , Cmd.none
    )



-- * UPDATE


type Msg
    = Foo


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Foo ->
            ( if model.isLoading then
                { isLoading = False, text = "Click to start loading" }

              else
                { isLoading = True, text = "Click to stop loading" }
            , consoleLog "Hello, Foo!"
            )



-- * SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- * VIEW


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = ""
    , body = [ view model ]
    }


view : Model -> Html Msg
view model =
    H.div
        []
        [ (A.default
            |> A.withBorder True
            |> A.withListType A.Div
            |> A.withDisplaySize A.Large
            |> A.toHtml
          )
            [ HE.onClick Foo ]
            [ accordionItem
                [ H.h3 []
                    [ (AT.default "foo"
                        |> AT.withExpanded (not model.isLoading)
                        |> AT.toHtml
                      )
                        []
                        [ H.text "Item five" ]
                    ]
                , (AC.default
                    |> AC.withHidden model.isLoading
                    |> AC.toHtml
                  )
                    []
                    [ H.p [] [ H.text "Vivamus finibus dictum ex id ultrices. Mauris dictum neque a iaculis blandit." ] ]
                ]
            ]
        ]


type Button
    = Button String String


reverse : List a -> List a
reverse list =
    case list of
        [] ->
            []

        x :: xs ->
            reverse xs ++ [ x ]
