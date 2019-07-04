port module Main exposing (Message(..), Model, init, main, sendMessage, subscriptions, update, view)

import Browser
import Html exposing (Html, br, button, div, h1, h2, input, text)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Json.Encode
import Maybe.Extra



-- MODEL


type alias Model =
    { messagesReceived : List IncomingMessage
    , messageToSend : String
    , userId : UserId
    , userName : String
    }



-- INIT


type alias Flags =
    { userId : String
    }


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { messagesReceived = []
      , messageToSend = ""
      , userId = UserId flags.userId
      , userName = "Unnamed User"
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Browser.Document Message
view model =
    { title = "Chat: " ++ userIdToString model.userId
    , body = bodyView model
    }


bodyView : Model -> List (Html Message)
bodyView model =
    [ h1 [ style "display" "flex", style "justify-content" "center" ]
        [ text "Chatting With Elm"
        ]
    , div [] [ text <| "Your user id: " ++ userIdToString model.userId ]
    , div []
        [ text "Your name: "
        , input [ onInput UserUpdatesUserName, value model.userName ] []
        ]
    , input [ onInput UserUpdatesMessageToSend, value model.messageToSend ] []
    , button [ onClick UserClickedSendMessageButton ] [ text "Send Message" ]
    , messagesView model
    ]


messagesView : { model | userId : UserId, messagesReceived : List IncomingMessage } -> Html Message
messagesView { userId, messagesReceived } =
    div []
        [ h2 [] [ text "Messages" ]
        , div [] <| List.map (messageView userId) messagesReceived
        ]


messageView : UserId -> IncomingMessage -> Html Message
messageView myUserId incomingMessage =
    let
        userView msgUserId =
            if msgUserId == myUserId then
                "(you)"

            else
                ""

        messageDisplay =
            case incomingMessage of
                MessageParsingError err ->
                    "Error parsing message " ++ Json.Decode.errorToString err

                MessageReceived message ->
                    "Message sent by " ++ message.userName ++ userView message.userId ++ " : " ++ message.message
    in
    div [] [ text messageDisplay ]



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
            , sendMessage <| encodeChatMessage model
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



-- TYPES


type UserId
    = UserId String


userIdDecoder : Json.Decode.Decoder UserId
userIdDecoder =
    Json.Decode.map UserId Json.Decode.string


userIdToString : UserId -> String
userIdToString (UserId userId) =
    userId


type alias ChatMessage =
    { userId : UserId
    , userName : String
    , message : String
    }


type IncomingMessage
    = MessageParsingError Json.Decode.Error
    | MessageReceived ChatMessage


decodeIncomingMessage : Json.Decode.Value -> IncomingMessage
decodeIncomingMessage msgValue =
    case Json.Decode.decodeValue chatMessageDecoder msgValue of
        Ok message ->
            MessageReceived message

        Err err ->
            MessageParsingError err


chatMessageDecoder : Json.Decode.Decoder ChatMessage
chatMessageDecoder =
    Json.Decode.map3 ChatMessage
        (Json.Decode.field "user_id" userIdDecoder)
        (Json.Decode.field "user_name" Json.Decode.string)
        (Json.Decode.field "message" Json.Decode.string)


encodeChatMessage : { model | userId : UserId, userName : String, messageToSend : String } -> Json.Encode.Value
encodeChatMessage { userId, userName, messageToSend } =
    Json.Encode.object
        [ ( "user_id", Json.Encode.string <| userIdToString userId )
        , ( "user_name", Json.Encode.string userName )
        , ( "message", Json.Encode.string messageToSend )
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    receivedMessage (decodeIncomingMessage >> PortSentMessage)



-- PORTS


port sendMessage : Json.Encode.Value -> Cmd msg


port receivedMessage : (Json.Decode.Value -> msg) -> Sub msg



-- MAIN


main : Program Flags Model Message
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
