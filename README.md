# OIDC Tester

A professional macOS and iOS application for testing OpenID Connect (OIDC) authentication flows and inspecting JWT tokens.

![OIDC Tester App Icon](app_icon_preview.png)

## Overview

OIDC Tester is a native SwiftUI application designed to help developers and security professionals test OIDC authentication servers, inspect JWT tokens, and debug authentication flows. The app provides a clean, intuitive interface for configuring OIDC parameters and analyzing authentication responses.

## Platform Support

- **macOS**: Primary platform with full feature support
- **iOS**: Universal app icon support for future iOS deployment

## Features

### 🔐 **Authentication Testing**
- **Complete OIDC Flow Support**: Authorization Code flow with PKCE
- **Multiple Authentication Methods**: Support for various ACR (Authentication Context Class Reference) values
- **Real-time Authentication**: Uses `ASWebAuthenticationSession` for secure, Apple-compliant authentication
- **Custom Parameters**: Support for additional query parameters and login hints

### 🔍 **Token Analysis**
- **JWT Token Decoding**: Automatic parsing and display of JWT headers, payloads, and signatures
- **Multiple Token Types**: Support for ID tokens, access tokens, and refresh tokens
- **Readable Format**: Pretty-printed JSON with proper formatting and syntax highlighting
- **Token Validation**: Basic JWT structure validation and parsing

### 📊 **Comprehensive Logging**
- **Real-time Activity Logs**: Detailed logging of all authentication steps
- **Error Handling**: Clear error messages and debugging information
- **Session Tracking**: Complete audit trail of authentication attempts
- **Export Capabilities**: Easy copying of logs and token data

### 🎨 **Professional UI**
- **Modern Design**: Clean, card-based interface with gradient backgrounds
- **Tab Organization**: Organized workflow with Config → Authentication → Tokens → Logs
- **Responsive Layout**: Adaptive interface that works on various screen sizes
- **macOS Integration**: Native macOS appearance with proper system integration

## System Requirements

- **macOS**: 10.15 (Catalina) or later
- **Architecture**: Apple Silicon (M1/M2) and Intel Macs supported
- **Xcode**: 14.0 or later (for building from source)
- **Swift**: 5.7 or later

## Installation

### Option 1: Download Release (Recommended)
1. Download the latest release from the [Releases](../../releases) page
2. Open the `.dmg` file and drag OIDC Tester to your Applications folder
3. Launch the app from Applications or Spotlight

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/[username]/oidc-tester.git
cd oidc-tester

# Open in Xcode
open "OIDC Tester.xcodeproj"

# Or build from command line
xcodebuild -project "OIDC Tester.xcodeproj" -scheme "OIDC Tester" build
```

## Usage

### 1. **Configuration Tab**
Set up your OIDC server parameters:
- **Issuer URL**: Your OIDC provider's base URL
- **Client ID**: Your application's client identifier
- **Client Secret**: (Optional) For confidential clients
- **Scopes**: Space-separated list of requested scopes
- **ACR Values**: Authentication Context Class Reference
- **Login Hint**: Pre-fill username/email for testing

### 2. **Authentication Tab**
- Click "Start Authentication" to begin the OIDC flow
- The app will open Safari for secure authentication
- Complete login in the browser
- Return to the app to see results

### 3. **Tokens Tab**
- View decoded JWT tokens with full header and payload information
- Copy token values for external testing
- Inspect token expiration and claims
- Analyze token structure and validation

### 4. **Logs Tab**
- Monitor real-time authentication progress
- Review detailed error messages
- Track API calls and responses
- Export logs for debugging

## Configuration Examples

### **Keycloak**
```
Issuer URL: https://your-keycloak.com/auth/realms/your-realm
Client ID: your-client-id
Scopes: openid profile email
```

### **Azure AD**
```
Issuer URL: https://login.microsoftonline.com/your-tenant-id/v2.0
Client ID: your-application-id
Scopes: openid profile email
```

### **Auth0**
```
Issuer URL: https://your-domain.auth0.com
Client ID: your-client-id
Scopes: openid profile email
```

## Security Features

- **Sandboxed Application**: Runs in macOS App Sandbox for security
- **Ephemeral Sessions**: Authentication sessions don't persist cookies
- **Secure Storage**: Configuration stored securely in UserDefaults
- **No Data Collection**: All processing happens locally on your device

## Supported OIDC Features

- ✅ Authorization Code Flow
- ✅ PKCE (Proof Key for Code Exchange)
- ✅ State parameter for CSRF protection
- ✅ Custom redirect URI scheme
- ✅ Multiple response types
- ✅ Custom ACR values
- ✅ Login hints and prompts
- ✅ JWT token parsing and validation

## Architecture

The application is built using modern Swift and SwiftUI:

- **SwiftUI**: Declarative UI framework for clean, maintainable interfaces
- **ASWebAuthenticationSession**: Apple's secure authentication framework
- **Combine**: For reactive data binding and state management
- **Foundation**: Core networking and JSON processing
- **Security Framework**: For secure credential storage

## Troubleshooting

### Common Issues

**"Authentication Error: The operation can not be completed. (com.apple.AuthenticationServices.WebAuthenticationSession error 2)"**
- This typically indicates a configuration issue with the OIDC provider
- Verify your redirect URI is properly configured as `ImprivataOIDC://callback`
- Ensure your issuer URL is correct and accessible

**"Failed to parse discovery document"**
- Check that your issuer URL includes the correct path
- Verify the OIDC provider supports the `.well-known/openid-configuration` endpoint
- Test the discovery URL directly in a browser

**"No authorization code or tokens received"**
- Verify your client ID is correct
- Check that the redirect URI matches exactly: `ImprivataOIDC://callback`
- Review the logs tab for detailed error information

### Debug Mode

For additional debugging information:
1. Open the **Logs** tab before starting authentication
2. Monitor real-time log messages during the flow
3. Copy relevant log entries when reporting issues

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

### Code Style

- Follow Swift naming conventions
- Use SwiftUI best practices
- Include documentation for public APIs
- Write unit tests for new functionality

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 **Issues**: [GitHub Issues](../../issues)
- 💬 **Discussions**: [GitHub Discussions](../../discussions)
- 📖 **Documentation**: [Wiki](../../wiki)

## Acknowledgments

- Built with Swift and SwiftUI
- Uses Apple's ASWebAuthenticationSession for secure authentication
- Icon design inspired by security and authentication themes
- Thanks to the OIDC community for specifications and standards

---

**Made with ❤️ for the OIDC community**

*OIDC Tester is an open-source project designed to make OIDC testing easier and more accessible for developers and security professionals.*
