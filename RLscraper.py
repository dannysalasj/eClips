import requests
from selectolax.parser import HTMLParser # We are using the HTML parser
import re 

# Define headers locally to be 100% sure they are used
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36'
}

def rl_news():
    # 1. This is the new RSS FEED URL you provided
    url = "https://www.reddit.com/r/RocketLeagueEsports/.rss"
    
    try:
        resp = requests.get(url, headers=headers)
        resp.raise_for_status() 
        
        # 2. We use the HTML parser on the XML feed.
        # It's error-tolerant and will lowercase all tags.
        parser = HTMLParser(resp.text)
        status = 200
        
    except Exception as e:
        # Added 'v_REDDIT' to the print message
        print(f"Rocket League (v_REDDIT) scraper error: {e}")
        return {"data": {"status": 500, "segments": []}}

    result = []
    
    # 3. Use the lowercase selector for an ATOM feed
    # (ATOM feeds use <entry> instead of <item>)
    post_selector = "entry"
    
    # Added 'v_REDDIT' to the print message
    print(f"Using RL post selector (v_REDDIT): '{post_selector}'")

    for item in parser.css(post_selector):
        try:
            #
            # --- THIS IS THE FIX ---
            # All selectors are now all-lowercase
            #
            
            # 4. Get Title
            title_node = item.css_first("title")
            title = title_node.text(strip=True) if title_node else "No Title Found"
            
            # 5. Get Link
            link_node = item.css_first("link")
            url_path = link_node.attributes.get('href', '#') # Get the 'href' attribute

            # 6. Get Date (using lowercase "updated")
            date_node = item.css_first("updated") 
            date_raw = date_node.text(strip=True).split('T')[0] # Get '2025-11-17'
            
            # 7. Get Author (using "author name" selector)
            author_node = item.css_first("author name")
            author = author_node.text(strip=True) if author_node else "Reddit"


            # Get Description
            content_node = item.css_first("content")
            description = content_node.text(strip=True) if content_node else "..."

            result.append(
                {
                    "title": title,
                    "description": description, # <-- UPDATED
                    "date": date_raw,
                    "author": author,
                    "url_path": url_path,
                }
            )
        
        except Exception as e:
            # If one item is bad, skip it
            print(f"  ... skipped one item due to error: {e}")
            continue
            
    print(f"RL Scraper (v_REDDIT) found {len(result)} results.")
    final_data = {"data": {"status": status, "segments": result}}

    return final_data