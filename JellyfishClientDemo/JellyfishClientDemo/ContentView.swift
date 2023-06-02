//
//  ContentView.swift
//  JellyfishClientDemo
//
//  Created by Karol Sygiet on 26/05/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var contentViewController: ContentViewController

    init() {
        self.contentViewController = ContentViewController()
        print(contentViewController.participants)

    }

    @ViewBuilder
    func participantsVideoViews(_ participantVideos: [ParticipantVideo], size: CGFloat) -> some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(Array(stride(from: 0, to: participantVideos.count, by: 2)), id: \.self) { index in
                    HStack {
                        Spacer()
                        ParticipantVideoView(participantVideos[index], height: size, width: size)
                        Spacer()

                        if index + 1 < participantVideos.count {
                            ParticipantVideoView(participantVideos[index + 1], height: size, width: size)
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }

    func connectButt() {
        contentViewController.connect()
    }

    func disconnect() {
        contentViewController.disconnect()
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Connect", action: connectButt)
            Button("Disconnect", action: disconnect)
            participantsVideoViews(contentViewController.participantVideos, size: 100)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
