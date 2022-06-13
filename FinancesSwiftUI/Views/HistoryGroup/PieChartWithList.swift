import SwiftUI

@available(OSX 10.15, *)
public struct PieChartWithList: View {
    @Environment(\.presentationMode) var presentationMode
    
    public let values: [Double]
    public let names: [String]
    public let formatter: (Double) -> String
    
    public var colors: [Color]
    public var backgroundColor: Color
    
    public var widthFraction: CGFloat
    public var innerRadiusFraction: CGFloat
    
    @State private var activeIndex: Int = -1
    
    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), text: String(format: "%.0f%%", value * 100 / sum), color: self.colors[i]))
            endDeg += degrees
        }
        return tempSlices
    }
    
    public init(values:[Double], names: [String], formatter: @escaping (Double) -> String, colors: [Color] = [Color("FoodCategoryColor"), Color("DrinkCategoryColor"), Color("GroceryCategoryColor"), Color("TransportationCategoryColor"), Color("MiscCategoryColor")], backgroundColor: Color = Color.white, widthFraction: CGFloat = 0.75, innerRadiusFraction: CGFloat = 0.60){
        self.values = values
        self.names = names
        self.formatter = formatter
        
        self.colors = colors
        self.backgroundColor = backgroundColor
        self.widthFraction = widthFraction
        self.innerRadiusFraction = innerRadiusFraction
    }
    
    public var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ZStack{
                        ForEach(0..<self.values.count){ i in
                            PieSlice(pieSliceData: self.slices[i])
                        }
                        .frame(width: widthFraction * Constants.Views.SCREEN_WIDTH, height: widthFraction * Constants.Views.SCREEN_WIDTH)
                        Circle()
                            .fill(self.backgroundColor)
                            .frame(width: widthFraction * Constants.Views.SCREEN_WIDTH * innerRadiusFraction, height: widthFraction * Constants.Views.SCREEN_WIDTH * innerRadiusFraction)
                        
                        VStack {
                            Text(self.activeIndex == -1 ? "Total" : names[self.activeIndex])
                                .font(.title)
                                .foregroundColor(Color.gray)
                            Text(self.formatter(self.activeIndex == -1 ? values.reduce(0, +) : values[self.activeIndex]))
                                .font(.title)
                        }
                        
                    }

                    HStack {
                        // TODO: Replace this with the correct date (prob pass it into this view)
                        Text("05/01/22 - 5/31/22")
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                    PieChartRows(colors: self.colors, names: self.names, values: self.values.map { self.formatter($0) }, percents: self.values.map { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) })
                }
                .background(self.backgroundColor)
                .foregroundColor(Color.black)
            }.padding()
        }
    }
}

@available(OSX 10.15, *)
struct PieChartRows: View {
    var colors: [Color]
    var names: [String]
    var values: [String]
    var percents: [String]
    
    var body: some View {
        VStack {
            ForEach(0..<self.values.count){ i in
                Button (action: {
                    // TODO: Expand list
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .strokeBorder(self.colors[i], lineWidth: 2)
                            .frame(width: Constants.Views.SCREEN_WIDTH * 0.95,
                                   height: Constants.Views.SCREEN_HEIGHT * 0.075)
                        HStack {
                            RoundedRectangle(cornerRadius: 5.0)
                                .fill(self.colors[i])
                                .frame(width: 20, height: 20)
                            Text(self.names[i])
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(self.values[i])
                                Text(self.percents[i])
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

@available(OSX 10.15.0, *)
struct PieChartWithList_Previews: PreviewProvider {
    static var previews: some View {
        PieChartWithList(values: [1300, 500, 300, 100, 200], names: ["Food", "Drink", "Grocery", "Transportation", "Misc"], formatter: {value in String(format: "$%.2f", value)})
    }
}

