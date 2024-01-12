//
//  TypeWritterEffect.swift
//  ChatGPT-swittUI-IL
//
//  Created by Иван Легенький on 12.01.2024.
//

import SwiftUI

import SwiftUI
import Combine

struct TypeWriterView: View {
    private let text: String
    private let speed: TimeInterval
    @Binding var isStarted: Bool
    @State private var textArray: String = ""
    @State private var processedIDs: Set<String> = Set()
    @State private var cancellables: Set<AnyCancellable> = []  // Доданий рядок

    init(_ text: String, speed: TimeInterval = 0.1, isStarted: Binding<Bool>) {
        self.text = text
        self.speed = speed
        self._isStarted = isStarted
    }

    var body: some View {
        Text(textArray)
            .onAppear {
                if isStarted {
                    startAnimate()
                }
            }
    }

    private func startAnimate() {
        guard !processedIDs.contains(text) else {
            return
        }

        let publisher = Timer.publish(every: speed, on: .main, in: .common)
            .autoconnect()
            .prefix(while: { _ in textArray.count < text.count })

        publisher
            .sink { _ in
                let currentIndex = textArray.endIndex
                if currentIndex < text.endIndex {
                    textArray += String(text[currentIndex])
                } else {
                    processedIDs.insert(text)
                }
            }
            .store(in: &cancellables)
    }
}


