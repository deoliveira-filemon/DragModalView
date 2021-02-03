//
//  ContentView.swift
//  DragModalViewTutorial
//
//  Created by Filemon Oliveira on 03/02/2021.
//

import SwiftUI

struct ContentView: View {

    @State var isShown = false

    var body: some View {
        ZStack {
            Button(action: {
                isShown.toggle()
            }, label: {
                Text("Show Modal")
            })
            DragModalView(isShown: $isShown, height: .fullscreen) {
                Text("Here goes my content view.")
            }
        }
        .background(Color(#colorLiteral(red: 0.2186107635, green: 0.7709638476, blue: 0.7870952487, alpha: 1)))
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
