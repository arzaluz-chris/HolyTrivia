// OptionButtonView.swift
import SwiftUI

struct OptionButtonView: View {
    var text: String
    var index: Int
    var selectedIndex: Int?
    var correctIndex: Int?
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if selectedIndex == nil {
                onTap()
            }
        }) {
            HStack {
                Text("\(["A", "B", "C", "D"][index])")
                    .font(.headline)
                    .foregroundColor(backgroundColor)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(foregroundColor)
                    )
                
                Text(text)
                    .font(.body)
                    .foregroundColor(foregroundColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let selected = selectedIndex, let correct = correctIndex {
                    if selected == index {
                        Image(systemName: selected == correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(selected == correct ? .green : .red)
                    } else if index == correct {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
            )
        }
        .disabled(selectedIndex != nil)
    }
    
    // Color de fondo basado en el estado
    var backgroundColor: Color {
        if let selected = selectedIndex, let correct = correctIndex {
            if selected == index {
                return selected == correct ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
            } else if index == correct {
                return Color.green.opacity(0.2)
            }
        }
        
        return selectedIndex == index ? Color("PrimaryColor").opacity(0.2) : Color.white
    }
    
    // Color de texto basado en el estado
    var foregroundColor: Color {
        if let selected = selectedIndex, let correct = correctIndex {
            if selected == index {
                return selected == correct ? .green : .red
            } else if index == correct {
                return .green
            }
        }
        
        return selectedIndex == index ? Color("PrimaryColor") : Color("PrimaryTextColor")
    }
}
