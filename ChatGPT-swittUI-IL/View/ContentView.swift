import SwiftUI
import Combine

struct ContentView: View {
    @State private var chatMessages: [ChatMessage] = []
    @State private var messageText: String = ""
    @State private var isLoading: Bool = false
    
    private let openAIViewModel = OpenAIViewModel()
    
    @State private var cancellables: Set<AnyCancellable> = []

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
            messageInputView()
            sendButton()
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
                .messageBubbleStyle(isGPT: isGPT)
            } else {
                Text(message.content)
                    .messageBubbleStyle(isGPT: isGPT)
            }
           
            if isGPT { Spacer() }
        }
    }
    
    func messageInputView() -> some View {
        TextField("Enter a message", text: $messageText)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    
    func sendButton() -> some View {
        let isDisabled = isLoading || messageText == ""
        return Button(action: sendMSG) {
            Text("Send")
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 10)
                .background(isDisabled ? Color.gray : Color.green)
                .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
    
    func sendMSG() {
        withAnimation {
            isLoading = true
        }
        let myMSG = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .myself)
        let AIMessage = [AIMessage(role: "user", content: messageText)]
        
        chatMessages.append(myMSG)
        
        openAIViewModel.sendMessage(message: AIMessage)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished successful")
                case .failure(let error):
                    print("ERROR \(error)")
                }
            }, receiveValue: { response in
                print("MY RESP \(response)")
                guard let textResponse = response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
                let gptMSG = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .chatGpt)

                chatMessages.append(gptMSG)
                let animationDuration = Double(textResponse.count) * 0.07
                         
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    isLoading = false
                }
            })
            .store(in: &cancellables)
        
        messageText = ""
    }
}

extension View {
    func messageBubbleStyle(isGPT: Bool) -> some View {
        self.padding(10)
            .foregroundColor(isGPT ? Color.black : Color.white)
            .background(isGPT ? Color.gray.opacity(0.1) : Color.blue)
            .cornerRadius(16)
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
