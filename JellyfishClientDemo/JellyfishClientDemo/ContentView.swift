//
//  ContentView.swift
//  JellyfishClientDemo
//
//  Created by Karol Sygiet on 26/05/2023.
//

import SwiftUI

struct ContentView: View {
    var contentViewController: ContentViewController
    init() {
        self.contentViewController = ContentViewController()
    }

    func connectButt() {
        contentViewController.connect()
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Connect", action: connectButt)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
