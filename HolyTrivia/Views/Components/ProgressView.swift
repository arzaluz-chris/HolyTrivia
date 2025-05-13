// ProgressView.swift
import SwiftUI

struct CustomProgressView: View {
    var value: Double
    var color: Color = Color("PrimaryColor")
    var height: CGFloat = 8
    var showPercentage: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo de la barra
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(height / 2)
                    
                    // Barra de progreso
                    Rectangle()
                        .fill(color)
                        .cornerRadius(height / 2)
                        .frame(width: geometry.size.width * CGFloat(min(max(value, 0), 1)))
                }
            }
            .frame(height: height)
            
            if showPercentage {
                HStack {
                    Spacer()
                    Text("\(Int(value * 100))%")
                        .font(.caption)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
            }
        }
    }
}

struct CustomProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CustomProgressView(value: 0.25, color: .blue)
            CustomProgressView(value: 0.5, color: .green)
            CustomProgressView(value: 0.75, color: .orange)
            CustomProgressView(value: 1.0, color: .red, showPercentage: true)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
