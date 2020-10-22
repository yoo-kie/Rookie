//
//  RookieEntryView.swift
//  Rookie
//
//  Created by 유연주 on 2020/10/21.
//  Copyright © 2020 yookie. All rights reserved.
//

import SwiftUI

struct RookieEntryView: View {
    let entry: RookieEntry
    
    var body: some View {
        if let groupUserDefaults = UserDefaults(suiteName: "group.com.yookie.rookie") {
            let doneCount = groupUserDefaults.integer(forKey: "doneCount")
            let totalCount = groupUserDefaults.integer(forKey: "totalCount")
            
            VStack {
                Spacer()
                
                Image(groupUserDefaults.string(forKey: "todayProgressImage")!).resizable()
                    .frame(alignment: .center)
                    .aspectRatio(contentMode: .fit)
                
                if totalCount == 0 {
                    Text("하루를 시작해보세요:)")
                        .font(.system(size: 10))
                        .bold()
                } else {
                    HStack {
                        Text("오늘의 달성률")
                            .font(.system(size: 10))
                            .bold()
                        
                        if doneCount != 0 && doneCount == totalCount {
                            Text("Finish-!")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        } else {
                            Text("\(doneCount) / \(totalCount)")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct RookieEntryView_Previews: PreviewProvider {
    static var previews: some View {
        RookieEntryView(entry: RookieEntry(date: Date()))
    }
}
