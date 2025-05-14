// CategoriesView.swift con solución para el problema de inicialización
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
    
    // Nuevo estado para controlar si los datos están listos
    @State private var dataIsReady = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                Color("BackgroundColor").ignoresSafeArea()
                
                // Vista de carga inicial hasta que los datos estén listos
                if !dataIsReady {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Preparando datos...")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryTextColor"))
                    }
                } else {
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
                                            
                                            // Verificar explícitamente si la categoría tiene preguntas en PersistenceManager
                                            let hasQuestions = PersistenceManager.shared.categoryHasQuestions(category.id)
                                            print("¿Tiene preguntas disponibles? \(hasQuestions)")
                                            
                                            if hasQuestions {
                                                selectedCategory = category
                                                
                                                // Pequeño retraso para asegurar que todo esté listo
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    showQuiz = true
                                                }
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
                }
            }
            .sheet(isPresented: $isShowingQuestionPicker) {
                QuestionPickerView(numberOfQuestions: $numberOfQuestions)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .sheet(isPresented: $showQuiz) {
                if let category = selectedCategory {
                    SimpleQuizView(category: category, questionsCount: numberOfQuestions)
                }
            }
            .alert(isPresented: $showNoCategoryAlert) {
                Alert(
                    title: Text("Categoría sin preguntas"),
                    message: Text("La categoría '\(emptyCategory)' aún no tiene preguntas disponibles. Por favor, selecciona otra categoría."),
                    dismissButton: .default(Text("Entendido"))
                )
            }
            .onAppear {
                // Al aparecer la vista, forzamos la carga completa de los datos
                // y esperamos un tiempo prudencial antes de permitir interacción
                preloadData()
            }
        }
    }
    
    // Nueva función para precargar datos y asegurar que todo esté listo
    private func preloadData() {
        print("Precargando datos para asegurar inicialización completa...")
        
        // Reiniciar estado
        dataIsReady = false
        
        // Forzar carga completa de categorías y preguntas
        PersistenceManager.shared.loadCategories()
        PersistenceManager.shared.loadQuestions()
        categoriesViewModel.loadCategories()
        categoriesViewModel.checkCategoriesWithQuestions()
        
        // Esperar un tiempo prudencial para asegurar que todo esté cargado
        // antes de permitir interacción
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("Datos precargados completamente, permitiendo interacción")
            dataIsReady = true
        }
    }
}
