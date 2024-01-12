//
//  OpenAICompletionsModel.swift
//  ChatGPT-swittUI-IL
//
//  Created by Иван Легенький on 12.01.2024.
//

import Foundation


struct OpenAICompletionsModel: Encodable {
    let model: String
    let messages: [AIMessage]
    let temperature: Double
}

struct AIMessage: Codable {
    let role, content: String
}


struct OpenAICompletionsResponseModel: Codable {
    let id, object: String
    let created: Int
    let model: String
    let usage: Usage
    let choices: [Choice]
}

struct Choice: Codable {
    let message: AIMessage
    let logprobs: JSONNull?
    let finishReason: String
    let index: Int

    enum CodingKeys: String, CodingKey {
        case message, logprobs
        case finishReason = "finish_reason"
        case index
    }
}

struct Usage: Codable {
    let promptTokens, completionTokens, totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

struct OpenAICompletionChoices: Decodable {
    let text: String
}

