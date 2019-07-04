port module Main exposing (Message(..), Model, init, main, sendMessage, subscriptions, update, view)

import Browser
import Html exposing (Html, br, button, div, h1, h2, input, text)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Maybe.Extra



-- MODEL


type alias Model =
    { messagesReceived : List String
    , messageToSend : String
    }



-- INIT


init : ( Model, Cmd Message )
init =
    ( { messagesReceived = []
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
    , messagesView model.messagesReceived
    ]


messagesView : List String -> Html Message
messagesView messages =
    div []
        [ h2 [] [ text "Messages" ]
        , div [] <| List.map messageView messages
        ]


messageView : String -> Html Message
messageView message =
    div []
        [ text <| "Message: " ++ message
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
            ( { model | messagesReceived = message :: model.messagesReceived }
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
