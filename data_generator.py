import pandas as pd
import numpy as np
import datetime
import random

def generate_maharashtra_mandi_data():
    start_date = datetime.date(2026, 1, 1)
    end_date = datetime.date(2026, 4, 25)
    delta = end_date - start_date
    
    dates = [start_date + datetime.timedelta(days=i) for i in range(delta.days + 1)]
    
    commodities = {
        "Tomato": {"base_price": 1200, "volatility": 400, "trend": 1.2},
        "Onion": {"base_price": 1500, "volatility": 300, "trend": 0.8},
        "Potato": {"base_price": 1000, "volatility": 100, "trend": 1.0},
        "Brinjal": {"base_price": 2000, "volatility": 200, "trend": 1.1},
        "Cabbage": {"base_price": 800, "volatility": 150, "trend": 0.9},
        "Cauliflower": {"base_price": 1800, "volatility": 250, "trend": 1.1},
        "Okra": {"base_price": 3000, "volatility": 500, "trend": 1.3},
        "Green Chilli": {"base_price": 4000, "volatility": 800, "trend": 1.2},
        "Spinach": {"base_price": 1500, "volatility": 300, "trend": 1.0},
        "Bitter Gourd": {"base_price": 2500, "volatility": 400, "trend": 1.1}
    }
    
    districts = [
        "Ahmednagar", "Akola", "Amravati", "Aurangabad", "Beed", "Bhandara", "Buldhana", 
        "Chandrapur", "Dhule", "Gadchiroli", "Gondia", "Hingoli", "Jalgaon", "Jalna", 
        "Kolhapur", "Latur", "Mumbai City", "Mumbai Suburban", "Nagpur", "Nanded", 
        "Nandurbar", "Nashik", "Osmanabad", "Palghar", "Parbhani", "Pune", "Raigad", 
        "Ratnagiri", "Sangli", "Satara", "Sindhudurg", "Solapur", "Thane", "Wardha", 
        "Washim", "Yavatmal"
    ]
    markets = ["APMC Market", "Mandi"]
    
    data = []
    
    for date in dates:
        for commodity, params in commodities.items():
            # Add some seasonal/random variation
            # Prices tend to fluctuate weekly and monthly
            seasonal_factor = 1 + 0.2 * np.sin(2 * np.pi * date.timetuple().tm_yday / 365)
            
            for district in districts:
                # District specific price variation
                dist_factor = random.uniform(0.9, 1.1)
                
                # Base price calculation
                price_quintal = params["base_price"] * params["trend"] * seasonal_factor * dist_factor
                # Add random noise
                price_quintal += random.gauss(0, params["volatility"])
                price_quintal = max(price_quintal, 300) # Minimum price floor
                
                # Arrival quantity (inverse to price usually)
                arrival = random.randint(50, 500) * (2000 / price_quintal)
                
                data.append({
                    "commodity": commodity,
                    "state": "Maharashtra",
                    "district": district,
                    "market": random.choice(markets),
                    "date": date.strftime("%Y-%m-%d"),
                    "quintal_price": f"₹ {round(price_quintal, 2)}",
                    "kg_price": f"{round(price_quintal/100, 2)} per kg",
                    "arrival_quantity": round(arrival, 2)
                })
    
    df = pd.DataFrame(data)
    output_path = "Maharashtra_Crop_Analysis/data/mandi_data_2026.csv"
    df.to_csv(output_path, index=False)
    print(f"Generated {len(df)} rows of historical data at {output_path}")
    return output_path

if __name__ == "__main__":
    generate_maharashtra_mandi_data()
