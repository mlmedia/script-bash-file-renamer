# Development

Use these guidelines to keep the repository consistent.

## Code formatting with Prettier

Prettier keeps code style consistent across the repository. The following commands format and check files:

```bash
npx prettier --check "**/*.{js,jsx,ts,tsx,json,css,scss,html,md}"
```

To apply formatting in place:

```bash
npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,scss,html,md}"
```

Install the Prettier – Code Formatter extension in VS Code and enable `"editor.formatOnSave": true` to format files automatically on save using the project’s `.prettierrc`.
