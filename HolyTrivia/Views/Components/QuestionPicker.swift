// QuestionPickerView.swift
import SwiftUI

struct QuestionPickerView: View {
    @Binding var numberOfQuestions: Int
    @Environment(\.presentationMode) var presentationMode
    
    let options = [5, 10, 15, 20]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How many questions do you want to answer?")
                    .font(.headline)
                    .foregroundColor(Color("PrimaryTextColor"))
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                ForEach(options, id: \.self) { number in
                    Button(action: {
                        numberOfQuestions = number
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("\(number) questions")
                                .font(.title3)
                                .foregroundColor(number == numberOfQuestions ? .white : Color("PrimaryTextColor"))
                            
                            Spacer()
                            
                            if number == numberOfQuestions {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(number == numberOfQuestions ? Color("PrimaryColor") : Color.gray.opacity(0.1))
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Quiz Length", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
