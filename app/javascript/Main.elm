port module Main exposing (Message(..), Model, init, main, sendMessage, subscriptions, update, view)

import Browser
import Html exposing (Html, br, button, h1, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)



-- MODEL


type alias Model =
    {}



-- INIT


init : ( Model, Cmd Message )
init =
    ( Model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Message
view model =
    { title = "Hello, ActionCable"
    , body = bodyView model
    }


bodyView : Model -> List (Html Message)
bodyView model =
    [ -- The inline style is being used for example purposes in order to keep this example simple and
      -- avoid loading additional resources. Use a proper stylesheet when building your own app.
      h1 [ style "display" "flex", style "justify-content" "center" ]
        [ text "Hello Again!"
        ]
    , button [ onClick SendMessage ] [ text "Send Message" ]
    ]



-- MESSAGE


type Message
    = SendMessage



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        SendMessage ->
            ( model, sendMessage "TRIGGERED FROM ELM!" )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none



-- PORTS


port sendMessage : String -> Cmd msg



-- MAIN


main : Program (Maybe {}) Model Message
main =
    Browser.document
        { init = always init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
