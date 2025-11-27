# Contributing to Eggdrop Scripts

Thank you for your interest in contributing to the Eggdrop Scripts repository! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:

- A clear, descriptive title
- Steps to reproduce the bug
- Expected behavior
- Actual behavior
- Your Eggdrop version and TCL version
- Any relevant error messages or logs

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- A clear description of the enhancement
- Use cases and examples
- Why this enhancement would be useful

### Submitting Code Changes

1. **Fork the repository**
2. **Create a branch** for your changes (`git checkout -b feature/amazing-feature`)
3. **Make your changes** following the coding standards below
4. **Test your changes** thoroughly
5. **Commit your changes** with clear, descriptive commit messages
6. **Push to your branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

## Coding Standards

### TCL Script Guidelines

- **Indentation**: Use spaces (4 spaces per level)
- **Comments**: Add comments for complex logic
- **Naming**: Use descriptive variable and procedure names
- **Error Handling**: Include proper error handling
- **Documentation**: Update README.md if adding new commands or features

### Code Style

```tcl
# Good example
proc my_proc {arg1 arg2} {
    if {$arg1 == ""} {
        return 0
    }
    # Do something
    return 1
}
```

### Script Structure

Each script should include:

- Header with version, author, and description
- Configuration section at the top
- Clear procedure definitions
- Proper namespace usage when appropriate
- Error handling

## Pull Request Process

1. Ensure your code follows the coding standards
2. Update documentation (README.md) if needed
3. Test your changes with Eggdrop 1.10.0+ and TCL 8.6+
4. Ensure all existing tests pass (if applicable)
5. Add comments explaining complex logic
6. Update version numbers if making significant changes

### PR Title Format

Use descriptive titles:

- `Add feature: description`
- `Fix bug: description`
- `Update script: description`

## Testing

Before submitting:

- Test your script on a test Eggdrop instance
- Verify it works with the latest Eggdrop version
- Check for any error messages in logs
- Test edge cases and error conditions

## Documentation

- Update README.md with new features or commands
- Add comments in code for complex logic
- Include examples in documentation when helpful

## Questions?

Feel free to:

- Open an issue for questions
- Contact the maintainer on IRC: irc.dbase.in.rs
- Check existing issues and discussions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

Thank you for contributing! 🎉
