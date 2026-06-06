import Foundation

@Observable
final class AuthViewModel {
    private let authService = AuthService()
    
    var email = ""
    var password = ""
    var fullName = ""
    var confirmPassword = ""
    var errorMessage = ""
    var isLoading = false
    
    var isLoggedIn: Bool { authService.isLoggedIn }
    
    func signIn() async {
        isLoading = true
        await authService.signIn(email: email, password: password)
        errorMessage = authService.errorMessage
        isLoading = false
    }
    
    func register() async {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        isLoading = true
        await authService.register(email: email, password: password, fullName: fullName)
        errorMessage = authService.errorMessage
        isLoading = false
    }
    
    func signOut() {
        authService.signOut()
    }
}
