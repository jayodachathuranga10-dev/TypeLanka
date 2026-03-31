import SwiftUI

struct ContentView: View {
    @State private var textInput = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "keyboard.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.blue)
                
                Text("TypeLanka Keyboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("""
                1. Go to Settings -> General -> Keyboard -> Keyboards -> Add New Keyboard
                2. Select 'TypeLanka'
                3. Tap 'TypeLanka' again and allow Full Access for custom themes and smart replies to work perfectly.
                """)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                TextField("Test your keyboard here...", text: $textInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Setup")
            .navigationBarHidden(true)
        }
    }
}
