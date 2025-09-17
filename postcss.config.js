module.exports = {
    plugins: [
        require('postcss-import'),
        require('postcss-preset-env')({
            stage: 1,
            features: {
                'custom-properties': true,
                'nesting-rules': true
            }
        }),
        require('autoprefixer')
    ]
}; 