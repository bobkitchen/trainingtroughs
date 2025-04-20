//
//  ChatView.swift
//  TrainingTroughs
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel

    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages) { msg in
                    Text(msg.content)
                        .frame(maxWidth: .infinity, alignment: msg.role == .user ? .trailing : .leading)
                        .padding(.vertical, 4)
                }
            }
            .onChange(of: viewModel.input) { _ in }   // silence SwiftUI‑4 deprecation

            HStack {
                TextField("Ask something…", text: $viewModel.input)
                    .textFieldStyle(.roundedBorder)
                Button("Send") {
                    Task { await viewModel.send() }
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
    }
}
