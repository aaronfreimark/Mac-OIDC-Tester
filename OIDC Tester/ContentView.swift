//
//  ContentView.swift
//  OIDC Tester
//
//  Created by Aaron Freimark on 8/26/25.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @AppStorage("issuerURL") private var issuerURL: String = ""
    @AppStorage("clientID") private var clientID: String = ""
    @AppStorage("clientSecret") private var clientSecret: String = ""
    @AppStorage("acrValue") private var acrValue: String = "None"
    @AppStorage("loginHint") private var loginHint: String = ""
    @AppStorage("promptLogin") private var promptLogin: Bool = false
    private let acrOptions = ["None", "SSO (com:imprivata:oidc:epic:sso)", "EPCS (com:imprivata:oidc:epic:cw:epcs)"]
    private let defaultRedirectURI = "ImprivataOIDC://callback"
    @AppStorage("scopes") private var scopes: String = "openid profile email"
    @AppStorage("responseType") private var responseType: String = "code"
    @AppStorage("extraParams") private var extraParams: String = ""

    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var progressMessage: String? = nil
    @State private var tokenMessage: String? = nil
    @State private var logMessages: [String] = []
    @State private var selectedTab: Int = 0
    @State private var isAuthenticating: Bool = false
    @State private var webAuthSession: ASWebAuthenticationSession?
    @State private var presentationContextProvider: PresentationContextProvider?
    @State private var tokenEndpoint: String? = nil

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 0.98, green: 0.98, blue: 1.0, opacity: 1.0),
                    Color(.sRGB, red: 0.95, green: 0.96, blue: 0.98, opacity: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Config Tab
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        Text("Configuration")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                        .background(Color.blue.opacity(0.3))
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // OIDC Configuration Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("OIDC Configuration")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                VStack(spacing: 16) {
                                    TextField("Issuer URL", text: $issuerURL)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    TextField("Client ID", text: $clientID)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    TextField("Client Secret (optional)", text: $clientSecret)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    Picker("ACR Value", selection: $acrValue) {
                                        ForEach(acrOptions, id: \.self) { option in
                                            Text(option)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    TextField("Login Hint (Optional)", text: $loginHint)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    Toggle("Prompt for login", isOn: $promptLogin)
                                        .toggleStyle(.checkbox)
                                    
                                    Text("Redirect URI: \(defaultRedirectURI)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(4)
                                    
                                    TextField("Scopes", text: $scopes)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    TextField("Response Type", text: $responseType)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    TextField("Extra Params (optional)", text: $extraParams)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            
                            // Action Button Card
                            VStack(spacing: 16) {
                                Button(isLoading ? "Loading..." : "Begin Authentication") {
                                    selectedTab = 1 // Switch to Authentication tab
                                    startOIDCAuthentication()
                                }
                                .disabled(isLoading)
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .tint(.blue)
                                
                                if let error = errorMessage {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                    }
                }
                .padding(32)
                .tabItem {
                    Label("Config", systemImage: "gearshape.fill")
                }
                .tag(0)

                // Tokens Tab
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "key.fill")
                            .font(.title)
                            .foregroundColor(.green)
                        Text("Tokens")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                        .background(Color.green.opacity(0.3))
                    
                    if let token = tokenMessage {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Raw Tokens Card
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Raw Tokens")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    
                                    Text(token)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.primary)
                                        .textSelection(.enabled)
                                        .padding(16)
                                        .background(Color(.controlBackgroundColor))
                                        .cornerRadius(8)
                                }
                                .padding(20)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                
                                // Decoded Token Details Card
                                if let decodedDetails = getDecodedTokenDetails() {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Decoded Token Details")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                        
                                        Text(decodedDetails)
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.primary)
                                            .textSelection(.enabled)
                                            .padding(16)
                                            .background(Color(.controlBackgroundColor))
                                            .cornerRadius(8)
                                    }
                                    .padding(20)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                }
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack(spacing: 16) {
                                    Image(systemName: "key.slash")
                                        .font(.system(size: 48))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text("No tokens yet")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    Text("Complete authentication to see tokens here")
                                        .font(.body)
                                        .foregroundColor(.secondary.opacity(0.8))
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                    }
                }
                .padding(32)
                .tabItem {
                    Label("Tokens", systemImage: "key.fill")
                }
                .tag(2)

                // Logs Tab
                AuthenticationTabView(
                    isLoading: $isLoading,
                    isAuthenticating: $isAuthenticating,
                    progressMessage: progressMessage ?? "Ready to authenticate",
                    errorMessage: errorMessage,
                    webAuthSession: $webAuthSession,
                    onCancel: {
                        webAuthSession?.cancel()
                        isLoading = false
                        isAuthenticating = false
                        logMessages.append("Authentication cancelled by user")
                    }
                )
                .padding(32)
                .tabItem {
                    Label("Authentication", systemImage: "person.badge.key.fill")
                }
                .tag(1)

                // Logs Tab
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.title)
                            .foregroundColor(.purple)
                        Text("Logs")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                        .background(Color.purple.opacity(0.3))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity Log")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        if logMessages.isEmpty {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack(spacing: 16) {
                                        Image(systemName: "list.bullet.rectangle")
                                            .font(.system(size: 48))
                                            .foregroundColor(.secondary.opacity(0.5))
                                        Text("No activity yet")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                        Text("Start authentication to see logs here")
                                            .font(.body)
                                            .foregroundColor(.secondary.opacity(0.8))
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 6) {
                                    ForEach(logMessages, id: \.self) { msg in
                                        HStack {
                                            Circle()
                                                .fill(Color.purple.opacity(0.6))
                                                .frame(width: 4, height: 4)
                                                .padding(.top, 8)
                                            
                                            Text(msg)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.primary)
                                                .textSelection(.enabled)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(6)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .padding(32)
                .tabItem {
                    Label("Logs", systemImage: "doc.text.fill")
                }
                .tag(3)
            }
        }
        .frame(minWidth: 700, minHeight: 800)
    }

    func startOIDCAuthentication() {
        isLoading = true
        isAuthenticating = true
        errorMessage = nil
        progressMessage = "Fetching OIDC discovery document..."
        logMessages.append("Started OIDC authentication at \(Date())")
        guard let discoveryURL = URL(string: issuerURL + "/.well-known/openid-configuration") else {
            errorMessage = "Invalid Issuer URL."
            isLoading = false
            isAuthenticating = false
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: discoveryURL)
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let authEndpoint = json["authorization_endpoint"] as? String,
                      let tokenEndpoint = json["token_endpoint"] as? String else {
                    await MainActor.run {
                        errorMessage = "Failed to parse discovery document."
                        logMessages.append("Failed to parse discovery document.")
                        isLoading = false
                        isAuthenticating = false
                    }
                    return
                }
                await MainActor.run {
                    self.tokenEndpoint = tokenEndpoint
                    progressMessage = "Building authorization URL..."
                    logMessages.append("Fetched discovery document - Auth endpoint: \(authEndpoint), Token endpoint: \(tokenEndpoint)")
                }
                guard let url = buildAuthorizationURL(authEndpoint: authEndpoint) else {
                    await MainActor.run {
                        errorMessage = "Failed to build authorization URL."
                        logMessages.append("Failed to build authorization URL.")
                        isLoading = false
                        isAuthenticating = false
                    }
                    return
                }
                await MainActor.run {
                    progressMessage = "Starting authentication..."
                    logMessages.append("Starting authentication with URL: \(url)")
                    startWebAuthSession(authURL: url)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Authentication error: \(error.localizedDescription)"
                    logMessages.append("Authentication error: \(error.localizedDescription)")
                    isLoading = false
                    isAuthenticating = false
                }
            }
        }
    }

    func startWebAuthSession(authURL: URL) {
        let callbackScheme = "ImprivataOIDC"
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackScheme
        ) { callbackURL, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Authentication error: \(error.localizedDescription)"
                    logMessages.append("Authentication error: \(error.localizedDescription)")
                    isLoading = false
                    isAuthenticating = false
                    return
                }
                guard let callbackURL = callbackURL else {
                    errorMessage = "No callback URL received."
                    logMessages.append("No callback URL received.")
                    isLoading = false
                    isAuthenticating = false
                    return
                }
                progressMessage = "Authentication complete. Parsing tokens..."
                logMessages.append("Authentication complete. Parsing tokens from callback URL: \(callbackURL)")
                handleAuthCallback(url: callbackURL)
                isLoading = false
                isAuthenticating = false
            }
        }
        
        // Enable ephemeral web browser session
        session.prefersEphemeralWebBrowserSession = true
        
        // CRITICAL: Set presentation context provider BEFORE starting the session
        let contextProvider = PresentationContextProvider()
        contextProvider.setWindow(NSApplication.shared.windows.first)
        session.presentationContextProvider = contextProvider
        
        // Retain both the session and context provider
        webAuthSession = session
        presentationContextProvider = contextProvider
        
        // Update progress and start authentication
        progressMessage = "Opening browser for authentication..."
        logMessages.append("Authentication session starting with ephemeral browsing enabled and presentation context set.")
        
        // Start the session (presentation context provider is now set)
        session.start()
        
        // Update progress after session starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            progressMessage = "Waiting for authentication completion..."
        }
    }

    func handleAuthCallback(url: URL) {
        // Extract query parameters from callback URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else {
            errorMessage = "Failed to parse callback URL."
            return
        }
        
        var code: String?
        var idToken: String?
        var accessToken: String?
        var error: String?
        
        for item in items {
            if item.name == "code" { code = item.value }
            if item.name == "id_token" { idToken = item.value }
            if item.name == "access_token" { accessToken = item.value }
            if item.name == "error" { error = item.value }
        }
        
        // Check for errors first
        if let error = error {
            errorMessage = "Authentication error: \(error)"
            logMessages.append("Authentication error: \(error)")
            return
        }
        
        // If we have direct tokens (implicit flow), display them
        if idToken != nil || accessToken != nil {
            var result = ""
            if let idToken = idToken {
                result += "ID Token: \(idToken)\n"
            }
            if let accessToken = accessToken {
                result += "Access Token: \(accessToken)\n"
            }
            tokenMessage = result
            logMessages.append("Direct tokens received from callback")
            selectedTab = 2 // Switch to Tokens tab on success
            return
        }
        
        // If we have an authorization code, exchange it for tokens
        if let code = code, let tokenEndpoint = tokenEndpoint {
            progressMessage = "Exchanging authorization code for tokens..."
            logMessages.append("Authorization code received: \(code)")
            exchangeCodeForTokens(code: code, tokenEndpoint: tokenEndpoint)
        } else {
            errorMessage = "No authorization code or tokens received in callback."
            logMessages.append("No authorization code or tokens found in callback URL")
        }
    }
    
    func exchangeCodeForTokens(code: String, tokenEndpoint: String) {
        guard let tokenURL = URL(string: tokenEndpoint) else {
            errorMessage = "Invalid token endpoint URL."
            return
        }
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var bodyComponents = [
            "grant_type=authorization_code",
            "code=\(code)",
            "client_id=\(clientID)",
            "redirect_uri=\(defaultRedirectURI)"
        ]
        
        if !clientSecret.isEmpty {
            bodyComponents.append("client_secret=\(clientSecret)")
        }
        
        let body = bodyComponents.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)
        
        logMessages.append("Exchanging authorization code at token endpoint: \(tokenEndpoint)")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    logMessages.append("Token endpoint response status: \(httpResponse.statusCode)")
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    await MainActor.run {
                        errorMessage = "Failed to parse token response."
                        logMessages.append("Failed to parse token response.")
                    }
                    return
                }
                
                await MainActor.run {
                    var result = ""
                    
                    if let accessToken = json["access_token"] as? String {
                        result += "Access Token: \(accessToken)\n"
                        logMessages.append("Access token received")
                    }
                    
                    if let idToken = json["id_token"] as? String {
                        result += "ID Token: \(idToken)\n"
                        logMessages.append("ID token received")
                    }
                    
                    if let refreshToken = json["refresh_token"] as? String {
                        result += "Refresh Token: \(refreshToken)\n"
                        logMessages.append("Refresh token received")
                    }
                    
                    if let tokenType = json["token_type"] as? String {
                        result += "Token Type: \(tokenType)\n"
                    }
                    
                    if let expiresIn = json["expires_in"] as? Int {
                        result += "Expires In: \(expiresIn) seconds\n"
                    }
                    
                    tokenMessage = result.isEmpty ? "No tokens found in response." : result
                    logMessages.append("Token exchange completed successfully")
                    
                    // Switch to Tokens tab on successful token exchange
                    if !result.isEmpty {
                        selectedTab = 2
                    }
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "Token exchange error: \(error.localizedDescription)"
                    logMessages.append("Token exchange error: \(error.localizedDescription)")
                }
            }
        }
    }

    func decodeJWT(_ token: String) -> String {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return "Invalid JWT format." }
        let payload = segments[1]
        var payloadString = String(payload)
        // Pad base64 if needed
        let rem = payloadString.count % 4
        if rem > 0 {
            payloadString += String(repeating: "=", count: 4 - rem)
        }
        guard let data = Data(base64Encoded: payloadString, options: .ignoreUnknownCharacters),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return "Failed to decode JWT payload."
        }
        return "Decoded JWT: \(json)\n"
    }
    
    func getDecodedTokenDetails() -> String? {
        guard let token = tokenMessage else { return nil }
        
        var decodedDetails = ""
        let lines = token.components(separatedBy: "\n")
        
        for line in lines {
            if line.hasPrefix("ID Token: ") {
                let tokenValue = String(line.dropFirst("ID Token: ".count))
                if !tokenValue.isEmpty {
                    decodedDetails += "=== ID TOKEN DETAILS ===\n"
                    decodedDetails += formatTokenDetails(tokenValue)
                    decodedDetails += "\n"
                }
            } else if line.hasPrefix("Access Token: ") {
                let tokenValue = String(line.dropFirst("Access Token: ".count))
                if !tokenValue.isEmpty {
                    decodedDetails += "=== ACCESS TOKEN DETAILS ===\n"
                    decodedDetails += formatTokenDetails(tokenValue)
                    decodedDetails += "\n"
                }
            }
        }
        
        return decodedDetails.isEmpty ? nil : decodedDetails
    }
    
    func formatTokenDetails(_ token: String) -> String {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return "Invalid JWT format.\n" }
        
        var result = ""
        
        // Decode header
        if let headerData = decodeBase64URLSafe(String(segments[0])),
           let headerJson = try? JSONSerialization.jsonObject(with: headerData) as? [String: Any] {
            result += "Header:\n"
            result += formatJSON(headerJson, indent: "  ")
            result += "\n"
        }
        
        // Decode payload
        if let payloadData = decodeBase64URLSafe(String(segments[1])),
           let payloadJson = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
            result += "Payload:\n"
            result += formatJSON(payloadJson, indent: "  ")
            result += "\n"
        }
        
        // Show signature info
        result += "Signature: \(segments[2])\n"
        
        return result
    }
    
    func decodeBase64URLSafe(_ string: String) -> Data? {
        var base64 = string
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        
        // Pad if necessary
        let rem = base64.count % 4
        if rem > 0 {
            base64 += String(repeating: "=", count: 4 - rem)
        }
        
        return Data(base64Encoded: base64)
    }
    
    func formatJSON(_ json: [String: Any], indent: String) -> String {
        var result = ""
        let sortedKeys = json.keys.sorted()
        
        for key in sortedKeys {
            let value = json[key]
            if let stringValue = value as? String {
                result += "\(indent)\(key): \"\(stringValue)\"\n"
            } else if let numberValue = value as? NSNumber {
                result += "\(indent)\(key): \(numberValue)\n"
            } else if let arrayValue = value as? [Any] {
                result += "\(indent)\(key): \(arrayValue)\n"
            } else if let dictValue = value as? [String: Any] {
                result += "\(indent)\(key): \(dictValue)\n"
            } else {
                result += "\(indent)\(key): \(String(describing: value))\n"
            }
        }
        
        return result
    }

    func buildAuthorizationURL(authEndpoint: String) -> URL? {
        var components = URLComponents(string: authEndpoint)
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: defaultRedirectURI),
            URLQueryItem(name: "response_type", value: responseType),
            URLQueryItem(name: "scope", value: scopes)
        ]
        if acrValue != "None" {
            let acrRaw = acrValue.contains("(") ? acrValue.split(separator: "(").last?.dropLast() : nil
            queryItems.append(URLQueryItem(name: "acr_values", value: acrRaw != nil ? String(acrRaw!) : acrValue))
        }
        if !loginHint.isEmpty {
            queryItems.append(URLQueryItem(name: "login_hint", value: loginHint))
        }
        if promptLogin {
            queryItems.append(URLQueryItem(name: "prompt", value: "login"))
        }
        if !extraParams.isEmpty {
            let pairs = extraParams.split(separator: "&")
            for pair in pairs {
                let kv = pair.split(separator: "=")
                if kv.count == 2 {
                    queryItems.append(URLQueryItem(name: String(kv[0]), value: String(kv[1])))
                }
            }
        }
        components?.queryItems = queryItems
        return components?.url
    }
}

