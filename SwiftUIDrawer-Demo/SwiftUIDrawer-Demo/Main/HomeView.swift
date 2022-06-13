//
//  MainView1.swift
//  SwiftDrawer_Example
//
//  Created by Parag Patill on 10/06/22.
//  Copyright © 2022 PTech. All rights reserved.
//

import SwiftUI
import SwiftUIDrawer

struct HomeView : View {
    @EnvironmentObject public var control: DrawerControl

    var body: some View {
        NavigationView {
            Text("Home View in Main")
                .navigationBarTitle(Text("Home"), displayMode: .automatic)
                .navigationBarItems(leading: Image("menu").onTapGesture(perform: {
                    self.control.show(type: control.leftSliderType, isShow: true)
                }), trailing: Text("right").onTapGesture {
                    self.control.show(type: control.rightSliderType, isShow: true)
                })
        }
        .foregroundColor(Color.red)
    }
}

#if DEBUG
struct HomeView_Previews : PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
