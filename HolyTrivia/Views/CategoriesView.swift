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
                    QuestionPickerView(numberOfQuestions: $numberOfQuestions)
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
