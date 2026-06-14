import os
import asyncio
import uuid
import json
import urllib.parse
from datetime import datetime
from pydantic import BaseModel, Field
from google import genai
from supabase import create_client, Client
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig, UndetectedAdapter
from crawl4ai.async_crawler_strategy import AsyncPlaywrightCrawlerStrategy

# Load .env file manually if it exists
if os.path.exists(".env"):
    with open(".env", "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                os.environ[k.strip()] = v.strip()

# Pydantic schemas for Gemini Structured Outputs

# Step 1 Schema: Extracting campaign detail URLs
class CampaignLink(BaseModel):
    title: str = Field(description="Title of the campaign")
    url: str = Field(description="Relative or absolute URL of the campaign detail page")

class CampaignLinkList(BaseModel):
    campaign_links: list[CampaignLink]

# Step 2 Schema: Extracting structured campaign rules
class CampaignRule(BaseModel):
    bank_name: str = Field(description="Official name of the bank organizing the campaign. E.g. Garanti BBVA, İş Bankası, Yapı Kredi, Akbank, Ziraat Bankası, VakıfBank")
    station_brand: str = Field(description="The fuel brand targeted. Must be one of: Shell, Opet, BP, Petrol Ofisi, Aygaz, Total, or Genel if it applies to all stations.")
    target_tx_count: int = Field(default=4, description="Target number of transactions required to unlock the reward. E.g. 4")
    min_tx_amount: float = Field(default=0.0, description="Minimum transaction amount in Turkish Liras for each purchase to count.")
    reward_amount: float = Field(default=0.0, description="Total reward amount in TL (points or cashback) unlocked upon completion.")
    is_different_days_required: bool = Field(default=True, description="True if purchases must be made on different days, false otherwise.")
    expiry_date: str = Field(default="", description="Expiry date of the campaign in YYYY-MM-DD format.")
    campaign_url: str = Field(default="", description="The campaign detail URL.")
    description: str = Field(default="", description="Detailed explanation of the campaign rules, rewards, and eligibility in Turkish. E.g. 'Maximum Kart ile Shell'de farklı günlerde 4 adet 1500 TL harcamaya 450 TL MaxiPuan.'")

class CampaignExtractionList(BaseModel):
    campaigns: list[CampaignRule]

# Target Bank Campaign URLs
CAMPAIGN_SOURCES = [
    {
        "bank": "Garanti BBVA",
        "list_url": "https://www.bonus.com.tr/kampanyalar",
        "base_url": "https://www.bonus.com.tr"
    },
    {
        "bank": "Yapı Kredi",
        "list_url": "https://www.worldcard.com.tr/firsatlar",
        "base_url": "https://www.worldcard.com.tr"
    },
    {
        "bank": "İş Bankası",
        "list_url": "https://www.maximum.com.tr/kampanyalar",
        "base_url": "https://www.maximum.com.tr"
    },
    {
        "bank": "Akbank",
        "list_url": "https://www.axess.com.tr/axess/kampanyalar",
        "base_url": "https://www.axess.com.tr"
    },
    {
        "bank": "Ziraat Bankası",
        "list_url": "https://www.bankkart.com.tr/kampanyalar",
        "base_url": "https://www.bankkart.com.tr"
    },
    {
        "bank": "QNB Finansbank",
        "list_url": "https://www.cardfinans.com/kampanyalar",
        "base_url": "https://www.cardfinans.com"
    },
    {
        "bank": "Halkbank",
        "list_url": "https://www.parafcard.com.tr/tr/kampanyalar.html",
        "base_url": "https://www.parafcard.com.tr"
    },
    {
        "bank": "VakıfBank",
        "list_url": "https://www.vakifkart.com.tr/kampanyalar",
        "base_url": "https://www.vakifkart.com.tr"
    },
]

import re

KEYWORDS = ["akaryakıt", "petrol", "motorin", "dizel", "lpg", "shell", "opet", "bp", "petrol ofisi", "aygaz", "total", "yakıt", "world üye", "maximum üye", "bonus üye"]

# Compile regexes once
KEYWORD_REGEXES = []
for kw in KEYWORDS:
    if " " in kw:
        KEYWORD_REGEXES.append(re.compile(re.escape(kw), re.IGNORECASE))
    else:
        KEYWORD_REGEXES.append(re.compile(rf'\b{re.escape(kw)}\b', re.IGNORECASE))

def clean_markdown_by_keywords(markdown_text: str, keywords: list[str], window_before: int = 5, window_after: int = 10) -> str:
    """
    Filters the markdown text to keep only lines matching keywords along with surrounding context lines.
    This helps keep token counts extremely small and avoids Gemini 429 quota limits.
    """
    if not markdown_text:
        return ""
    lines = markdown_text.splitlines()
    matching_indices = []
    
    for idx, line in enumerate(lines):
        if any(rx.search(line) for rx in KEYWORD_REGEXES):
            matching_indices.append(idx)
            
    if not matching_indices:
        return ""
        
    keep_indices = set()
    for idx in matching_indices:
        start = max(0, idx - window_before)
        end = min(len(lines), idx + window_after + 1)
        for i in range(start, end):
            keep_indices.add(i)
            
    sorted_indices = sorted(list(keep_indices))
    cleaned_lines = []
    last_idx = -1
    for idx in sorted_indices:
        if last_idx != -1 and idx > last_idx + 1:
            cleaned_lines.append("\n... [content omitted] ...\n")
        cleaned_lines.append(lines[idx])
        last_idx = idx
        
    return "\n".join(cleaned_lines)

async def scrape_url_content(url: str, browser_config: BrowserConfig, delay: float = 3.0) -> str:
    """
    Crawls a URL using Crawl4AI, falling back to Undetected Browser if needed.
    """
    run_config = CrawlerRunConfig(
        delay_before_return_html=delay,
        flatten_shadow_dom=True
    )
    
    async with AsyncWebCrawler(config=browser_config) as crawler:
        result = await crawler.arun(url, config=run_config)
        if result.success:
            return result.markdown or ""
            
    # Fallback to Undetected Browser adapter
    print(f"Stealth Mode failed/empty for {url}. Retrying with Undetected Browser Adapter...")
    try:
        adapter = UndetectedAdapter()
        strategy = AsyncPlaywrightCrawlerStrategy(
            browser_config=browser_config,
            browser_adapter=adapter
        )
        async with AsyncWebCrawler(crawler_strategy=strategy, config=browser_config) as undetected_crawler:
            result_undetected = await undetected_crawler.arun(url, config=run_config)
            if result_undetected.success:
                return result_undetected.markdown or ""
    except Exception as e:
        print(f"Undetected Browser fallback error: {e}")
        
    return ""

async def call_gemini_with_retry(client: genai.Client, prompt: str, schema: type, model: str = 'gemini-2.5-flash', max_retries: int = 3, initial_delay: float = 20.0) -> dict:
    """
    Calls Gemini API with exponential backoff on 429 rate limit errors.
    """
    delay = initial_delay
    for attempt in range(max_retries):
        try:
            response = client.models.generate_content(
                model=model,
                contents=prompt,
                config={
                    'response_mime_type': 'application/json',
                    'response_schema': schema,
                    'temperature': 0.1
                }
            )
            return json.loads(response.text)
        except Exception as e:
            err_str = str(e)
            if "429" in err_str or "RESOURCE_EXHAUSTED" in err_str or "503" in err_str or "UNAVAILABLE" in err_str:
                print(f"Gemini API rate limit or service error ({err_str}). Retrying in {delay} seconds (Attempt {attempt+1}/{max_retries})...")
                await asyncio.sleep(delay)
                delay *= 2  # Exponential backoff
            else:
                print(f"Gemini API error during call: {e}")
                raise e
    raise RuntimeError("Failed to get response from Gemini API after maximum retries due to rate limits.")

async def call_gemini_search_then_parse(client: genai.Client, search_prompt: str, schema: type, model: str = 'gemini-2.5-flash', max_retries: int = 3, initial_delay: float = 20.0) -> dict:
    """
    Two-pass approach:
    1. Call Gemini with Google Search tool (no schema constraint) to search the web and return plain text detail.
    2. Pass the search text detail to Gemini again with response_schema to get structured JSON.
    This guarantees compatibility across all Gemini API versions and models.
    """
    search_text = ""
    delay = initial_delay
    for attempt in range(max_retries):
        try:
            response = client.models.generate_content(
                model=model,
                contents=search_prompt,
                config={
                    'tools': [{'google_search': {}}],
                    'temperature': 0.1
                }
            )
            search_text = response.text
            if search_text:
                break
        except Exception as e:
            err_str = str(e)
            if "429" in err_str or "RESOURCE_EXHAUSTED" in err_str or "503" in err_str or "UNAVAILABLE" in err_str:
                print(f"Gemini Search API rate limit ({err_str}). Retrying in {delay} seconds (Attempt {attempt+1}/{max_retries})...")
                await asyncio.sleep(delay)
                delay *= 2
            else:
                print(f"Gemini Search API error in Pass 1: {e}")
                raise e
    
    if not search_text:
        raise RuntimeError("Pass 1: Search returned empty content or failed.")
        
    parse_prompt = f"""
    You are an expert financial analyst. From the following gathered information, extract the structured campaign data matching the JSON schema.
    
    Gathered Information:
    {search_text}
    """
    return await call_gemini_with_retry(client, parse_prompt, schema, model, max_retries, initial_delay)

async def get_active_campaign_links(client: genai.Client, bank_name: str, list_url: str, browser_config: BrowserConfig) -> list[dict]:
    """
    Step 1: Scrapes the list page, filters it, and queries Gemini to extract active fuel campaign URLs.
    If direct scraping fails, falls back to Google Search grounding.
    """
    links = []
    
    # Try scraping first
    markdown_content = await scrape_url_content(list_url, browser_config, delay=4.0)
    cleaned_markdown = ""
    if markdown_content:
        cleaned_markdown = clean_markdown_by_keywords(markdown_content, KEYWORDS, window_before=4, window_after=8)
        
    if cleaned_markdown:
        # Save list page markdown for debugging
        safe_bank_name = bank_name.replace(" ", "_")
        os.makedirs("scratch/scraped_pages", exist_ok=True)
        with open(f"scratch/scraped_pages/{safe_bank_name}_list_cleaned.md", "w", encoding="utf-8") as f:
            f.write(cleaned_markdown)

        prompt = f"""
        You are an expert financial analyst. Analyze the following scraped markdown content of the bank campaigns page for {bank_name}.
        Extract only the active campaigns that are related to 'Akaryakıt' (fuel/petrol/diesel/LPG, E.g. Shell, Opet, BP, Petrol Ofisi, Aygaz).
        Do NOT extract campaigns that are under the expired section marked 'SÜRESİ BİTTİ' or whose links end in '#gecmis' or '#gecmis-kampanyalar'.
        For each matched active campaign, extract its title and its detail page URL.

        Scraped Markdown Content:
        {cleaned_markdown}
        """
        try:
            data = await call_gemini_with_retry(client, prompt, CampaignLinkList)
            links = data.get("campaign_links", [])
        except Exception as e:
            print(f"Gemini Step 1 parsing failed for {bank_name}: {e}")

    # Fallback if no links found (timed out, blocked, or 0 links matched)
    if not links:
        print(f"Scraper found 0 campaigns for {bank_name} or connection failed. Initiating Gemini Google Search Fallback...")
        search_prompt = f"""
        Search Google to find the active 'Akaryakıt' (fuel/petrol/LPG/diesel, e.g. Shell, Opet, BP, Petrol Ofisi, Aygaz, Total) campaigns for {bank_name} active in June 2026.
        For each active campaign, find its official campaign detail page URL and title.
        Do NOT include expired campaigns or past campaigns.
        """
        try:
            data = await call_gemini_search_then_parse(client, search_prompt, CampaignLinkList)
            links = data.get("campaign_links", [])
            print(f"Gemini Google Search Fallback successfully found {len(links)} campaigns for {bank_name}!")
        except Exception as e:
            print(f"Gemini Google Search Fallback failed for {bank_name}: {e}")
            
    return links

async def scrape_and_parse_campaigns_batch(client: genai.Client, bank_name: str, campaigns: list[dict], base_url: str, browser_config: BrowserConfig, current_date: str) -> list[dict]:
    """
    Scrapes detail pages in parallel, cleans markdown, and sends a single batch prompt to Gemini
    to extract all rules in one go, dramatically reducing API request counts.
    If direct scraping fails, falls back to 2-pass Google Search grounding for details.
    """
    if not campaigns:
        return []

    # Parallel Scrape
    tasks = []
    urls = []
    for link in campaigns:
        abs_url = urllib.parse.urljoin(base_url, link["url"])
        urls.append((link["title"], abs_url))
        tasks.append(scrape_url_content(abs_url, browser_config, delay=2.0))
        
    print(f"Scraping {len(urls)} detail pages in parallel for {bank_name}...")
    markdowns = await asyncio.gather(*tasks)
    
    # Process scraped contents
    scraped_details_text = ""
    for (title, abs_url), md in zip(urls, markdowns):
        cleaned_md = ""
        if md:
            cleaned_md = clean_markdown_by_keywords(md, KEYWORDS, window_before=8, window_after=15)
            if not cleaned_md:
                cleaned_md = md[:8000] # Fallback to first 8k chars
        
        if cleaned_md:
            scraped_details_text += f"\n--- CAMPAIGN: {title} ---\nURL: {abs_url}\n{cleaned_md}\n"
            
    extracted_rules = []
    
    # Try direct parse on scraped combined content if we have scraped text
    if scraped_details_text:
        batch_prompt = f"""
        You are an expert financial analyst. Analyze the following scraped markdown content of multiple bank campaign detail pages for {bank_name}.
        Extract the campaign terms matching the JSON schema provided (a list of campaigns).
        Ensure the campaign_url for each campaign matches the URL provided in the heading.

        Current Date context:
        - The current date is {current_date}.
        - Use this to calculate absolute expiry date.
        - If the expiry year is not specified, assume it is {datetime.now().year}.

        Scraped Detail Pages Content:
        {scraped_details_text}
        """
        try:
            data = await call_gemini_with_retry(client, batch_prompt, CampaignExtractionList)
            extracted_rules = data.get("campaigns", [])
            print(f"Successfully batch-extracted {len(extracted_rules)} rules from scraped pages for {bank_name}.")
        except Exception as e:
            print(f"Gemini batch detail parsing failed for {bank_name}: {e}")
            
    # Fallback to search grounding for missing details
    if not extracted_rules:
        print(f"Direct scrape/parse detail failed for {bank_name} campaigns. Initiating 2-pass Google Search Fallback...")
        campaign_titles = ", ".join([f"'{l['title']}' ({urllib.parse.urljoin(base_url, l['url'])})" for l in campaigns])
        search_prompt = f"""
        Search Google to find the official terms and conditions for these campaigns by {bank_name}: {campaign_titles}.
        For each campaign, extract the campaign rules strictly matching the JSON schema (a list of campaigns).
        Make sure to set the correct campaign_url for each.

        Current Date context:
        - The current date is {current_date}.
        - Use this to calculate absolute expiry date.
        """
        try:
            data = await call_gemini_search_then_parse(client, search_prompt, CampaignExtractionList)
            extracted_rules = data.get("campaigns", [])
            print(f"Gemini Google Search Fallback successfully batch-extracted {len(extracted_rules)} details for {bank_name}!")
        except Exception as e:
            print(f"Gemini Google Search Fallback batch detail extraction failed for {bank_name}: {e}")
            
    return extracted_rules

async def main():
    # Setup Gemini API client
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("GEMINI_API_KEY not found in environment variables.")
        return
        
    client = genai.Client(api_key=api_key)
    current_date = datetime.now().strftime("%Y-%m-%d")
    
    # Configure Crawl4AI Browser
    browser_config = BrowserConfig(
        enable_stealth=True,
        headless=True,
        viewport_width=1920,
        viewport_height=1080,
        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        extra_args=["--disable-http2"]
    )

    all_extracted_rules = []

    # Step 1 & 2 Execution
    for source in CAMPAIGN_SOURCES:
        bank_name = source["bank"]
        print(f"\n=== Processing {bank_name} ===")
        links = await get_active_campaign_links(client, bank_name, source["list_url"], browser_config)
        print(f"Found {len(links)} candidate campaigns for {bank_name}.")
        
        # Batch scrape and parse details
        rules = await scrape_and_parse_campaigns_batch(client, bank_name, links, source["base_url"], browser_config, current_date)
        for rule in rules:
            if hasattr(rule, "model_dump"):
                rule_dict = rule.model_dump()
            elif hasattr(rule, "dict"):
                rule_dict = rule.dict()
            else:
                rule_dict = dict(rule)
                
            # Ensure bank name is populated
            rule_dict["bank_name"] = bank_name
            # Fallback for empty campaign_url
            if not rule_dict.get("campaign_url"):
                # if there is a matching link by title, use it
                matched_url = ""
                for link in links:
                    if link["title"].lower() in rule_dict.get("station_brand", "").lower() or rule_dict.get("station_brand", "").lower() in link["title"].lower():
                        matched_url = urllib.parse.urljoin(source["base_url"], link["url"])
                        break
                rule_dict["campaign_url"] = matched_url or source["list_url"]
                
            all_extracted_rules.append(rule_dict)
            print(f"Successfully extracted rule: {rule_dict}")
        await asyncio.sleep(1.0) # Small pause between banks

    print(f"\nExtraction complete. Total campaigns extracted: {len(all_extracted_rules)}")

    # Database synchronization (Supabase)
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    
    if not supabase_url or not supabase_key:
        print("Supabase credentials not found in environment. Running in dry-run mode.")
        for r in all_extracted_rules:
            print(f"Dry-run Campaign: {r}")
    else:
        supabase: Client = create_client(supabase_url, supabase_key)
        for rule in all_extracted_rules:
            expiry_val = rule.get("expiry_date", "")
            if expiry_val:
                if "T" not in expiry_val:
                    expiry_val = f"{expiry_val}T23:59:59Z"
            else:
                import calendar
                now = datetime.now()
                _, last_day = calendar.monthrange(now.year, now.month)
                expiry_val = f"{now.year}-{now.month:02d}-{last_day:02d}T23:59:59Z"
                
            row = {
                "id": str(uuid.uuid4()),
                "bank_name": rule["bank_name"],
                "station_brand": rule["station_brand"],
                "target_tx_count": int(rule.get("target_tx_count", 4)),
                "min_tx_amount": float(rule.get("min_tx_amount", 0.0)),
                "reward_amount": float(rule.get("reward_amount", 0.0)),
                "is_different_days_required": bool(rule.get("is_different_days_required", True)),
                "expiry_date": expiry_val,
                "campaign_url": rule.get("campaign_url", ""),
                "description": rule.get("description", ""),
                "is_active": True
            }
            
            try:
                # Upsert based on bank_name, station_brand, reward_amount, min_tx_amount, and expiry_date constraints
                supabase.table("global_campaigns").upsert(
                    row,
                    on_conflict="bank_name,station_brand,reward_amount,min_tx_amount,expiry_date"
                ).execute()
                print(f"Successfully upserted: {rule['bank_name']} - {rule['station_brand']} (Expiry: {rule['expiry_date']})")
            except Exception as e:
                print(f"Supabase upsert failed for {rule['bank_name']} {rule['station_brand']}: {e}")

if __name__ == "__main__":
    asyncio.run(main())
