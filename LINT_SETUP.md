# 🎯 Configuration Linting & Formatting

## ✅ Installation Complète

### Frontend

```bash
cd frontend
npm run lint          # Linter les fichiers
npm run lint:fix      # Fixer les erreurs ESLint
npm run format        # Formater avec Prettier
npm run format:check  # Vérifier la formatting
```

### Backend

```bash
cd backend
npm run lint          # Linter les fichiers
npm run lint:fix      # Fixer les erreurs ESLint
npm run format        # Formater avec Prettier
npm run format:check  # Vérifier la formatting
```

### Racine (Pour tout linter)

```bash
npm run lint:front    # Linter le frontend
npm run lint:back     # Linter le backend
npm run lint:all      # Linter front + back
```

## 🔧 Configuration

### Frontend - `eslint.config.js` & `.prettierrc.json`

- Vue 3 recommandations activées
- Prettier intégré
- Attributs Vue ordonnés correctement
- Globals du navigateur configurés (localStorage, console, etc.)

### Backend - `eslint.config.js` & `.prettierrc.json`

- ESLint recommandations
- Support CommonJS (require, module, process, console)
- Prettier intégré

### `.prettierrc.json` (Frontend & Backend)

```json
{
  "semi": true,
  "trailingComma": "all",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "always"
}
```

## 📊 Statut Actuel

### Frontend

- ⚠️ 15 avertissements (attribute ordering, unused imports)
- ✅ 0 erreurs
- ✅ Formatting issues (fixable with `npm run format`)

### Backend

- ⚠️ 4 avertissements (unused vars, console logs)
- ✅ 0 erreurs
- ✅ Formatting issues (fixable with `npm run format`)

## 🚀 Prochaines Étapes

### Intégration aux Hooks

Ajouter au `.husky/pre-commit`:

```bash
npm run lint:all        # Vérifier ESLint
npm run format:check    # Vérifier Prettier
```

Ajouter au `.husky/pre-push`:

```bash
npm run lint:fix        # Auto-fixer les erreurs
npm run format          # Auto-formatter le code
```

### Auto-correction Recommandée

Pour formatter tous les fichiers automatiquement :

```bash
cd frontend && npm run format && cd ../backend && npm run format
```

Ou utiliser le script root :

```bash
npm run format:all    # (À ajouter au package.json root)
```

## 📦 Dépendances Installées

### Frontend

- `eslint` - Linter JavaScript
- `prettier` - Formatteur de code
- `eslint-plugin-vue` - Plugin Vue pour ESLint
- `@eslint/js` - ESLint config flat
- `eslint-config-prettier` - Désactiver les règles ESLint conflictantes avec Prettier

### Backend

- `eslint` - Linter JavaScript
- `prettier` - Formatteur de code
- `@eslint/js` - ESLint config flat
- `eslint-config-prettier` - Désactiver les règles ESLint conflictantes avec Prettier
