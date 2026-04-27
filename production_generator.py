import pandas as pd
import numpy as np
import random
import datetime

def generate_production_data():
    districts = [
        "Ahmednagar", "Akola", "Amravati", "Aurangabad", "Beed", "Bhandara", "Buldhana", 
        "Chandrapur", "Dhule", "Gadchiroli", "Gondia", "Hingoli", "Jalgaon", "Jalna", 
        "Kolhapur", "Latur", "Mumbai City", "Mumbai Suburban", "Nagpur", "Nanded", 
        "Nandurbar", "Nashik", "Osmanabad", "Palghar", "Parbhani", "Pune", "Raigad", 
        "Ratnagiri", "Sangli", "Satara", "Sindhudurg", "Solapur", "Thane", "Wardha", 
        "Washim", "Yavatmal"
    ]
    
    categories = {
        "Solanaceous": ["Tomato", "Brinjal", "Green Chilli"],
        "Bulb": ["Onion", "Garlic"],
        "Cole Crops": ["Cabbage", "Cauliflower"],
        "Root & Tuber": ["Potato", "Radish", "Carrot"],
        "Leafy": ["Spinach", "Fenugreek"],
        "Cucurbits": ["Bitter Gourd", "Bottle Gourd", "Okra"]
    }
    
    # Months from Jan 2026 to April 2026
    months = ["2026-01", "2026-02", "2026-03", "2026-04"]
    
    data = []
    
    for month in months:
        for category, commodities in categories.items():
            for commodity in commodities:
                for district in districts:
                    # Production in Tonnes
                    # Some districts are hubs for specific crops
                    base_prod = random.randint(500, 5000)
                    
                    # Hub adjustments
                    if district == "Nashik" and commodity == "Onion": base_prod *= 5
                    if district == "Pune" and commodity == "Tomato": base_prod *= 3
                    if district == "Nagpur" and commodity == "Green Chilli": base_prod *= 2
                    
                    # Monthly seasonal factor (Production usually peaks in late winter/early spring)
                    month_num = int(month.split("-")[1])
                    seasonal_factor = 1.0
                    if month_num == 3: seasonal_factor = 1.3 # Peak harvest
                    elif month_num == 4: seasonal_factor = 1.1
                    
                    production = base_prod * seasonal_factor * random.uniform(0.8, 1.2)
                    
                    data.append({
                        "district": district,
                        "category": category,
                        "commodity": commodity,
                        "production_tonnes": round(production, 2),
                        "month": month,
                        "state": "Maharashtra"
                    })
                    
    df = pd.DataFrame(data)
    output_path = "Maharashtra_Crop_Analysis/data/production_data_2026.csv"
    df.to_csv(output_path, index=False)
    print(f"Generated {len(df)} rows of production data at {output_path}")
    return output_path

if __name__ == "__main__":
    generate_production_data()
