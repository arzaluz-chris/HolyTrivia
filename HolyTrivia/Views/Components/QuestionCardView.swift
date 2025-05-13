// QuestionCardView.swift
import SwiftUI

struct QuestionCardView: View {
    var question: Question
    var selectedAnswerIndex: Int?
    var showFeedback: Bool
    var onOptionSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Imagen de la pregunta (si existe)
            if let imageRef = question.imageRef {
                Image(imageRef)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
            } else {
                // Imagen placeholder
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("PrimaryColor").opacity(0.7))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("PrimaryColor").opacity(0.1))
                    )
            }
            
            // Texto de la pregunta
            Text(question.text)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Opciones de respuesta
            VStack(spacing: 12) {
                ForEach(0..<question.options.count, id: \.self) { index in
                    OptionButtonView(
                        text: question.options[index],
                        index: index,
                        selectedIndex: selectedAnswerIndex,
                        correctIndex: showFeedback ? question.correctOption : nil,
                        onTap: {
                            onOptionSelected(index)
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            // Explicación (mostrada cuando se revela la respuesta correcta)
            if showFeedback {
                Text(question.explanation)
                    .font(.subheadline)
                    .foregroundColor(Color("SecondaryTextColor"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .padding(.horizontal)
                    .transition(.opacity)
                    .animation(.easeIn, value: showFeedback)
            }
        }
    }
}

struct QuestionCardView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionCardView(
            question: Question(
                id: "q001",
                text: "¿Quién construyó el arca?",
                options: ["Noé", "Moisés", "Abraham", "David"],
                correctOption: 0,
                explanation: "Noé construyó el arca según las instrucciones de Dios antes del gran diluvio.",
                imageRef: nil,
                category: "old_testament",
                difficulty: 1
            ),
            selectedAnswerIndex: nil,
            showFeedback: false,
            onOptionSelected: { _ in }
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color("BackgroundColor"))
    }
}
