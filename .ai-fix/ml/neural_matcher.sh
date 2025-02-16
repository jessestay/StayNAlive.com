#!/bin/bash

# Neural network-based pattern matching using Python
create_neural_matcher() {
    cat > .ai-fix/ml/matcher.py << 'EOL'
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neural_network import MLPClassifier
import json
import sys

class ErrorMatcher:
    def __init__(self):
        self.vectorizer = TfidfVectorizer()
        self.classifier = MLPClassifier(hidden_layer_sizes=(100, 50))
        self.load_patterns()
    
    def load_patterns(self):
        with open('.ai-fix/patterns/db.json', 'r') as f:
            self.patterns = json.load(f)
            
    def train(self):
        texts = [p['pattern'] for p in self.patterns['patterns'].values()]
        fixes = [p['fix'] for p in self.patterns['patterns'].values()]
        X = self.vectorizer.fit_transform(texts)
        self.classifier.fit(X, fixes)
    
    def predict(self, error_msg):
        X = self.vectorizer.transform([error_msg])
        return self.classifier.predict(X)[0]

if __name__ == '__main__':
    matcher = ErrorMatcher()
    matcher.train()
    print(matcher.predict(sys.argv[1]))
EOL
}

# Function to match errors using neural network
neural_match() {
    local error_msg="$1"
    
    # Create matcher if it doesn't exist
    if [ ! -f ".ai-fix/ml/matcher.py" ]; then
        create_neural_matcher
    fi
    
    # Get prediction
    python3 .ai-fix/ml/matcher.py "$error_msg"
} 