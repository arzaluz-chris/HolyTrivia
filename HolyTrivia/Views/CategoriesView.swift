// CategoriesView.swift
import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @EnvironmentObject var statsViewModel: StatsViewModel
    @State private var selectedCategory: Category?
    @State private var showQuiz = false
    @State private var numberOfQuestions = 10
    @State private var isShowingQuestionPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                Color("BackgroundColor").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cabecera
                    HStack {
                        Text("Choose a Category")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("PrimaryTextColor"))
                        
                        Spacer()
                        
                        Button(action: {
                            isShowingQuestionPicker = true
                        }) {
                            HStack {
                                Text("\(numberOfQuestions)")
                                    .foregroundColor(Color("PrimaryColor"))
                                    .fontWeight(.bold)
                                
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(Color("PrimaryColor"))
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("PrimaryColor").opacity(0.1))
                            )
                        }
                    }
                    .padding()
                    
                    if categoriesViewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    } else if let errorMessage = categoriesViewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text(errorMessage)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                categoriesViewModel.loadCategories()
                            }) {
                                Text("Try Again")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("PrimaryColor"))
                                    )
                            }
                        }
                        .padding()
                        Spacer()
                    } else {
                        // Lista de categorías
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                                ForEach(categoriesViewModel.categories) { category in
                                    CategoryCardView(
                                        category: category,
                                        stats: categoriesViewModel.getStatsFor(categoryId: category.id)
                                    )
                                    .onTapGesture {
                                        selectedCategory = category
                                        showQuiz = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .sheet(isPresented: $isShowingQuestionPicker) {
                    QuestionNumberPickerView(numberOfQuestions: $numberOfQuestions)
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                .fullScreenCover(isPresented: $showQuiz) {
                    if let category = selectedCategory {
                        QuizView(
                            quizViewModel: QuizViewModel(
                                category: category,
                                questionsCount: numberOfQuestions
                            )
                        )
                    }
                }
            }
        }
    }
}

struct CategoryCardView: View {
    var category: Category
    var stats: CategoryStat?
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            LinearGradient(
                gradient: Gradient(colors: [category.color, category.color.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            
            HStack(spacing: 16) {
                // Ícono
                Image(systemName: category.systemIconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Titulo
                    Text(category.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Progreso
                    if let stats = stats {
                        ProgressView(value: stats.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .frame(height: 8)
                        
                        HStack {
                            Text("\(stats.answeredQuestions) of \(stats.totalQuestions) questions")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text("\(Int(stats.accuracy * 100))% correct")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("Not played yet")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.vertical, 16)
                
                Spacer()
                
                // Flecha para indicar que es seleccionable
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 100)
    }
}

struct QuestionNumberPickerView: View {
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

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .environmentObject(CategoriesViewModel())
    }
}
