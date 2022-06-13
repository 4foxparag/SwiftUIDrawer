//
//  MainView2.swift
//  SwiftDrawer_Example
//
//  Created by Parag Patill on 10/06/22.
//  Copyright © 2022 PTech. All rights reserved.
//

import SwiftUI
import SwiftUIDrawer

struct AccountView : View {
    @EnvironmentObject public var control: DrawerControl
    var body: some View {
        NavigationView {
            VStack {
                Image("user").padding(.top, 10)
                Divider()
                Text("millman")
                Text("mm@gmail.com")
                Spacer()
            }
            .navigationBarItems(leading: Image("menu").onTapGesture {
                self.control.show(type: control.leftSliderType, isShow: true)
            }, trailing: Text("right").onTapGesture {
                self.control.show(type: control.rightSliderType, isShow: true)
            })
            .navigationBarTitle(Text("Account"), displayMode: .inline)
        }
        .foregroundColor(Color.red)
    }
}

#if DEBUG
struct AccountView_Previews : PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
#endif
