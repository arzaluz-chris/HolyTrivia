// CategoriesView.swift
import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @EnvironmentObject var statsViewModel: StatsViewModel
    @State private var selectedCategory: Category?
    @State private var showQuiz = false
    @State private var numberOfQuestions = 10
    @State private var isShowingQuestionPicker = false
    @State private var showNoCategoryAlert = false
    @State private var emptyCategory: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                Color("BackgroundColor").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cabecera
                    HStack {
                        Text("Elige una Categoría")
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
                                Text("Intentar de nuevo")
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
                                        stats: categoriesViewModel.getStatsFor(categoryId: category.id),
                                        hasQuestions: categoriesViewModel.categoryHasQuestions(categoryId: category.id)
                                    )
                                    .onTapGesture {
                                        print("Categoría seleccionada: \(category.id) - \(category.name)")
                                        
                                        // Verificar si la categoría tiene preguntas antes de continuar
                                        if categoriesViewModel.categoryHasQuestions(categoryId: category.id) {
                                            selectedCategory = category
                                            showQuiz = true
                                        } else {
                                            // Mostrar alerta de categoría sin preguntas
                                            emptyCategory = category.name
                                            showNoCategoryAlert = true
                                        }
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
                            category: category,
                            questionsCount: numberOfQuestions
                        )
                    }
                }
                .alert(isPresented: $showNoCategoryAlert) {
                    Alert(
                        title: Text("Categoría sin preguntas"),
                        message: Text("La categoría '\(emptyCategory)' aún no tiene preguntas disponibles. Por favor, selecciona otra categoría."),
                        dismissButton: .default(Text("Entendido"))
                    )
                }
            }
        }
        .onAppear {
            // Cargar categorías y verificar cuáles tienen preguntas
            categoriesViewModel.checkCategoriesWithQuestions()
        }
    }
}
