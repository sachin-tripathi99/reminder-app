# Security Policy

## Supported Versions

Currently supported versions for security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of the Interval-Based Alarm Reminder App seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do Not Open a Public Issue

Please do not open a public GitHub issue for security vulnerabilities. This helps protect users while the vulnerability is being addressed.

### 2. Report via Email

Send a detailed report to the project maintainers. Include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### 3. Response Time

You can expect:
- Acknowledgment within 48 hours
- Initial assessment within 1 week
- Regular updates on progress
- Public disclosure after fix is released

## Security Best Practices

### For Users

1. **Keep App Updated**
   - Always use the latest version
   - Enable automatic updates

2. **Permission Management**
   - Review requested permissions
   - Grant only necessary permissions
   - Check permissions periodically

3. **Device Security**
   - Use device lock screen
   - Keep OS updated
   - Enable Find My Device

4. **Data Protection**
   - Regular backups (manual)
   - Don't root/jailbreak device
   - Use secure Wi-Fi networks

### For Developers

1. **Code Quality**
   - Run static analysis
   - Follow security guidelines
   - Regular dependency updates

2. **Sensitive Data**
   - No hardcoded credentials
   - Secure local storage
   - Encryption for sensitive data

3. **Permissions**
   - Request minimal permissions
   - Runtime permission checks
   - Clear permission explanations

4. **Third-Party Dependencies**
   - Regular security audits
   - Use trusted packages
   - Monitor for vulnerabilities

## Security Features

### Current Implementation

1. **Local Data Storage**
   - All data stored locally on device
   - No cloud transmission
   - SQLite database in app sandbox
   - Protected by OS-level security

2. **Permission Model**
   - Runtime permission requests
   - Clear justification for each permission
   - Graceful degradation if denied
   - No excessive permissions

3. **No Data Collection**
   - No analytics
   - No user tracking
   - No third-party SDKs for analytics
   - Privacy by design

4. **Secure Communication**
   - No network communication (currently)
   - No API calls
   - No user authentication

5. **Code Security**
   - Static analysis with flutter analyze
   - CodeQL security scanning
   - Regular dependency updates
   - Secure coding practices

### Planned Security Enhancements

1. **Database Encryption**
   - SQLCipher integration
   - Encrypted database storage
   - Key management

2. **Biometric Authentication** (Optional)
   - Fingerprint unlock
   - Face recognition
   - PIN protection for sensitive actions

3. **Secure Cloud Backup** (If implemented)
   - End-to-end encryption
   - User-controlled keys
   - Zero-knowledge architecture

4. **Certificate Pinning** (If networking added)
   - SSL/TLS enforcement
   - Certificate validation
   - Man-in-the-middle prevention

## Known Security Considerations

### Permission Requirements

The app requires several permissions that users should be aware of:

1. **SCHEDULE_EXACT_ALARM**
   - Purpose: Trigger alarms at precise times
   - Risk: Low - standard alarm app permission
   - Mitigation: Required for core functionality

2. **ACCESS_NOTIFICATION_POLICY**
   - Purpose: Detect ringer mode
   - Risk: Low - read-only access
   - Mitigation: No data modification

3. **WAKE_LOCK**
   - Purpose: Keep device awake for alarms
   - Risk: Low - battery drain potential
   - Mitigation: Used only during alarm

4. **VIBRATE**
   - Purpose: Vibration alerts
   - Risk: None
   - Mitigation: Standard alarm functionality

5. **USE_FULL_SCREEN_INTENT**
   - Purpose: Show full-screen alarm
   - Risk: Low - UI overlay
   - Mitigation: User-initiated, expected behavior

### Data Storage

**What is stored:**
- Reminder configurations (name, times, days)
- Alarm history (trigger/dismiss times)
- App preferences

**What is NOT stored:**
- No personal information
- No location data
- No contacts or calendar access
- No health/medical information

**Storage location:**
- App-specific directory
- Protected by Android/iOS sandbox
- Cleared when app uninstalled

### Background Execution

The app runs in background to trigger alarms:

**Security measures:**
- No network access in background
- Limited to alarm scheduling
- System-controlled execution
- User can disable in settings

## Compliance

### GDPR (EU)
- ✅ No personal data collection
- ✅ No data processing
- ✅ No data sharing
- ✅ Local storage only
- ✅ Right to delete (uninstall app)

### CCPA (California)
- ✅ No sale of personal information
- ✅ No personal data collection
- ✅ Transparent privacy practices

### COPPA (Children's Privacy)
- ✅ No data collection from children
- ✅ No age restrictions needed
- ✅ Safe for all ages

### Accessibility (WCAG)
- 🔧 Partial compliance with WCAG 2.1 Level AA
- 🔄 Ongoing improvements

## Security Audit History

### Version 1.0.0 (2025-10-21)
- ✅ CodeQL static analysis - No critical issues
- ✅ Dependency audit - All packages secure
- ✅ Permission review - Minimal required permissions
- ✅ Data flow analysis - No data leakage

## Vulnerability Disclosure Policy

### Disclosure Timeline

1. **Day 0**: Vulnerability reported
2. **Day 1-2**: Acknowledged by team
3. **Day 7**: Initial assessment provided
4. **Day 30**: Fix developed and tested
5. **Day 45**: Update released
6. **Day 60**: Public disclosure (if appropriate)

### Credit Policy

Security researchers who responsibly disclose vulnerabilities will be:
- Acknowledged in release notes
- Listed in security hall of fame
- Credited in CHANGELOG.md

## Security Checklist for Contributors

Before submitting code:

- [ ] No hardcoded credentials or API keys
- [ ] No sensitive data in logs
- [ ] Proper error handling
- [ ] Input validation
- [ ] SQL injection prevention (parameterized queries)
- [ ] No eval() or dangerous functions
- [ ] Secure random number generation
- [ ] Proper permission checks
- [ ] No file path traversal vulnerabilities
- [ ] Dependencies are up to date
- [ ] Static analysis passes
- [ ] CodeQL scan passes

## Security Tools

### Used in Development

1. **Flutter Analyze**
   - Static code analysis
   - Security linting rules
   - Run before each commit

2. **CodeQL**
   - Advanced security scanning
   - Pattern-based vulnerability detection
   - Integrated in CI/CD

3. **Dependency Check**
   - Regular package audits
   - Vulnerability scanning
   - Automated updates

### Recommended for Testing

1. **OWASP Mobile Security Testing Guide**
2. **Android Security Test Framework**
3. **iOS Security Test Tools**

## Contact

For security concerns:
- **DO**: Report privately via email
- **DON'T**: Open public issues for vulnerabilities

For general security questions:
- Open a GitHub Discussion
- Check existing documentation
- Review security policy

## Acknowledgments

We thank the following security researchers for responsible disclosure:
- (None yet - first to report gets listed here!)

## Resources

- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://flutter.dev/docs/development/data-and-backend/security)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [iOS Security Guide](https://support.apple.com/guide/security/welcome/web)

## Updates

This security policy is reviewed and updated:
- After each security incident
- With each major release
- At least quarterly
- When regulations change

Last updated: 2025-10-21

---

**Remember:** Security is everyone's responsibility. If you see something, say something.
