import requests

from selectolax.parser import HTMLParser

from utils.utils import headers


# Function that scrapes Valorant news from vlr.gg
def val_news():
# The URL of the Valorant news page to scrape
    url = "https://www.vlr.gg/news"
# Sends an HTTP GET request to the URL
    resp = requests.get(url, headers=headers)
# Parses the HTML content of the response
    html = HTMLParser(resp.text)
# Stores the HTTP status code
    status = resp.status_code

    result = []
# Loops through each news item container using a CSS selector
    for item in html.css("a.wf-module-item"):
# Extracts the combined date and author text
        date_author = item.css_first("div.ge-text-light").text()
# Splits the combined text into date and author
        date, author = date_author.split("by")

# Extracts the description snippet
        desc = item.css_first("div").css_first("div:nth-child(2)").text().strip()

# Extracts the title, cleaning up newlines and tabs
        title = item.css_first("div:nth-child(1)").text().strip().split("\n")[0]
        title = title.replace("\t", "")

# Extracts the relative URL path from the anchor tag's 'href' attribute
        url = item.css_first("a.wf-module-item").attributes["href"]

# Appends the extracted and cleaned data to the result list
        result.append(
            {
                "title": title,
                "description": desc,
# Cleans and strips the date text
                "date": date.split("\u2022")[1].strip(),
# Cleans and strips the author text
                "author": author.strip(),
# Constructs the full absolute URL path
                "url_path": "https://vlr.gg" + url,
            }
        )

# Constructs the final data dictionary structure
    data = {"data": {"status": status, "segments": result}}

# Raises an exception if the status code is not 200
    if status != 200:
        raise Exception("API response: {}".format(status))
# Returns the final news data
    return data
