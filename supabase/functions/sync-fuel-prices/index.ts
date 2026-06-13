// Supabase Edge Function: sync-fuel-prices
// Dosya: supabase/functions/sync-fuel-prices/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    console.log("Fetching fuel prices from Petrol Ofisi website...");
    const response = await fetch("https://www.petrolofisi.com.tr/akaryakit-fiyatlari", {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error fetching PO prices: ${response.status}`);
    }

    const html = await response.text();
    const bodyClean = html.replace(/\s+/g, ' ');

    const rowRegex = /<tr class="price-row[^"]*"[^>]*data-disctrict-name="([^"]*)"[^>]*>(.*?)<\/tr>/g;
    const tdRegex = /<td>(.*?)<\/td>/g;
    const taxRegex = /<span class="with-tax">(.*?)<\/span>/;

    const cityPrices: Record<string, Array<{ benzin: number; motorin: number; lpg: number }>> = {};

    let rowMatch;
    while ((rowMatch = rowRegex.exec(bodyClean)) !== null) {
      const poCity = rowMatch[1];
      const rowHtml = rowMatch[2];

      const prices: string[] = [];
      let tdMatch;
      const localTdRegex = new RegExp(tdRegex);
      while ((tdMatch = localTdRegex.exec(rowHtml)) !== null) {
        const tdHtml = tdMatch[1];
        const taxMatch = taxRegex.exec(tdHtml);
        if (taxMatch) {
          prices.push(taxMatch[1].trim());
        } else {
          const cleanVal = tdHtml.replace(/<[^>]+>/g, '').trim();
          if (cleanVal.length > 0) {
            prices.push(cleanVal);
          }
        }
      }

      if (prices.length >= 7) {
        const appCity = mapPoCityToAppCity(poCity);
        const benzinVal = parseFloat(prices[1].replace(',', '.'));
        const motorinVal = parseFloat(prices[2].replace(',', '.'));
        const lpgVal = parseFloat(prices[6].replace(',', '.'));

        if (appCity && !isNaN(benzinVal) && !isNaN(motorinVal) && !isNaN(lpgVal)) {
          if (!cityPrices[appCity]) {
            cityPrices[appCity] = [];
          }
          cityPrices[appCity].push({
            benzin: benzinVal,
            motorin: motorinVal,
            lpg: lpgVal,
          });
        }
      }
    }

    const todayStr = new Date().toISOString().split('T')[0];
    const rowsToInsert: Array<{ province_code: string; fuel_type: string; price_date: string; price: number }> = [];

    // Tüm parse edilen şehirler için ortalama hesaplayıp insert edelim
    for (const [appCity, dataList] of Object.entries(cityPrices)) {
      let sumBenzin = 0;
      let sumMotorin = 0;
      let sumLpg = 0;

      for (const item of dataList) {
        sumBenzin += item.benzin;
        sumMotorin += item.motorin;
        sumLpg += item.lpg;
      }

      const avgBenzin = parseFloat((sumBenzin / dataList.length).toFixed(2));
      const avgMotorin = parseFloat((sumMotorin / dataList.length).toFixed(2));
      const avgLpg = parseFloat((sumLpg / dataList.length).toFixed(2));

      rowsToInsert.push(
        { province_code: appCity, fuel_type: 'BENZIN', price_date: todayStr, price: avgBenzin },
        { province_code: appCity, fuel_type: 'MAZOT', price_date: todayStr, price: avgMotorin },
        { province_code: appCity, fuel_type: 'LPG', price_date: todayStr, price: avgLpg }
      );
    }

    let totalUpdated = 0;
    if (rowsToInsert.length > 0) {
      console.log(`Upserting ${rowsToInsert.length} fuel price rows to Supabase...`);
      const { error: insertError } = await supabase
        .from('fuel_prices')
        .upsert(rowsToInsert, { onConflict: 'province_code,fuel_type,price_date' });

      if (insertError) {
        throw insertError;
      }
      totalUpdated = rowsToInsert.length;
      console.log(`Successfully updated prices database with ${totalUpdated} entries.`);
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `Fiyat senkronizasyonu tamamlandı. Güncellenen satır sayısı: ${totalUpdated}` 
      }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" }, 
        status: 200 
      }
    );
  } catch (error) {
    console.error("Error in sync-fuel-prices function:", error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" }, 
        status: 400 
      }
    );
  }
})

function mapPoCityToAppCity(poCity: string): string | null {
  const clean = poCity.trim().toUpperCase();
  if (clean === 'ISTANBUL (AVRUPA)' || clean === 'ISTANBUL (ANADOLU)') {
    return 'ISTANBUL';
  }
  if (clean === 'AFYON') {
    return 'AFYONKARAHISAR';
  }
  return clean;
}
