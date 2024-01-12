//
//  TypeWritterEffect.swift
//  ChatGPT-swittUI-IL
//
//  Created by Иван Легенький on 12.01.2024.
//

import SwiftUI

struct TypeWriterView: View {

    private let text: String
    private let speed: TimeInterval
    @Binding var isStarted: Bool
    @State private var textArray: String = ""
    @State private var processedIDs: Set<String> = Set()

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
           DispatchQueue.global().async {
               guard !processedIDs.contains(text) else {
                   return
               }

               for char in self.text {
                   Thread.sleep(forTimeInterval: self.speed)
                   DispatchQueue.main.async {
                       self.textArray += char.description
                   }
               }

               DispatchQueue.main.async {
                   self.processedIDs.insert(text)
               }
           }
       }

}
