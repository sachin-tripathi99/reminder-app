# Contributing to Interval-Based Alarm Reminder App

Thank you for considering contributing to this project! Here are some guidelines to help you get started.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device/OS information
- App version

### Suggesting Enhancements

Enhancement suggestions are welcome! Please create an issue with:
- A clear, descriptive title
- Detailed description of the proposed feature
- Why this enhancement would be useful
- Possible implementation approach

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m 'Add feature X'`)
6. Push to your branch (`git push origin feature/your-feature-name`)
7. Open a Pull Request

#### Pull Request Guidelines

- Follow the existing code style
- Include tests for new features
- Update documentation as needed
- Keep PRs focused on a single feature/fix
- Ensure all tests pass
- Add entry to CHANGELOG.md

## Development Setup

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio or VS Code
- Android device/emulator (API 23+) or iOS device/simulator
- Git

### Setup Steps

1. Clone your fork:
```bash
git clone https://github.com/YOUR_USERNAME/reminder-app.git
cd reminder-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Add alarm sound files to `assets/sounds/` (see README for details)

4. Run the app:
```bash
flutter run
```

## Code Style

### Dart/Flutter

- Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` to format code
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### File Organization

```
lib/
├── models/       # Data models
├── services/     # Business logic and external integrations
├── providers/    # State management
├── screens/      # Full-page UI components
└── widgets/      # Reusable UI components
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

- Add unit tests for models and services
- Add widget tests for UI components
- Add integration tests for critical flows
- Aim for >80% code coverage

## Commit Messages

Follow the conventional commits format:

- `feat: add snooze statistics feature`
- `fix: correct alarm scheduling on DST change`
- `docs: update README with iOS setup instructions`
- `style: format code with flutter format`
- `refactor: extract alarm logic to separate service`
- `test: add tests for reminder model`
- `chore: update dependencies`

## Documentation

- Update README.md for user-facing changes
- Update IMPLEMENTATION.md for technical details
- Add inline comments for complex logic
- Update CHANGELOG.md for all changes

## Review Process

1. All PRs require at least one review
2. Address review comments promptly
3. Keep discussions professional and constructive
4. Be open to feedback

## Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

Positive behavior includes:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards others

Unacceptable behavior includes:
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

## Questions?

Feel free to open an issue for any questions about contributing!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
