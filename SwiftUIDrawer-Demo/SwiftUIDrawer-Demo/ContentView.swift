//
//  ContentView.swift
//  SwiftUIDrawer-Demo
//
//  Created by Parag Patill on 10/06/22.
//

import SwiftUI
import SwiftUIDrawer

struct ContentView: View {
    var body: some View {
        Drawer()
            .setSlider(view: SliderView(type: .leftFront), shadowRadius: 0)
            .setMain(view: HomeView())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
