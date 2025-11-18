# Creates the web server to run the scraper. USE THE FOLLOWING CODE TO INITIALIZE!!
# python3 -m venv venv
# source venv/bin/activate
# pip install -r requirements.txt
# python index.py
# Server should now be running on http://127.0.0.1:5000/api/val_news
# After you close it, you only need 2 steps to rerun it.
# source venv/bin/activate
# python index.py

from flask import Flask, jsonify
from flask_cors import CORS

# This imports the multiple scrapers.

from VALscraper import val_news as val_news_scraper
from OWscraper import ow_news as ow_news_scraper
from RLscraper import rl_news as rl_news_scraper # <-- 1. ADD THIS IMPORT

# Create the server app
# Allows Swift app to connect

app = Flask(__name__)
CORS(app)

# Create the API endpoint

@app.route("/api/val_news")
def get_val_news():
    try:

        # Calls function when someone visits /api/val_news

        news_data = val_news_scraper() 
        return jsonify(news_data)
    except Exception as e:

        # Return an error if the scraper fails

        return jsonify({"error": str(e)}), 500

@app.route("/api/ow_news")
def get_ow_news():
    try:
        news_data = ow_news_scraper() 
        return jsonify(news_data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# --- 2. ADD THIS ENTIRE ROUTE ---
@app.route("/api/rl_news")
def get_rl_news():
    try:
        news_data = rl_news_scraper() 
        return jsonify(news_data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
# --- END OF NEW ROUTE ---


# This is the code that runs the server

if __name__ == "__main__":

    # Runs on http://127.0.0.1:5000

    app.run(debug=True, port=5000)