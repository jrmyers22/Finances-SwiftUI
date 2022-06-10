//
//  HistoryMainView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 6/9/22.
//

import SwiftUI

struct HistoryMainView: View {
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(0..<5) {_ in
                        CardWithPieChart()
                    }
                }.padding()
            }
            .navigationTitle(Text("History"))
        }
    }
}

struct HistoryMainView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryMainView()
    }
}
