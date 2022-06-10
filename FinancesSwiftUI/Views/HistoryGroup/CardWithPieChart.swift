//
//  CardWithPieChart.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 6/9/22.
//

import SwiftUI

struct CardWithPieChart: View {
    var body: some View {
        ZStack {
            Text("5/04/22 - 5/31/22")
                .bold()
                .font(.title2)
                .padding(.leading, Constants.Views.SCREEN_WIDTH * 0.05)
                .padding(.top, Constants.Views.SCREEN_HEIGHT * 0.4)
                .foregroundColor(Color.gray)
            PieChartView(values: [1300, 500, 300], names: ["Rent", "Transport", "Education"], formatter: {value in String(format: "$%.2f", value)})
                .frame(width: Constants.Views.SCREEN_WIDTH * 0.8, height: Constants.Views.SCREEN_HEIGHT * 0.4, alignment: .center)
                .padding(.bottom, Constants.Views.SCREEN_HEIGHT * 0.1)
            
            RoundedRectangle(cornerRadius: 10.0)
                .strokeBorder(Color.gray, lineWidth: 1.5)
                .frame(width: Constants.Views.SCREEN_WIDTH * 0.9, height: Constants.Views.SCREEN_HEIGHT * 0.5)
        }.frame(width: Constants.Views.SCREEN_WIDTH * 0.9, height: Constants.Views.SCREEN_HEIGHT * 0.5, alignment: .center)
    }
}

struct CardWithPieChart_Previews: PreviewProvider {
    static var previews: some View {
        CardWithPieChart()
    }
}
