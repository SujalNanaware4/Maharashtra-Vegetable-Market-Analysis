import pandas as pd
import numpy as np

def clean_and_process_data(input_path, output_path):
    print(f"Cleaning data from {input_path}...")
    df = pd.read_csv(input_path)
    
    # 1. Clean price columns
    # Remove ₹, commas, and other units
    def clean_price(val):
        if pd.isna(val): return 0
        val = str(val).replace('₹', '').replace(',', '').strip()
        # Handle "per kg" or other strings
        val = val.split(' ')[0]
        try:
            return float(val)
        except ValueError:
            return 0

    df['quintal_price'] = df['quintal_price'].apply(clean_price)
    df['kg_price'] = df['kg_price'].apply(clean_price)
    
    # 2. Convert date column to datetime format
    df['date'] = pd.to_datetime(df['date'])
    
    # 3. Standardize vegetable names (Title Case)
    df['commodity'] = df['commodity'].str.strip().str.title()
    
    # 4. Handle missing/null values
    # Fill missing prices with the mean of that commodity
    df['quintal_price'] = df.groupby('commodity')['quintal_price'].transform(lambda x: x.replace(0, x.mean()))
    df['kg_price'] = df.groupby('commodity')['kg_price'].transform(lambda x: x.replace(0, x.mean()))
    
    # 5. Feature Engineering
    print("Performing Feature Engineering...")
    
    # Average price per vegetable (across the whole period)
    df['avg_commodity_price'] = df.groupby('commodity')['quintal_price'].transform('mean')
    
    # Price volatility (standard deviation per vegetable)
    df['price_volatility'] = df.groupby('commodity')['quintal_price'].transform('std')
    
    # Supply gap indicator = high price + low arrivals
    # First normalize price and arrivals to 0-1 scale to combine them
    df['norm_price'] = df.groupby('commodity')['quintal_price'].transform(lambda x: (x - x.min()) / (x.max() - x.min() + 1))
    df['norm_arrival'] = df.groupby('commodity')['arrival_quantity'].transform(lambda x: (x - x.min()) / (x.max() - x.min() + 1))
    
    # Supply gap is high when price is high and arrival is low
    df['supply_gap_score'] = df['norm_price'] * (1 - df['norm_arrival'])
    
    # Profit score = avg_price * arrival (proxy for production if production data not merged yet)
    df['profit_score'] = df['quintal_price'] * df['arrival_quantity']
    
    # Save processed data
    df.to_csv(output_path, index=False)
    print(f"Processed data saved to {output_path}")
    return df

if __name__ == "__main__":
    clean_and_process_data(
        "Maharashtra_Crop_Analysis/data/mandi_data_2026.csv",
        "Maharashtra_Crop_Analysis/data/mandi_data_cleaned.csv"
    )
