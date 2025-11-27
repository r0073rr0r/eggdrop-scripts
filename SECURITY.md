# Security Policy

## Supported Versions

We currently support security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < Latest | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please **DO NOT** open a public issue. Instead, please report it privately using one of the following methods:

### Preferred Method

- **Email**: Report via GitHub Security Advisories (if available)
- **IRC**: Contact munZe on irc.dbase.in.rs (DBase Network)

### What to Include

When reporting a vulnerability, please include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)
- Your contact information

### Response Time

We aim to:

- Acknowledge receipt within 48 hours
- Provide initial assessment within 7 days
- Keep you updated on progress

### Security Best Practices

When using these scripts:

- **Review code** before deploying to production
- **Keep Eggdrop updated** to the latest stable version
- **Use strong passwords** for bot authentication
- **Limit access** to authorized users only
- **Monitor logs** for suspicious activity
- **Regular backups** of configuration and data

### Known Security Considerations

- Scripts may execute external commands - review before use
- Some scripts require OPER privileges - use with caution
- IP checking scripts may make external HTTP requests
- RSS feeds may fetch content from external sources

### Disclosure Policy

- Vulnerabilities will be disclosed after a fix is available
- Credit will be given to reporters (if desired)
- A security advisory will be published for significant issues

Thank you for helping keep Eggdrop Scripts secure!
