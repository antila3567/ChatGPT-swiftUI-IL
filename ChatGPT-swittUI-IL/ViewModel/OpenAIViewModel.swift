//
//  OpenAIViewModel.swift
//  ChatGPT-swittUI-IL
//
//  Created by Иван Легенький on 12.01.2024.
//


import Combine
import Foundation
import Alamofire

class OpenAIViewModel {
    let baseUrl = "https://api.openai.com/v1/chat/completions"

    
    func sendMessage(message: [AIMessage]) -> AnyPublisher<OpenAICompletionsResponseModel, Error> {
        let body = OpenAICompletionsModel(model: "gpt-3.5-turbo", messages: message, temperature: 0.5)
        
        let baseHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIAPIKey)"
        ]
        
        return Future {[weak self] promise in
            guard let self = self else { return }
            AF.request(
                self.baseUrl,
                method: .post,
                parameters: body,
                encoder: .json,
                headers: baseHeaders ).responseDecodable(of: OpenAICompletionsResponseModel.self) { response in
                    switch response.result {
                    case .success(let result):
                        promise(.success(result))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}