// MARK: - Authentication Tab View
struct AuthenticationTabView: View {
    @Binding var isLoading: Bool
    @Binding var isAuthenticating: Bool
    let progressMessage: String
    let errorMessage: String?
    @Binding var webAuthSession: ASWebAuthenticationSession?
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "person.badge.key.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                Text("Authentication")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 8)
            
            Divider()
                .background(Color.orange.opacity(0.3))
            
            VStack(spacing: 20) {
                if isAuthenticating {
                    // Active Authentication Card
                    VStack(spacing: 24) {
                        HStack {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 32))
                                .foregroundColor(.orange)
                            Text("OIDC Authentication in Progress")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)
                        }
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background(Circle().fill(Color.orange.opacity(0.1)))
                        
                        VStack(spacing: 16) {
                            Text(progressMessage)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text("Complete authentication in the browser window that opens.\nThis tab serves as the presentation context for secure authentication.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(20)
                        .background(Color.orange.opacity(0.05))
                        .cornerRadius(12)
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.body)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Button("Cancel Authentication") {
                            onCancel()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .tint(.red)
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
                    
                } else {
                    // Idle State Card
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "person.badge.key")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.5))
                            VStack(alignment: .leading) {
                                Text("Ready to Authenticate")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Click 'Begin Authentication' on the Config tab to start")
                                    .font(.body)
                                    .foregroundColor(.secondary.opacity(0.8))
                            }
                        }
                        
                        if let error = errorMessage {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Error:")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.body)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                }
                
                Spacer()
                
                // Info Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Authentication Context")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("This tab provides the secure presentation context for OIDC authentication sessions. When authentication begins, Safari will open with your OIDC provider, and this window serves as the trusted anchor for the authentication process.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.orange.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

// MARK: - Presentation Context Provider
class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var window: NSWindow?
    
    func setWindow(_ window: NSWindow?) {
        self.window = window
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Return the designated window or fall back to main application window
        return window ?? NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}
