module.exports = {
    root: true,
    extends: [
        'plugin:@wordpress/eslint-plugin/recommended',
        'plugin:prettier/recommended'
    ],
    env: {
        browser: true,
        es6: true
    },
    globals: {
        wp: 'readonly'
    },
    parserOptions: {
        ecmaVersion: 2021,
        sourceType: 'module'
    },
    rules: {
        'no-console': ['error', { allow: ['warn', 'error'] }],
        'no-unused-vars': ['error', { argsIgnorePattern: '^_' }]
    }
}; 