//
//  ContentView.swift
//  ChatGPT-swittUI-IL
//
//  Created by Иван Легенький on 12.01.2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var chatMessages: [ChatMessage] = []
    @State var messageText: String = ""
    @State private var isLoading: Bool = false
    
    private let openAIViewModel = OpenAIViewModel()
    
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(chatMessages, id: \.id) { message in
                   messageView(message: message)
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                }
            }
        }
        HStack {
            TextField("Enter a message", text: $messageText)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            Button {
                sendMSG()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
    
    func messageView(message: ChatMessage) -> some View {
        let isGPT = message.sender == .chatGpt
        return HStack {
            if !isGPT { Spacer() }
          
            if isGPT {
                TypeWriterView(
                    message.content,
                    speed: 0.07,
                    isStarted: $isLoading
                )
                .padding(10)
                .foregroundColor(.black)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            } else {
                Text(message.content)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
           
         
            if isGPT { Spacer() }
        }
    }
    
    func sendMSG() {
        withAnimation {
            isLoading = true
        }
        let myMSG = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .myself)

        let AIMessage = [AIMessage(role: "user", content: messageText)]
        
     
        chatMessages.append(myMSG)
        
       
        openAIViewModel.sendMessage(message: AIMessage).sink { completion in
            switch completion {
            case .finished:
                print("Finished successful")
            case .failure(let error):
                print("ERRROR \(error)")
            }
        } receiveValue: { response in
            print("MY RESP \(response)")
            guard let textResponse = response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            let gptMSG = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .chatGpt)
            
            chatMessages.append(gptMSG)
        }
        .store(in: &cancellables)
        messageText = ""
    }
}

struct ChatMessage {
    let id: String
    let content: String
    let dateCreated: Date
    let sender: MessageSender
}

enum MessageSender {
    case myself
    case chatGpt
}

#Preview {
    ContentView()
}
