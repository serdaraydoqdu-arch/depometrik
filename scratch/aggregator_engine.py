import os
import asyncio
import uuid
from datetime import datetime
from pydantic import BaseModel, Field
from google import genai
from supabase import create_client, Client
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig, UndetectedAdapter
from crawl4ai.async_crawler_strategy import AsyncPlaywrightCrawlerStrategy

# Pydantic schemas for Gemini Structured Outputs
class CampaignRule(BaseModel):
    bank_name: str = Field(description="Official name of the bank organizing the campaign. E.g. Garanti BBVA, İş Bankası, Yapı Kredi, Akbank, Ziraat Bankası, VakıfBank")
    station_brand: str = Field(description="The fuel brand targeted. Must be one of: Shell, Opet, BP, Petrol Ofisi, Aygaz, Total, or Genel if it applies to all stations.")
    target_tx_count: int = Field(description="Target number of transactions required to unlock the reward. E.g. 4")
    min_tx_amount: float = Field(description="Minimum transaction amount in Turkish Liras for each purchase to count.")
    reward_amount: float = Field(description="Total reward amount in TL (points or cashback) unlocked upon completion.")
    is_different_days_required: bool = Field(description="True if purchases must be made on different days, false otherwise.")
    expiry_date: str = Field(description="Expiry date of the campaign in YYYY-MM-DD format.")

class CampaignExtractionList(BaseModel):
    campaigns: list[CampaignRule]

# Target Bank Campaign URLs
CAMPAIGN_SOURCES = [
    {"bank": "Garanti BBVA", "url": "https://www.bonus.com.tr/kampanyalar/akaryakit-kampanyalari"},
    {"bank": "Yapı Kredi", "url": "https://www.worldcard.com.tr/kampanyalar/akaryakit"},
    {"bank": "İş Bankası", "url": "https://www.maximum.com.tr/kampanyalar/akaryakit"},
]

async def scrape_and_parse(url: str, bank_name: str) -> list[dict]:
    print(f"Scraping campaign page for {bank_name}...")
    
    # Configure Crawl4AI with Stealth Mode
    browser_config = BrowserConfig(
        enable_stealth=True,
        headless=True,
        viewport_width=1920,
        viewport_height=1080,
        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    )
    
    markdown_content = ""
    async with AsyncWebCrawler(config=browser_config) as crawler:
        result = await crawler.arun(url)
        if result.success:
            markdown_content = result.markdown
        else:
            print(f"Stealth Mode failed for {bank_name}. Trying Undetected Browser...")
            adapter = UndetectedAdapter()
            strategy = AsyncPlaywrightCrawlerStrategy(
                browser_config=browser_config,
                browser_adapter=adapter
            )
            async with AsyncWebCrawler(crawler_strategy=strategy, config=browser_config) as undetected_crawler:
                run_config = CrawlerRunConfig(flatten_shadow_dom=True, word_count_threshold=20)
                result_undetected = await undetected_crawler.arun(url, config=run_config)
                if result_undetected.success:
                    markdown_content = result_undetected.markdown

    if not markdown_content:
        print(f"Failed to scrape content for {bank_name}.")
        return []

    # Initialize Gemini client
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("GEMINI_API_KEY not found in environment variables.")
        return []

    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are an expert financial analyst. Analyze the following scraped markdown content of the bank campaigns page for {bank_name}.
    Identify and extract only the campaigns that are related to 'Akaryakıt' (fuel/petrol/diesel/LPG, e.g., Shell, Opet, BP, Petrol Ofisi, Aygaz).
    Ignore all other categories (food, clothing, e-commerce, travel, etc.).
    Extract details strictly matching the JSON schema provided.

    Scraped Markdown Content:
    {markdown_content}
    """

    try:
        response = client.models.generate_content(
            model='gemini-2.0-flash-lite',
            contents=prompt,
            config={
                'response_mime_type': 'application/json',
                'response_schema': CampaignExtractionList,
                'temperature': 0.1
            }
        )
        
        # Parse output JSON
        import json
        data = json.loads(response.text)
        return data.get("campaigns", [])
    except Exception as e:
        print(f"Gemini API parsing failed for {bank_name}: {e}")
        return []

async def main():
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    
    if not supabase_url or not supabase_key:
        print("Supabase credentials not found in environment variables. Running in dry-run mode.")
        supabase = None
    else:
        supabase: Client = create_client(supabase_url, supabase_key)

    all_extracted_rules = []
    
    for source in CAMPAIGN_SOURCES:
        campaigns = await scrape_and_parse(source["url"], source["bank"])
        for camp in campaigns:
            all_extracted_rules.append(camp)

    print(f"Extracted {len(all_extracted_rules)} campaigns in total.")
    
    if supabase:
        for rule in all_extracted_rules:
            # Prepare row for Supabase global_campaigns
            row = {
                "id": str(uuid.uuid4()),
                "bank_name": rule["bank_name"],
                "station_brand": rule["station_brand"],
                "target_tx_count": rule["target_tx_count"],
                "min_tx_amount": rule["min_tx_amount"],
                "reward_amount": rule["reward_amount"],
                "is_different_days_required": rule["is_different_days_required"],
                "expiry_date": rule["expiry_date"] + "T23:59:59Z", # Standardize to ISO timestamp
                "is_active": True
            }
            
            try:
                # Upsert to prevent duplicate campaigns on (bank_name, station_brand, expiry_date)
                # In PostgreSQL, we have a unique constraint/index. 
                # This syntax performs an upsert:
                res = supabase.table("global_campaigns").upsert(
                    row, 
                    on_conflict="bank_name,station_brand,expiry_date"
                ).execute()
                print(f"Upserted campaign for {rule['bank_name']} - {rule['station_brand']}.")
            except Exception as e:
                print(f"Supabase upsert failed: {e}")
    else:
        print("Dry Run complete. Extracted campaigns:")
        for r in all_extracted_rules:
            print(f" - {r}")

if __name__ == "__main__":
    asyncio.run(main())
