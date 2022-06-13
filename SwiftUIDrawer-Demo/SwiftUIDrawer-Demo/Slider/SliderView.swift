//
//  SliderView.swift
//  SwiftDrawer_Example
//
//  Created by Parag Patill on 10/06/22.
//  Copyright © 2022 PTech. All rights reserved.
//

import SwiftUI
import SwiftUIDrawer

struct SliderView : View, SliderProtocol {
    @EnvironmentObject public var drawerControl: DrawerControl
    let type: SliderType
    init(type: SliderType) {
        self.type = type
    }
    var body: some View {
        
        List {
            HeaderView()
            SliderCell(imgName: "home", title: "Home").onTapGesture {
                self.drawerControl.setMain(view: HomeView())
                //self.drawerControl.show(type: type, isShow: false)
            }.onAppear {
                    
            }
            
            SliderCell(imgName: "account", title: "Account").onTapGesture {
                self.drawerControl.setMain(view: AccountView())
                //self.drawerControl.show(type: type, isShow: false)
            }
        }
    }
}


#if DEBUG
struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        SliderView(type: .leftFront)
    }
}
#endif
