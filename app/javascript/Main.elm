port module Main exposing (Message(..), Model, init, main, sendMessage, subscriptions, update, view)

import Browser
import Html exposing (Html, br, button, h1, input, text)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Maybe.Extra



-- MODEL


type alias Model =
    { messageReceived : Maybe String
    , messageToSend : String
    }



-- INIT


init : ( Model, Cmd Message )
init =
    ( { messageReceived = Nothing
      , messageToSend = ""
      }
    , Cmd.none
    )



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
        [ text "Send A Chat Message"
        ]
    , input [ onInput UserUpdatesMessageToSend, value model.messageToSend ] []
    , button [ onClick UserClickedSendMessageButton ] [ text "Send Message" ]
    , br [] []
    , Maybe.Extra.unwrap (text "") (\msg -> text <| "Message Received! " ++ msg) model.messageReceived
    ]



-- MESSAGE


type Message
    = UserClickedSendMessageButton
    | PortSentMessage String
    | UserUpdatesMessageToSend String



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        UserClickedSendMessageButton ->
            ( { model | messageToSend = "" }
            , sendMessage model.messageToSend
            )

        PortSentMessage message ->
            ( { model | messageReceived = Just message }
            , Cmd.none
            )

        UserUpdatesMessageToSend message ->
            ( { model | messageToSend = message }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    receivedMessage PortSentMessage



-- PORTS


port sendMessage : String -> Cmd msg


port receivedMessage : (String -> msg) -> Sub msg



-- MAIN


main : Program (Maybe {}) Model Message
main =
    Browser.document
        { init = always init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
