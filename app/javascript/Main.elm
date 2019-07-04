port module Main exposing (Message(..), Model, init, main, sendMessage, subscriptions, update, view)

import Browser
import Html exposing (Html, br, button, div, h1, h2, input, text)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Maybe.Extra



-- MODEL


type alias Model =
    { messagesReceived : List IncomingMessage
    , messageToSend : String
    , userId : String
    , userName : String
    }


type alias IncomingMessage =
    { userId : String
    , userName : String
    , message : String
    }



-- INIT


type alias Flags =
    { userId : String
    }


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { messagesReceived = []
      , messageToSend = ""
      , userId = flags.userId
      , userName = "Unnamed User"
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
    , div [] [ text <| "Your user id: " ++ model.userId ]
    , div []
        [ text "Your name: "
        , input [ onInput UserUpdatesUserName, value model.userName ] []
        ]
    , input [ onInput UserUpdatesMessageToSend, value model.messageToSend ] []
    , button [ onClick UserClickedSendMessageButton ] [ text "Send Message" ]
    , messagesView model
    ]


messagesView : { model | userId : String, messagesReceived : List IncomingMessage } -> Html Message
messagesView { userId, messagesReceived } =
    div []
        [ h2 [] [ text "Messages" ]
        , div [] <| List.map (messageView userId) messagesReceived
        ]


messageView : String -> IncomingMessage -> Html Message
messageView myUserId incomingMessage =
    let
        userView msgUserId =
            if msgUserId == myUserId then
                "(you)"

            else
                ""
    in
    div []
        [ text <| "Message sent by " ++ incomingMessage.userName ++ userView incomingMessage.userId ++ " : " ++ incomingMessage.message
        ]



-- MESSAGE


type Message
    = UserClickedSendMessageButton
    | PortSentMessage IncomingMessage
    | UserUpdatesMessageToSend String
    | UserUpdatesUserName String



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        UserClickedSendMessageButton ->
            ( { model | messageToSend = "" }
            , sendMessage
                { userId = model.userId
                , message = model.messageToSend
                , userName = model.userName
                }
            )

        PortSentMessage message ->
            ( { model | messagesReceived = message :: model.messagesReceived }
            , Cmd.none
            )

        UserUpdatesMessageToSend message ->
            ( { model | messageToSend = message }
            , Cmd.none
            )

        UserUpdatesUserName userName ->
            ( { model | userName = userName }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    receivedMessage (\{ user_id, user_name, message } -> PortSentMessage { userId = user_id, userName = user_name, message = message })



-- PORTS


port sendMessage : { userId : String, message : String, userName : String } -> Cmd msg


port receivedMessage : ({ user_id : String, user_name : String, message : String } -> msg) -> Sub msg



-- MAIN


main : Program Flags Model Message
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
