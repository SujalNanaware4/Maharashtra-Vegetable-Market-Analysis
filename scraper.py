import requests
from bs4 import BeautifulSoup
import pandas as pd
import datetime
import time

def scrape_kisandeals_live(commodity="TOMATO", state="MAHARASHTRA"):
    """
    Scrapes live mandi prices for a specific commodity and state from KisanDeals.
    Note: This is a demonstration script for live scraping.
    """
    url = f"https://www.kisandeals.com/mandiprices/{commodity}/{state}/ALL"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    
    print(f"Scraping {commodity} in {state} from {url}...")
    
    try:
        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            print(f"Failed to fetch data: HTTP {response.status_code}")
            return None
        
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # In a real scenario, we would find the table or list items.
        # Based on the fetch result, we see summary text.
        # Here we simulate extracting the average price from the text if a table isn't found.
        
        data = []
        # Example extraction logic (would be refined based on actual HTML structure)
        # For now, we'll just log that we reached the page and found some summary info.
        
        summary_divs = soup.find_all('div')
        avg_price = None
        for div in summary_divs:
            if "mandi rate" in div.text.lower() and "average" in div.text.lower():
                # Extract numeric value
                import re
                match = re.search(r'₹\s*([\d,]+)', div.text)
                if match:
                    avg_price = match.group(1).replace(',', '')
                    break
        
        if avg_price:
            data.append({
                "commodity": commodity,
                "state": state,
                "district": "All",
                "market": "Average",
                "date": datetime.date.today().strftime("%Y-%m-%d"),
                "quintal_price": avg_price,
                "kg_price": float(avg_price) / 100
            })
            
        return pd.DataFrame(data)
    
    except Exception as e:
        print(f"Error during scraping: {e}")
        return None

if __name__ == "__main__":
    # Test with Tomato
    df = scrape_kisandeals_live("TOMATO", "MAHARASHTRA")
    if df is not None and not df.empty:
        print("Scraped Data Sample:")
        print(df)
        df.to_csv("Maharashtra_Crop_Analysis/data/live_tomato_sample.csv", index=False)
    else:
        print("No data scraped. This might be due to dynamic content or anti-scraping measures.")
