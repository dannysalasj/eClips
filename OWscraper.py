import requests
from selectolax.parser import HTMLParser
import re

# NOTE: Using a default header to mimic a standard browser request.
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}

# This function pulls news from the MMO-Champion Overwatch section.
def ow_news():
    url = "https://www.mmo-champion.com/content/7421-overwatch"
    
    try:
        resp = requests.get(url, headers=headers, timeout=15) 
        resp.raise_for_status() 
    except requests.RequestException as e:
        print(f"MMO-Champion scraper network error: {e}")
        return {"data": {"status": 500, "segments": []}}

    html = HTMLParser(resp.text)
    status = resp.status_code

    result = []
    
    # --- START OF MODIFICATIONS ---
    
    # 1. This selector finds ALL <div class="message"> containers
    post_container_selector = "div.message" 
    print(f"Using container selector: '{post_container_selector}'")
    
    # --- THIS IS THE FIX ---
    # Use .css() to get ALL containers, not .css_first()
    all_containers = html.css(post_container_selector)
    
    if not all_containers:
        print("MMO-Champion Scraper found 0 results. Could not find any 'div.message' containers.")
        return {"data": {"status": status, "segments": []}}
    
    print(f"Found {len(all_containers)} 'div.message' containers to search.")
        
    # 2. This selector finds the "yellow letter" titles
    title_selector = "b font[color='#FFF3A5']"
    
    # --- 3. LOOP THROUGH EVERY CONTAINER ---
    for container in all_containers:
        
        # Find all titles *within this specific container*
        title_nodes = container.css(title_selector) 
        
        # 4. Loop through EACH title we found in THIS container
        for title_node in title_nodes:
            
            # Get the Title text
            title = title_node.text(strip=True)
            if not title:
                continue
                
            print(f"  ... found title: {title}")
                
            # Hardcode all other fields as requested
            url_final = url 
            author = "MMO-Champion"
            date_text = "Unknown Date" 
            description_snippet = "No summary available..."
            clean_title = re.sub(r'\[OW\]\s*', '', title, flags=re.IGNORECASE).strip()

            result.append(
                {
                "title": clean_title,
                "author": author,
                "date": date_text,
                "url_path": url_final,
                "description": description_snippet
                }
            )
        
    # --- END OF MODIFICATIONS ---

    data = {"data": {"status": status, "segments": result}}
    
    if not result and status == 200:
        print("MMO-Champion Scraper found 'div.message' but 0 titles inside. Verify 'title_selector'.")
    elif status == 200:
        print(f"MMO-Champion Scraper found {len(result)} total results.")

    return data
