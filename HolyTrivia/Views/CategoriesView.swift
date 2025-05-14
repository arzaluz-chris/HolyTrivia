// CategoriesView.swift
import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @EnvironmentObject var statsViewModel: StatsViewModel
    @State private var numberOfQuestions = 10
    @State private var isShowingQuestionPicker = false
    @State private var showNoCategoryAlert = false
    @State private var emptyCategory: String = ""
    
    // Nuevo enfoque: en lugar de una presentación modal, usamos un estado para controlar qué vista mostramos
    @State private var activeView: ActiveView = .categories
    @State private var selectedCategory: Category?
    
    // Enumeración para controlar qué vista está activa
    enum ActiveView {
        case categories
        case quiz
    }
    
    var body: some View {
        // Usamos un Group con un switch para mostrar diferentes vistas
        Group {
            switch activeView {
            case .categories:
                categoriesListView
            case .quiz:
                if let category = selectedCategory {
                    DirectQuizView(
                        category: category,
                        questionsCount: numberOfQuestions,
                        onDismiss: { activeView = .categories }
                    )
                } else {
                    // Fallback por si no hay categoría seleccionada
                    Text("Error: No se seleccionó una categoría")
                        .onAppear {
                            activeView = .categories
                        }
                }
            }
        }
        .onAppear {
            // Pre-cargar categorías y preguntas de forma forzada
            forcePreloadData()
        }
    }
    
    // Vista de la lista de categorías
    var categoriesListView: some View {
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
                                        
                                        // Verificar si hay preguntas en esta categoría
                                        let hasQuestions = PersistenceManager.shared.categoryHasQuestions(category.id)
                                        if hasQuestions {
                                            selectedCategory = category
                                            
                                            // Forzar lectura de preguntas antes de navegar
                                            let questions = PersistenceManager.shared.loadQuestionsFor(categoryId: category.id)
                                            print("Preguntas cargadas para \(category.name): \(questions.count)")
                                            
                                            if !questions.isEmpty {
                                                activeView = .quiz
                                            } else {
                                                emptyCategory = category.name
                                                showNoCategoryAlert = true
                                            }
                                        } else {
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
                .alert(isPresented: $showNoCategoryAlert) {
                    Alert(
                        title: Text("Categoría sin preguntas"),
                        message: Text("La categoría '\(emptyCategory)' aún no tiene preguntas disponibles. Por favor, selecciona otra categoría."),
                        dismissButton: .default(Text("Entendido"))
                    )
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
    
    // Función para pre-cargar datos de forma forzada
    private func forcePreloadData() {
        print("Forzando carga de datos...")
        
        // Forzar carga de categorías
        let categories = PersistenceManager.shared.loadCategories()
        print("Categorías precargadas: \(categories.count)")
        
        // Forzar carga de todas las preguntas
        let questions = PersistenceManager.shared.loadQuestions()
        print("Preguntas precargadas: \(questions.count)")
        
        // Actualizar ViewModel
        categoriesViewModel.loadCategories()
        categoriesViewModel.checkCategoriesWithQuestions()
    }
}
