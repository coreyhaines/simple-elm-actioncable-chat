// Run this example by adding <%= javascript_pack_tag "hello_elm" %> to the
// head of your layout file, like app/views/layouts/application.html.erb.
// It will render "Hello Elm!" within the page.

import {
  Elm
} from '../Main'

import { sendMessage, setCallback } from '../cable_client'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-app')
  const chatUserIdNode = document.head.querySelector("[name~='chat_user_id'][content]")
  let chatUserId;
  if(chatUserIdNode) {
    chatUserId = chatUserIdNode.content
  }else{
    chatUserId = "userid-not-set"
  }
  const app = Elm.Main.init({
    node: target,
    flags: {
      userId: chatUserId
    }
  })

  setCallback((msg) => {
    console.log("received", msg);
    app.ports.receivedMessage.send(msg);
  });
  app.ports.sendMessage.subscribe((message) => { sendMessage(message) });
})
