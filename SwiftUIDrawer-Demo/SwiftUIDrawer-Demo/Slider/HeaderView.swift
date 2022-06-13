//
//  HeaderView.swift
//  SwiftDrawer_Example
//
//  Created by Parag Patill on 10/06/22.
//  Copyright © 2022 PTech. All rights reserved.
//

import SwiftUI

struct HeaderView : View {
    var body: some View {
        HStack {
            Image("user").resizable().frame(width: 50, height: 50, alignment: .trailing)
            VStack(alignment: .leading) {
                Text("Millman")
                Text("mm@gmail.com")
            }.foregroundColor(.init("titleColor"))
        }
    }
}

#if DEBUG
struct HeaderView_Previews : PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
#endif
