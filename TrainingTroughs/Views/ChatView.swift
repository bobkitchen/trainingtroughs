//  ChatView.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 4/18/25.
//

import SwiftUI

struct ChatView: View {
  @ObservedObject var chatVM: ChatViewModel  // you already have

  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView {
          ForEach(chatVM.messages) { msg in
            HStack {
              if msg.role == .assistant { Spacer() }
              Text(msg.content)
                .padding()
                .background(msg.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(8)
              if msg.role == .user { Spacer() }
            }
            .id(msg.id)
          }
        }
        .onChange(of: chatVM.messages.count) { _ in
          proxy.scrollTo(chatVM.messages.last?.id, anchor: .bottom)
        }
      }
      HStack {
        TextField("Ask me anything…", text: $chatVM.input)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        Button("Send") {
          Task { await chatVM.send() }
        }
      }
      .padding()
    }
  }
}
