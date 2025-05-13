// TimerBarView.swift
import SwiftUI

struct TimerBarView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 4) {
            // Barra de progreso del temporizador
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo de la barra
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    // Barra de progreso
                    Rectangle()
                        .fill(progressColor)
                        .cornerRadius(10)
                        .frame(width: geometry.size.width * CGFloat(timerManager.progress))
                }
            }
            .frame(height: 8)
            
            // Tiempo restante en texto
            HStack {
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(timerManager.progress < 0.3 ? .red : Color("SecondaryTextColor"))
                    
                    Text(String(format: "%.0f", timerManager.timeRemaining))
                        .font(.caption)
                        .foregroundColor(timerManager.progress < 0.3 ? .red : Color("SecondaryTextColor"))
                        .fontWeight(timerManager.progress < 0.3 ? .bold : .regular)
                }
            }
        }
    }
    
    // Color de la barra de progreso basado en el tiempo restante
    private var progressColor: Color {
        switch timerManager.progress {
        case 0.7...1.0:
            return .green
        case 0.3..<0.7:
            return .orange
        default:
            return .red
        }
    }
}

struct TimerBarView_Previews: PreviewProvider {
    static var previews: some View {
        TimerBarView(timerManager: TimerManager(timeInterval: 15))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
