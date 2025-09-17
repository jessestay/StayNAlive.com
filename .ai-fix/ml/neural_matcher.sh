#!/bin/bash

# Neural network-based pattern matching using Python
create_neural_matcher() {
    cat > .ai-fix/ml/matcher.py << 'EOL'
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neural_network import MLPClassifier
import json
import sys
import transformers
import torch
import torch.nn as nn

class ErrorMatcher:
    def __init__(self):
        # Load pre-trained error embeddings
        self.error_bert = transformers.AutoModel.from_pretrained('bert-base-uncased')
        self.tokenizer = transformers.AutoTokenizer.from_pretrained('bert-base-uncased')
        
        self.vectorizer = TfidfVectorizer(
            ngram_range=(1, 3),
            max_features=5000,
            analyzer='char_wb'
        )
        self.classifier = MLPClassifier(
            hidden_layer_sizes=(256, 128, 64),
            activation='relu',
            solver='adam',
            learning_rate='adaptive',
            max_iter=1000,
            early_stopping=True
        )
        
        # Add attention mechanism
        self.attention = nn.MultiheadAttention(embed_dim=768, num_heads=8)
        
        self.load_patterns()
        self.error_embeddings = {}
        self.pattern_cache = {}
    
    def get_bert_embedding(self, text):
        """Get BERT embeddings with attention"""
        tokens = self.tokenizer(text, return_tensors='pt', padding=True, truncation=True)
        with torch.no_grad():
            outputs = self.error_bert(**tokens)
            # Apply attention
            attn_output, _ = self.attention(
                outputs.last_hidden_state,
                outputs.last_hidden_state,
                outputs.last_hidden_state
            )
            return attn_output.mean(dim=1).squeeze().numpy()
    
    def load_patterns(self):
        with open('.ai-fix/patterns/db.json', 'r') as f:
            self.patterns = json.load(f)
            self.build_embeddings()
    
    def build_embeddings(self):
        """Build error embeddings for faster matching"""
        texts = [p['pattern'] for p in self.patterns['patterns'].values()]
        X = self.vectorizer.fit_transform(texts)
        for text, vec in zip(texts, X):
            self.error_embeddings[text] = vec.toarray()[0]
    
    def train(self):
        texts = [p['pattern'] for p in self.patterns['patterns'].values()]
        fixes = [p['fix'] for p in self.patterns['patterns'].values()]
        X = self.vectorizer.fit_transform(texts)
        y = np.array(fixes)
        
        # Add noise for robustness
        X_noisy = self.add_noise(X.toarray())
        X_augmented = np.vstack([X.toarray(), X_noisy])
        y_augmented = np.concatenate([y, y])
        
        self.classifier.fit(X_augmented, y_augmented)
    
    def add_noise(self, X, noise_level=0.1):
        """Add random noise to training data for robustness"""
        noise = np.random.normal(0, noise_level, X.shape)
        return X + noise
    
    def predict(self, error_msg):
        # Get both BERT and TF-IDF features
        tfidf_features = self.vectorizer.transform([error_msg]).toarray()[0]
        bert_features = self.get_bert_embedding(error_msg)
        
        # Combine features
        X = np.concatenate([tfidf_features, bert_features])
        
        # Find most similar patterns
        similarities = []
        for pattern, embedding in self.error_embeddings.items():
            # Use cached similarity if available
            if pattern in self.pattern_cache:
                sim = self.pattern_cache[pattern]
            else:
                sim = self.cosine_similarity(X, embedding)
                self.pattern_cache[pattern] = sim
            similarities.append((sim, pattern))
        
        # Get top 3 most similar patterns
        top_patterns = sorted(similarities, reverse=True)[:3]
        
        # Get predictions for top patterns
        predictions = []
        for sim, pattern in top_patterns:
            if sim > 0.7:  # Similarity threshold
                pred = self.classifier.predict(self.vectorizer.transform([pattern]))
                predictions.append((sim, pred[0]))
        
        if not predictions:
            return None
            
        # Return highest confidence prediction
        return max(predictions, key=lambda x: x[0])[1]
    
    def cosine_similarity(self, a, b):
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

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