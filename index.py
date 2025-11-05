# Creates the web server to run the scraper. 

from flask import Flask, jsonify
from flask_cors import CORS

# This imports your vlr_news function from scraper.py
from scraper import vlr_news

# Create the server app
app = Flask(__name__)
CORS(app)  # Allows your Swift app to connect

# Create the API endpoint
@app.route("/api/news")
def get_news():
    try:
        # Call your function when someone visits /api/news
        news_data = vlr_news() 
        return jsonify(news_data)
    except Exception as e:
        # Return an error if your scraper fails
        return jsonify({"error": str(e)}), 500

# This is the code that runs the server
if __name__ == "__main__":
    # Runs on http://127.0.0.1:5000
    app.run(debug=True, port=5000)